// ============================================================================
// SpeakUp — Room Controller
// ============================================================================

import * as roomService from "./room.service.js";

export async function getRoomState(req, res, next) {
  try {
    const state = await roomService.getRoomState(req.params.id, req.user.id);
    res.json({ success: true, data: state });
  } catch (error) { next(error); }
}

export async function updateRoomSettings(req, res, next) {
  try {
    const meeting = await roomService.updateRoomSettings(req.params.id, req.user.id, req.body);
    res.json({ success: true, data: { meeting } });
  } catch (error) { next(error); }
}

export async function muteAll(req, res, next) {
  try {
    await roomService.muteAllParticipants(req.params.id, req.user.id);
    res.json({ success: true, message: "All participants muted" });
  } catch (error) { next(error); }
}

export async function getActiveRooms(req, res, next) {
  try {
    const rooms = await roomService.getActiveRooms(req.user.id);
    res.json({ success: true, data: { rooms } });
  } catch (error) { next(error); }
}
