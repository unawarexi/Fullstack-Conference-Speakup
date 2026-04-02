// ============================================================================
// SpeakUp — Search Controller
// ============================================================================

import * as searchService from "./search.service.js";

export async function searchUsers(req, res, next) {
  try {
    const result = await searchService.searchUsers(req.query.q, req.query);
    res.json({ success: true, data: result });
  } catch (error) { next(error); }
}

export async function searchMeetings(req, res, next) {
  try {
    const result = await searchService.searchMeetings(req.user.id, req.query.q, req.query);
    res.json({ success: true, data: result });
  } catch (error) { next(error); }
}

export async function globalSearch(req, res, next) {
  try {
    const result = await searchService.globalSearch(req.user.id, req.query.q, req.query);
    res.json({ success: true, data: result });
  } catch (error) { next(error); }
}
