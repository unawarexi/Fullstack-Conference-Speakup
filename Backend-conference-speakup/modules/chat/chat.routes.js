// ============================================================================
// SpeakUp — Chat Routes
// ============================================================================

import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { validateBody } from "../../middlewares/validate.middleware.js";
import { chatMessageLimiter } from "../../middlewares/ratelimit.middleware.js";
import { sendMessageSchema } from "./chat.validator.js";
import * as ctrl from "./chat.controller.js";

const router = Router();

router.use(authenticate);

router.get("/rooms", ctrl.getChatRooms);
router.get("/meeting/:meetingId", ctrl.getOrCreateMeetingChat);
router.get("/:chatRoomId/messages", ctrl.getMessages);
router.post("/:chatRoomId/messages", chatMessageLimiter, validateBody(sendMessageSchema), ctrl.sendMessage);
router.delete("/messages/:messageId", ctrl.deleteMessage);

export default router;
