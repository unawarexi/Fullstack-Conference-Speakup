// ============================================================================
// SpeakUp — Recording Routes
// ============================================================================

import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { validateBody } from "../../middlewares/validate.middleware.js";
import { recordingLimiter } from "../../middlewares/ratelimit.middleware.js";
import { recordingWebhookSchema } from "./recording.validator.js";
import * as ctrl from "./recording.controller.js";

const router = Router();

// Internal webhook (called by LiveKit/processing pipeline, not user-facing)
router.post("/webhook/complete", validateBody(recordingWebhookSchema), ctrl.webhookRecordingComplete);

// User routes
router.use(authenticate);

router.get("/", ctrl.getRecordings);
router.get("/:id", ctrl.getRecording);
router.get("/:id/download", ctrl.downloadRecording);
router.delete("/:id", ctrl.deleteRecording);
router.post("/meeting/:meetingId/start", recordingLimiter, ctrl.startRecording);
router.post("/meeting/:meetingId/stop", ctrl.stopRecording);

export default router;
