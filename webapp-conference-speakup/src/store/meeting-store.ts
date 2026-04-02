import { create } from "zustand";
import type { Meeting, Participant, MeetingRoomState } from "@/types";

interface MeetingStore extends MeetingRoomState {
  // Actions
  setMeeting: (meeting: Meeting) => void;
  setParticipants: (participants: Participant[]) => void;
  addParticipant: (participant: Participant) => void;
  removeParticipant: (id: string) => void;
  toggleMic: () => void;
  toggleCamera: () => void;
  toggleScreenShare: () => void;
  toggleHandRaise: () => void;
  toggleRecording: () => void;
  tick: () => void;
  reset: () => void;
}

const initialState: MeetingRoomState = {
  meeting: null,
  participants: [],
  isMicOn: true,
  isCameraOn: true,
  isScreenSharing: false,
  isHandRaised: false,
  isRecording: false,
  elapsedSeconds: 0,
};

export const useMeetingStore = create<MeetingStore>()((set) => ({
  ...initialState,

  setMeeting: (meeting) => set({ meeting }),
  setParticipants: (participants) => set({ participants }),
  addParticipant: (participant) =>
    set((s) => ({ participants: [...s.participants, participant] })),
  removeParticipant: (id) =>
    set((s) => ({
      participants: s.participants.filter((p) => p.id !== id),
    })),

  toggleMic: () => set((s) => ({ isMicOn: !s.isMicOn })),
  toggleCamera: () => set((s) => ({ isCameraOn: !s.isCameraOn })),
  toggleScreenShare: () => set((s) => ({ isScreenSharing: !s.isScreenSharing })),
  toggleHandRaise: () => set((s) => ({ isHandRaised: !s.isHandRaised })),
  toggleRecording: () => set((s) => ({ isRecording: !s.isRecording })),
  tick: () => set((s) => ({ elapsedSeconds: s.elapsedSeconds + 1 })),
  reset: () => set(initialState),
}));
