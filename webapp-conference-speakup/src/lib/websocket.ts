import { io, Socket } from "socket.io-client";
import { auth } from "@/lib/firebase";
import { WS_BASE_URL } from "@/config/constants";

class WebSocketService {
  private static instance: WebSocketService;
  private socket: Socket | null = null;
  private reconnectAttempts = 0;
  private readonly maxReconnectAttempts = 10;

  private constructor() {}

  static getInstance(): WebSocketService {
    if (!WebSocketService.instance) {
      WebSocketService.instance = new WebSocketService();
    }
    return WebSocketService.instance;
  }

  async connect(): Promise<Socket> {
    if (this.socket?.connected) return this.socket;

    const user = auth?.currentUser;
    const token = user ? await user.getIdToken() : undefined;

    this.socket = io(WS_BASE_URL, {
      auth: { token },
      transports: ["websocket", "polling"],
      reconnection: true,
      reconnectionAttempts: this.maxReconnectAttempts,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 10000,
    });

    this.socket.on("connect", () => {
      this.reconnectAttempts = 0;
    });

    this.socket.on("disconnect", () => {
      this.reconnectAttempts++;
    });

    return this.socket;
  }

  disconnect() {
    this.socket?.disconnect();
    this.socket = null;
  }

  getSocket(): Socket | null {
    return this.socket;
  }

  // ─── Meeting events ───
  joinMeeting(meetingId: string) {
    this.socket?.emit("meeting:join", { meetingId });
  }
  leaveMeeting(meetingId: string) {
    this.socket?.emit("meeting:leave", { meetingId });
  }
  onParticipantJoined(cb: (data: unknown) => void) {
    this.socket?.on("meeting:participant-joined", cb);
  }
  onParticipantLeft(cb: (data: unknown) => void) {
    this.socket?.on("meeting:participant-left", cb);
  }
  onMeetingEnded(cb: () => void) {
    this.socket?.on("meeting:ended", cb);
  }

  // ─── Chat events ───
  joinChatRoom(chatRoomId: string) {
    this.socket?.emit("chat:join", { chatRoomId });
  }
  leaveChatRoom(chatRoomId: string) {
    this.socket?.emit("chat:leave", { chatRoomId });
  }
  sendMessage(chatRoomId: string, content: string, type = "text") {
    this.socket?.emit("chat:message", { chatRoomId, content, type });
  }
  onNewMessage(cb: (data: unknown) => void) {
    this.socket?.on("chat:new-message", cb);
  }
  onTyping(cb: (data: unknown) => void) {
    this.socket?.on("chat:typing", cb);
  }
  emitTyping(chatRoomId: string) {
    this.socket?.emit("chat:typing", { chatRoomId });
  }

  // ─── Notification events ───
  onNotification(cb: (data: unknown) => void) {
    this.socket?.on("notification:new", cb);
  }

  // ─── Generic listener ───
  on(event: string, cb: (data: unknown) => void) {
    this.socket?.on(event, cb);
  }
  off(event: string, cb?: (data: unknown) => void) {
    this.socket?.off(event, cb);
  }
}

export const ws = WebSocketService.getInstance();
