// ============================================================================
// SpeakUp — Room Routes
// ============================================================================

import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { validateBody } from "../../middlewares/validate.middleware.js";
import { updateRoomSettingsSchema } from "./room.validator.js";
import * as ctrl from "./room.controller.js";

const router = Router();

router.use(authenticate);

router.get("/active", ctrl.getActiveRooms);
router.get("/:id", ctrl.getRoomState);
router.put("/:id/settings", validateBody(updateRoomSettingsSchema), ctrl.updateRoomSettings);
router.post("/:id/mute-all", ctrl.muteAll);

export default router;
