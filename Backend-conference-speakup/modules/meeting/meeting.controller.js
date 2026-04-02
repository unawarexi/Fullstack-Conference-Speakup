// ============================================================================
// SpeakUp — Meeting Controller
// ============================================================================

import * as meetingService from "./meeting.service.js";
import { HttpStatus } from "../../config/constants.js";

export async function createMeeting(req, res, next) {
  try {
    const meeting = await meetingService.createMeeting(req.user.id, req.body);
    res.status(HttpStatus.CREATED).json({ success: true, data: { meeting } });
  } catch (error) { next(error); }
}

export async function listMeetings(req, res, next) {
  try {
    const { page, limit, status } = req.query;
    const result = await meetingService.listUserMeetings(req.user.id, {
      page: parseInt(page) || 1,
      limit: Math.min(parseInt(limit) || 20, 100),
      status,
    });
    res.json({ success: true, data: result });
  } catch (error) { next(error); }
}

export async function getMeeting(req, res, next) {
  try {
    const meeting = await meetingService.getMeetingById(req.params.id, req.user.id);
    res.json({ success: true, data: { meeting } });
  } catch (error) { next(error); }
}

export async function updateMeeting(req, res, next) {
  try {
    const meeting = await meetingService.updateMeeting(req.params.id, req.user.id, req.body);
    res.json({ success: true, data: { meeting } });
  } catch (error) { next(error); }
}

export async function deleteMeeting(req, res, next) {
  try {
    await meetingService.deleteMeeting(req.params.id, req.user.id);
    res.json({ success: true, message: "Meeting deleted" });
  } catch (error) { next(error); }
}

export async function joinMeeting(req, res, next) {
  try {
    const participant = await meetingService.joinMeeting(req.params.id, req.user.id, req.body.password);
    res.status(HttpStatus.CREATED).json({ success: true, data: { participant } });
  } catch (error) { next(error); }
}

export async function leaveMeeting(req, res, next) {
  try {
    await meetingService.leaveMeeting(req.params.id, req.user.id);
    res.json({ success: true, message: "Left meeting" });
  } catch (error) { next(error); }
}

export async function endMeeting(req, res, next) {
  try {
    await meetingService.endMeeting(req.params.id, req.user.id);
    res.json({ success: true, message: "Meeting ended" });
  } catch (error) { next(error); }
}

export async function lockMeeting(req, res, next) {
  try {
    await meetingService.lockMeeting(req.params.id, req.user.id);
    res.json({ success: true, message: "Meeting locked" });
  } catch (error) { next(error); }
}

export async function unlockMeeting(req, res, next) {
  try {
    await meetingService.unlockMeeting(req.params.id, req.user.id);
    res.json({ success: true, message: "Meeting unlocked" });
  } catch (error) { next(error); }
}

export async function getParticipants(req, res, next) {
  try {
    const participants = await meetingService.getParticipants(req.params.id);
    res.json({ success: true, data: { participants } });
  } catch (error) { next(error); }
}

export async function kickParticipant(req, res, next) {
  try {
    await meetingService.kickParticipant(req.params.id, req.user.id, req.params.participantId);
    res.json({ success: true, message: "Participant removed" });
  } catch (error) { next(error); }
}

export async function joinByCode(req, res, next) {
  try {
    const meeting = await meetingService.getMeetingByCode(req.params.code);
    const participant = await meetingService.joinMeeting(meeting.id, req.user.id, req.query.password);
    res.status(HttpStatus.CREATED).json({ success: true, data: { meeting, participant } });
  } catch (error) { next(error); }
}

export async function getLiveKitToken(req, res, next) {
  try {
    const data = await meetingService.generateLiveKitToken(req.params.id, req.user.id);
    res.json({ success: true, data });
  } catch (error) { next(error); }
}
