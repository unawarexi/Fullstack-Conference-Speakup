// ============================================================================
// SpeakUp — Recording Controller
// ============================================================================

import * as recordingService from "./recording.service.js";
import { HttpStatus } from "../../config/constants.js";

export async function startRecording(req, res, next) {
  try {
    const recording = await recordingService.startRecording(req.params.meetingId, req.user.id);
    res.status(HttpStatus.CREATED).json({ success: true, data: { recording } });
  } catch (error) { next(error); }
}

export async function stopRecording(req, res, next) {
  try {
    const recording = await recordingService.stopRecording(req.params.meetingId, req.user.id);
    res.json({ success: true, data: { recording } });
  } catch (error) { next(error); }
}

export async function getRecordings(req, res, next) {
  try {
    const result = await recordingService.getRecordings(req.user.id, req.query);
    res.json({ success: true, data: result });
  } catch (error) { next(error); }
}

export async function getRecording(req, res, next) {
  try {
    const recording = await recordingService.getRecording(req.params.id, req.user.id);
    res.json({ success: true, data: { recording } });
  } catch (error) { next(error); }
}

export async function downloadRecording(req, res, next) {
  try {
    const data = await recordingService.getDownloadUrl(req.params.id, req.user.id);
    res.json({ success: true, data });
  } catch (error) { next(error); }
}

export async function deleteRecording(req, res, next) {
  try {
    await recordingService.deleteRecording(req.params.id, req.user.id);
    res.json({ success: true, message: "Recording deleted" });
  } catch (error) { next(error); }
}

export async function webhookRecordingComplete(req, res, next) {
  try {
    const { recordingId, fileUrl, fileSize, duration } = req.body;
    await recordingService.handleRecordingComplete(recordingId, { fileUrl, fileSize, duration });
    res.json({ success: true });
  } catch (error) { next(error); }
}
