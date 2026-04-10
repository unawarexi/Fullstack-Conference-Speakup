// ============================================================================
// SpeakUp — Notification Routes
// ============================================================================

import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import * as ctrl from "./notification.controller.js";

const router = Router();

router.use(authenticate);

router.get("/", ctrl.getNotifications);
router.get("/unread-count", ctrl.getUnreadCount);
router.get("/preferences", ctrl.getPreferences);
router.put("/preferences", ctrl.updatePreferences);
router.put("/read-all", ctrl.markAllAsRead);
router.put("/:id/read", ctrl.markAsRead);
router.delete("/:id", ctrl.deleteNotification);

export default router;
