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
    const result = await meetingService.leaveMeeting(req.params.id, req.user.id);
    res.json({ success: true, message: "Left meeting", data: { autoEnded: result?.autoEnded || false } });
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
    const { ban, reason } = req.body || {};
    await meetingService.kickParticipant(req.params.id, req.user.id, req.params.participantId, { ban: !!ban, reason });
    res.json({ success: true, message: ban ? "Participant banned" : "Participant removed" });
  } catch (error) { next(error); }
}

export async function banParticipant(req, res, next) {
  try {
    const ban = await meetingService.banParticipant(req.params.id, req.user.id, req.params.userId, req.body?.reason);
    res.json({ success: true, data: { ban } });
  } catch (error) { next(error); }
}

export async function unbanParticipant(req, res, next) {
  try {
    await meetingService.unbanParticipant(req.params.id, req.user.id, req.params.userId);
    res.json({ success: true, message: "Participant unbanned" });
  } catch (error) { next(error); }
}

export async function getMeetingBans(req, res, next) {
  try {
    const bans = await meetingService.getMeetingBans(req.params.id);
    res.json({ success: true, data: { bans } });
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

export async function respondToInvite(req, res, next) {
  try {
    const result = await meetingService.respondToInvite(req.params.token, req.user?.id, req.body.response);
    res.json({ success: true, data: result });
  } catch (error) { next(error); }
}

export async function getMeetingInvites(req, res, next) {
  try {
    const invites = await meetingService.getMeetingInvites(req.params.id, req.user.id);
    res.json({ success: true, data: { invites } });
  } catch (error) { next(error); }
}

// ── Material Controllers ──

export async function uploadMaterial(req, res, next) {
  try {
    if (!req.file?.buffer) {
      return res.status(400).json({ success: false, message: "No file provided" });
    }
    const material = await meetingService.uploadMaterial(req.params.id, req.user.id, req.file);
    res.status(201).json({ success: true, data: { material } });
  } catch (error) { next(error); }
}

export async function getMeetingMaterials(req, res, next) {
  try {
    const materials = await meetingService.getMeetingMaterials(req.params.id, req.user.id);
    res.json({ success: true, data: { materials } });
  } catch (error) { next(error); }
}

export async function getMaterial(req, res, next) {
  try {
    const material = await meetingService.getMaterialById(req.params.materialId, req.user.id);
    res.json({ success: true, data: { material } });
  } catch (error) { next(error); }
}

export async function deleteMaterial(req, res, next) {
  try {
    await meetingService.deleteMaterial(req.params.materialId, req.user.id);
    res.json({ success: true, message: "Material deleted" });
  } catch (error) { next(error); }
}

export async function recreateMeeting(req, res, next) {
  try {
    const meeting = await meetingService.recreateMeeting(req.params.id, req.user.id, req.body);
    res.status(HttpStatus.CREATED).json({ success: true, data: { meeting } });
  } catch (error) { next(error); }
}
