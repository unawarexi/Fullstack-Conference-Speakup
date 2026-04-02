// ============================================================================
// SpeakUp — Analytics Routes
// ============================================================================

import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { validateQuery } from "../../middlewares/validate.middleware.js";
import { usageQuerySchema } from "./analytics.validator.js";
import * as ctrl from "./analytics.controller.js";

const router = Router();

router.use(authenticate);

router.get("/dashboard", ctrl.getDashboard);
router.get("/usage", validateQuery(usageQuerySchema), ctrl.getUserUsage);
router.get("/meeting/:meetingId", ctrl.getMeetingAnalytics);

export default router;
