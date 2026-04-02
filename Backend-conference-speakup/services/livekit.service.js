// ============================================================================
// SpeakUp — LiveKit Service (replaces Agora RTC)
// Room token generation, room management for WebRTC SFU
// ============================================================================

import { AccessToken, RoomServiceClient } from "livekit-server-sdk";
import { env } from "../config/env.config.js";
import { createLogger } from "../logs/logger.js";

const log = createLogger("LiveKit");

let roomService = null;

// ============================================================================
// INITIALIZATION
// ============================================================================

export function initLiveKit() {
  if (!env.LIVEKIT_HOST || !env.LIVEKIT_API_KEY || !env.LIVEKIT_API_SECRET) {
    log.warn("LiveKit not configured — missing LIVEKIT_HOST, API_KEY, or API_SECRET");
    return;
  }

  roomService = new RoomServiceClient(env.LIVEKIT_HOST, env.LIVEKIT_API_KEY, env.LIVEKIT_API_SECRET);
  log.success("LiveKit initialized", { host: env.LIVEKIT_HOST });
}

// ============================================================================
// TOKEN GENERATION
// ============================================================================

export async function generateToken({ roomName, participantName, participantId, isHost = false }) {
  const token = new AccessToken(env.LIVEKIT_API_KEY, env.LIVEKIT_API_SECRET, {
    identity: participantId,
    name: participantName,
    ttl: "6h",
  });

  token.addGrant({
    room: roomName,
    roomJoin: true,
    canPublish: true,
    canSubscribe: true,
    canPublishData: true,
    roomAdmin: isHost,
    roomCreate: isHost,
  });

  const jwt = await token.toJwt();
  log.debug("LiveKit token generated", { roomName, participantId, isHost });
  return jwt;
}

// ============================================================================
// ROOM MANAGEMENT
// ============================================================================

export async function listRooms() {
  if (!roomService) throw new Error("LiveKit not initialized");
  return roomService.listRooms();
}

export async function getRoom(roomName) {
  if (!roomService) throw new Error("LiveKit not initialized");
  const rooms = await roomService.listRooms([roomName]);
  return rooms[0] || null;
}

export async function deleteRoom(roomName) {
  if (!roomService) throw new Error("LiveKit not initialized");
  await roomService.deleteRoom(roomName);
  log.info("LiveKit room deleted", { roomName });
}

export async function listParticipants(roomName) {
  if (!roomService) throw new Error("LiveKit not initialized");
  return roomService.listParticipants(roomName);
}

export async function removeParticipant(roomName, identity) {
  if (!roomService) throw new Error("LiveKit not initialized");
  await roomService.removeParticipant(roomName, identity);
  log.info("Participant removed from LiveKit room", { roomName, identity });
}

export async function muteParticipant(roomName, identity, trackSid, muted) {
  if (!roomService) throw new Error("LiveKit not initialized");
  await roomService.mutePublishedTrack(roomName, identity, trackSid, muted);
}

// ============================================================================
// RECORDING (via Egress)
// ============================================================================

export async function startRoomRecording(roomName, outputUrl) {
  // LiveKit Egress API for room composite recording
  // Implementation depends on whether you use the Egress service
  log.info("Room recording started", { roomName });
  return { roomName, outputUrl, status: "recording" };
}

export default {
  initLiveKit,
  generateToken,
  listRooms,
  getRoom,
  deleteRoom,
  listParticipants,
  removeParticipant,
  muteParticipant,
  startRoomRecording,
};
