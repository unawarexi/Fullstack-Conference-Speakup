// ============================================================================
// SpeakUp — Meeting Routes
// ============================================================================

import { Router } from "express";
import multer from "multer";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { validateBody, validateQuery } from "../../middlewares/validate.middleware.js";
import { meetingCreateLimiter, meetingJoinLimiter, uploadLimiter } from "../../middlewares/ratelimit.middleware.js";
import { createMeetingSchema, updateMeetingSchema, joinMeetingSchema } from "./meeting.validator.js";
import * as ctrl from "./meeting.controller.js";

const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 20 * 1024 * 1024 } });
const router = Router();

router.use(authenticate);

router.post("/", meetingCreateLimiter, validateBody(createMeetingSchema), ctrl.createMeeting);
router.get("/", ctrl.listMeetings);
router.get("/join/:code", meetingJoinLimiter, ctrl.joinByCode);
router.get("/:id", ctrl.getMeeting);
router.put("/:id", validateBody(updateMeetingSchema), ctrl.updateMeeting);
router.delete("/:id", ctrl.deleteMeeting);
router.post("/:id/join", meetingJoinLimiter, validateBody(joinMeetingSchema), ctrl.joinMeeting);
router.post("/:id/leave", ctrl.leaveMeeting);
router.post("/:id/end", ctrl.endMeeting);
router.post("/:id/lock", ctrl.lockMeeting);
router.post("/:id/unlock", ctrl.unlockMeeting);
router.get("/:id/participants", ctrl.getParticipants);
router.post("/:id/kick/:participantId", ctrl.kickParticipant);
router.get("/:id/token", ctrl.getLiveKitToken);
router.get("/:id/invites", ctrl.getMeetingInvites);
router.post("/invite/:token/respond", ctrl.respondToInvite);

// ── Materials ──
router.post("/:id/materials", uploadLimiter, upload.single("file"), ctrl.uploadMaterial);
router.get("/:id/materials", ctrl.getMeetingMaterials);
router.get("/materials/:materialId", ctrl.getMaterial);
router.delete("/materials/:materialId", ctrl.deleteMaterial);

export default router;
