// ============================================================================
// SpeakUp — Billing Controller
// ============================================================================

import * as billingService from "./billing.service.js";

export async function getSubscription(req, res, next) {
  try {
    const subscription = await billingService.getSubscription(req.user.id);
    res.json({ success: true, data: { subscription } });
  } catch (error) { next(error); }
}

export async function createCheckout(req, res, next) {
  try {
    const data = await billingService.createCheckoutSession(req.user.id, req.body.plan);
    res.json({ success: true, data });
  } catch (error) { next(error); }
}

export async function createPortal(req, res, next) {
  try {
    const data = await billingService.createPortalSession(req.user.id);
    res.json({ success: true, data });
  } catch (error) { next(error); }
}

export async function cancelSubscription(req, res, next) {
  try {
    const data = await billingService.cancelSubscription(req.user.id);
    res.json({ success: true, data });
  } catch (error) { next(error); }
}

export async function stripeWebhook(req, res, next) {
  try {
    await billingService.handleWebhook(req.body, req.headers["stripe-signature"]);
    res.json({ received: true });
  } catch (error) { next(error); }
}
