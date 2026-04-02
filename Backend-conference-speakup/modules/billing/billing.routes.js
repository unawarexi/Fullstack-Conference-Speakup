// ============================================================================
// SpeakUp — Billing Routes
// ============================================================================

import { Router } from "express";
import express from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { validateBody } from "../../middlewares/validate.middleware.js";
import { billingLimiter } from "../../middlewares/ratelimit.middleware.js";
import { createCheckoutSchema } from "./billing.validator.js";
import * as ctrl from "./billing.controller.js";

const router = Router();

// Stripe webhook needs raw body — must be registered BEFORE json middleware
router.post("/webhook", express.raw({ type: "application/json" }), ctrl.stripeWebhook);

// User routes
router.use(authenticate);

router.get("/subscription", ctrl.getSubscription);
router.post("/checkout", billingLimiter, validateBody(createCheckoutSchema), ctrl.createCheckout);
router.post("/portal", ctrl.createPortal);
router.post("/cancel", ctrl.cancelSubscription);

export default router;
