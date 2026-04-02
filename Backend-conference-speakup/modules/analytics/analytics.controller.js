// ============================================================================
// SpeakUp — Analytics Controller
// ============================================================================

import * as analyticsService from "./analytics.service.js";
import { notFound } from "../../middlewares/errorhandler.middleware.js";

export async function getMeetingAnalytics(req, res, next) {
  try {
    const analytics = await analyticsService.getMeetingAnalytics(req.params.meetingId, req.user.id);
    if (!analytics) throw notFound("Meeting not found or access denied");
    res.json({ success: true, data: analytics });
  } catch (error) { next(error); }
}

export async function getUserUsage(req, res, next) {
  try {
    const usage = await analyticsService.getUserUsage(req.user.id, req.query);
    res.json({ success: true, data: usage });
  } catch (error) { next(error); }
}

export async function getDashboard(req, res, next) {
  try {
    const dashboard = await analyticsService.getDashboard(req.user.id);
    res.json({ success: true, data: dashboard });
  } catch (error) { next(error); }
}
