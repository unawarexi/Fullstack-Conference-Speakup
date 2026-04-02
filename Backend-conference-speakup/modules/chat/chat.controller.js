// ============================================================================
// SpeakUp — Chat Controller
// ============================================================================

import * as chatService from "./chat.service.js";
import { HttpStatus } from "../../config/constants.js";

export async function getChatRooms(req, res, next) {
  try {
    const result = await chatService.getChatRooms(req.user.id, req.query);
    res.json({ success: true, data: result });
  } catch (error) { next(error); }
}

export async function getOrCreateMeetingChat(req, res, next) {
  try {
    const chatRoom = await chatService.getOrCreateMeetingChat(req.params.meetingId, req.user.id);
    res.json({ success: true, data: { chatRoom } });
  } catch (error) { next(error); }
}

export async function getMessages(req, res, next) {
  try {
    const result = await chatService.getMessages(req.params.chatRoomId, req.user.id, req.query);
    res.json({ success: true, data: result });
  } catch (error) { next(error); }
}

export async function sendMessage(req, res, next) {
  try {
    const message = await chatService.sendMessage(req.params.chatRoomId, req.user.id, req.body);
    res.status(HttpStatus.CREATED).json({ success: true, data: { message } });
  } catch (error) { next(error); }
}

export async function deleteMessage(req, res, next) {
  try {
    await chatService.deleteMessage(req.params.messageId, req.user.id);
    res.json({ success: true, message: "Message deleted" });
  } catch (error) { next(error); }
}
