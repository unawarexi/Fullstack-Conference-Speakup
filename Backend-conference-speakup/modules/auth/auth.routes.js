import { Router } from "express";
import * as controller from "./auth.controller.js";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { authLimiter } from "../../middlewares/ratelimit.middleware.js";

const router = Router();

router.post("/signin", authLimiter, authenticate, controller.signIn);
router.post("/signout", authenticate, controller.signOut);
router.get("/me", authenticate, controller.getMe);
router.delete("/account", authenticate, controller.deleteAccount);

export default router;
