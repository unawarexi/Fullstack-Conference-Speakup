import { Router } from "express";
import multer from "multer";
import * as controller from "./user.controller.js";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { validateBody } from "../../middlewares/validate.middleware.js";
import { updateProfileSchema, registerDeviceSchema } from "./user.validator.js";
import { uploadLimiter } from "../../middlewares/ratelimit.middleware.js";

const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 5 * 1024 * 1024 } });
const router = Router();

router.get("/profile", authenticate, controller.getProfile);
router.put("/profile", authenticate, validateBody(updateProfileSchema), controller.updateProfile);
router.put("/avatar", authenticate, uploadLimiter, upload.single("avatar"), controller.updateAvatar);
router.get("/devices", authenticate, controller.getDevices);
router.post("/devices", authenticate, validateBody(registerDeviceSchema), controller.registerDevice);
router.delete("/devices/:deviceId", authenticate, controller.removeDevice);
router.put("/online-status", authenticate, controller.updateOnlineStatus);

export default router;
