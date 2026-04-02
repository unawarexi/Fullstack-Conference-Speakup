// ============================================================================
// SpeakUp — Billing Service
// Stripe subscriptions, checkout sessions, portal, webhook lifecycle
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { env } from "../../config/env.config.js";
import * as stripe from "../../services/billing.service.js";
import { deleteCache } from "../../services/redis.service.js";
import { publishEvent } from "../../services/kafka.service.js";
import { queueEmail } from "../../services/workers.js";
import { badRequest, notFound } from "../../middlewares/errorhandler.middleware.js";
import { KafkaTopics } from "../../config/constants.js";

const PLAN_PRICE_MAP = {
  PRO: env.STRIPE_PRO_PRICE_ID,
  ENTERPRISE: env.STRIPE_ENTERPRISE_PRICE_ID,
};

export async function getSubscription(userId) {
  const sub = await prisma.subscription.findUnique({
    where: { userId },
  });
  return sub || { plan: "FREE", status: "ACTIVE", userId };
}

export async function createCheckoutSession(userId, plan) {
  if (!PLAN_PRICE_MAP[plan]) throw badRequest("Invalid plan. Choose PRO or ENTERPRISE");

  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: { subscriptions: true },
  });
  if (!user) throw notFound("User not found");

  let stripeCustomerId = user.subscriptions?.stripeCustomerId;
  if (!stripeCustomerId) {
    const customer = await stripe.createCustomer({
      email: user.email,
      name: user.fullName,
      metadata: { userId },
    });
    stripeCustomerId = customer.id;
  }

  const session = await stripe.createCheckoutSession({
    customerId: stripeCustomerId,
    priceId: PLAN_PRICE_MAP[plan],
    successUrl: `${env.FRONTEND_URL}/billing/success?session_id={CHECKOUT_SESSION_ID}`,
    cancelUrl: `${env.FRONTEND_URL}/billing/cancel`,
    metadata: { userId, plan },
  });

  return { sessionId: session.id, url: session.url };
}

export async function createPortalSession(userId) {
  const sub = await prisma.subscription.findUnique({ where: { userId } });
  if (!sub?.stripeCustomerId) throw badRequest("No billing account found");

  const session = await stripe.createPortalSession(sub.stripeCustomerId, `${env.FRONTEND_URL}/billing`);
  return { url: session.url };
}

export async function cancelSubscription(userId) {
  const sub = await prisma.subscription.findUnique({ where: { userId } });
  if (!sub || sub.plan === "FREE") throw badRequest("No active paid subscription");
  if (!sub.stripeSubId) throw badRequest("No Stripe subscription found");

  await stripe.cancelSubscription(sub.stripeSubId);

  await prisma.subscription.update({
    where: { userId },
    data: { status: "CANCELLED", canceledAt: new Date() },
  });

  await deleteCache(`user:${userId}`);
  return { message: "Subscription will be canceled at period end" };
}

export async function handleWebhook(rawBody, signature) {
  const event = stripe.constructWebhookEvent(rawBody, signature);

  switch (event.type) {
    case "checkout.session.completed":
      await handleCheckoutComplete(event.data.object);
      break;
    case "customer.subscription.updated":
      await handleSubscriptionUpdated(event.data.object);
      break;
    case "customer.subscription.deleted":
      await handleSubscriptionDeleted(event.data.object);
      break;
    case "invoice.payment_succeeded":
      await handlePaymentSucceeded(event.data.object);
      break;
    case "invoice.payment_failed":
      await handlePaymentFailed(event.data.object);
      break;
  }
}

async function handleCheckoutComplete(session) {
  const { userId, plan } = session.metadata;
  if (!userId || !plan) return;

  const subscriptionData = await stripe.getSubscription(session.subscription);

  await prisma.subscription.upsert({
    where: { userId },
    create: {
      userId,
      plan,
      status: "ACTIVE",
      stripeSubId: session.subscription,
      stripeCustomerId: session.customer,
      currentPeriodStart: new Date(subscriptionData.current_period_start * 1000),
      currentPeriodEnd: new Date(subscriptionData.current_period_end * 1000),
    },
    update: {
      plan,
      status: "ACTIVE",
      stripeSubId: session.subscription,
      stripeCustomerId: session.customer,
      currentPeriodStart: new Date(subscriptionData.current_period_start * 1000),
      currentPeriodEnd: new Date(subscriptionData.current_period_end * 1000),
      canceledAt: null,
    },
  });

  await deleteCache(`user:${userId}`);

  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (user?.email) {
    await queueEmail("subscription-confirmed", user.email, {
      name: user.fullName,
      plan,
    });
  }

  await publishEvent(KafkaTopics.USER_EVENTS, userId, { type: "subscription.created", userId, plan });
}

async function handleSubscriptionUpdated(subscription) {
  const sub = await prisma.subscription.findFirst({
    where: { stripeSubId: subscription.id },
  });
  if (!sub) return;

  const statusMap = {
    active: "ACTIVE",
    past_due: "PAST_DUE",
    canceled: "CANCELLED",
    unpaid: "PAST_DUE",
  };

  await prisma.subscription.update({
    where: { id: sub.id },
    data: {
      status: statusMap[subscription.status] || sub.status,
      currentPeriodStart: new Date(subscription.current_period_start * 1000),
      currentPeriodEnd: new Date(subscription.current_period_end * 1000),
    },
  });

  await deleteCache(`user:${sub.userId}`);
}

async function handleSubscriptionDeleted(subscription) {
  const sub = await prisma.subscription.findFirst({
    where: { stripeSubId: subscription.id },
  });
  if (!sub) return;

  await prisma.subscription.update({
    where: { id: sub.id },
    data: { plan: "FREE", status: "ACTIVE", stripeSubId: null, canceledAt: new Date() },
  });

  await deleteCache(`user:${sub.userId}`);
  await publishEvent(KafkaTopics.USER_EVENTS, sub.userId, { type: "subscription.canceled", userId: sub.userId });
}

async function handlePaymentSucceeded(invoice) {
  if (!invoice.subscription) return;
  const sub = await prisma.subscription.findFirst({
    where: { stripeSubId: invoice.subscription },
    include: { user: { select: { email: true, fullName: true } } },
  });
  if (!sub?.user?.email) return;

  await queueEmail("payment-receipt", sub.user.email, {
    name: sub.user.fullName,
    amount: (invoice.amount_paid / 100).toFixed(2),
    currency: invoice.currency.toUpperCase(),
    invoiceUrl: invoice.hosted_invoice_url,
  });
}

async function handlePaymentFailed(invoice) {
  if (!invoice.subscription) return;
  const sub = await prisma.subscription.findFirst({
    where: { stripeSubId: invoice.subscription },
  });
  if (!sub) return;

  await prisma.subscription.update({
    where: { id: sub.id },
    data: { status: "PAST_DUE" },
  });

  await deleteCache(`user:${sub.userId}`);
}
