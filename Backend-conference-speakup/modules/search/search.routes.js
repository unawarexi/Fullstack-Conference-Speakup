// ============================================================================
// SpeakUp — Search Routes
// ============================================================================

import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { validateQuery } from "../../middlewares/validate.middleware.js";
import { searchQuerySchema } from "./search.validator.js";
import * as ctrl from "./search.controller.js";

const router = Router();

router.use(authenticate);

router.get("/", validateQuery(searchQuerySchema), ctrl.globalSearch);
router.get("/users", validateQuery(searchQuerySchema), ctrl.searchUsers);
router.get("/meetings", validateQuery(searchQuerySchema), ctrl.searchMeetings);

export default router;
