// ============================================================================
// SpeakUp — Legal Routes
// Public endpoints for Terms of Service and Privacy Policy
// ============================================================================

import { Router } from "express";
import * as controller from "./legal.controller.js";

const router = Router();

// Public routes — no authentication required
router.get("/terms", controller.getTermsOfService);
router.get("/privacy", controller.getPrivacyPolicy);
router.get("/all", controller.getAllLegalDocuments);

export default router;
