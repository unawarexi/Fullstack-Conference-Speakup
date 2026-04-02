// ============================================================================
// SpeakUp — Billing Service
// Stripe integration for subscriptions and payments
// ============================================================================

import Stripe from "stripe";
import { env } from "../config/env.config.js";
import { createLogger } from "../logs/logger.js";

const log = createLogger("Billing");

let stripe = null;

// ============================================================================
// INITIALIZATION
// ============================================================================

export function initBilling() {
  if (!env.STRIPE_SECRET_KEY) {
    log.warn("Stripe not configured — missing STRIPE_SECRET_KEY");
    return;
  }

  stripe = new Stripe(env.STRIPE_SECRET_KEY, { apiVersion: "2024-12-18.acacia" });
  log.success("Stripe initialized");
}

// ============================================================================
// CUSTOMERS
// ============================================================================

export async function createCustomer({ email, name, userId }) {
  if (!stripe) throw new Error("Stripe not initialized");

  const customer = await stripe.customers.create({
    email,
    name,
    metadata: { userId },
  });

  log.info("Stripe customer created", { customerId: customer.id, userId });
  return customer;
}

export async function getCustomer(customerId) {
  if (!stripe) throw new Error("Stripe not initialized");
  return stripe.customers.retrieve(customerId);
}

// ============================================================================
// SUBSCRIPTIONS
// ============================================================================

export async function createSubscription(customerId, priceId) {
  if (!stripe) throw new Error("Stripe not initialized");

  const subscription = await stripe.subscriptions.create({
    customer: customerId,
    items: [{ price: priceId }],
    payment_behavior: "default_incomplete",
    expand: ["latest_invoice.payment_intent"],
  });

  log.info("Subscription created", { subscriptionId: subscription.id, customerId });
  return subscription;
}

export async function cancelSubscription(subscriptionId) {
  if (!stripe) throw new Error("Stripe not initialized");

  const subscription = await stripe.subscriptions.cancel(subscriptionId);
  log.info("Subscription cancelled", { subscriptionId });
  return subscription;
}

export async function getSubscription(subscriptionId) {
  if (!stripe) throw new Error("Stripe not initialized");
  return stripe.subscriptions.retrieve(subscriptionId);
}

// ============================================================================
// CHECKOUT SESSION
// ============================================================================

export async function createCheckoutSession({ customerId, priceId, successUrl, cancelUrl, metadata = {} }) {
  if (!stripe) throw new Error("Stripe not initialized");

  const session = await stripe.checkout.sessions.create({
    customer: customerId,
    payment_method_types: ["card"],
    line_items: [{ price: priceId, quantity: 1 }],
    mode: "subscription",
    success_url: successUrl,
    cancel_url: cancelUrl,
    metadata,
  });

  return session;
}

// ============================================================================
// WEBHOOK VERIFICATION
// ============================================================================

export function constructWebhookEvent(body, signature) {
  if (!stripe) throw new Error("Stripe not initialized");
  return stripe.webhooks.constructEvent(body, signature, env.STRIPE_WEBHOOK_SECRET);
}

// ============================================================================
// BILLING PORTAL
// ============================================================================

export async function createPortalSession(customerId, returnUrl) {
  if (!stripe) throw new Error("Stripe not initialized");

  return stripe.billingPortal.sessions.create({
    customer: customerId,
    return_url: returnUrl,
  });
}

export default {
  initBilling,
  createCustomer,
  getCustomer,
  createSubscription,
  cancelSubscription,
  getSubscription,
  createCheckoutSession,
  constructWebhookEvent,
  createPortalSession,
};
