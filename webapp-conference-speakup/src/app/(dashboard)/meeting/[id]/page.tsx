"use client";

import { use } from "react";
import { useMeeting, useMeetingToken, useLeaveMeeting, useEndMeeting } from "@/hooks/use-meetings";
import { useMeetingStore } from "@/store/meeting-store";
import { useCurrentUser } from "@/hooks/use-auth";
import { Button, Avatar, AvatarGroup, Badge, Spinner, PageSpinner, Modal } from "@/components/ui";
import { formatTimer, formatParticipantCount } from "@/lib/formatters";
import {
  Mic,
  MicOff,
  Camera,
  CameraOff,
  Monitor,
  MonitorOff,
  Hand,
  PhoneOff,
  MessageSquare,
  Users,
  MoreVertical,
  Copy,
  Shield,
} from "lucide-react";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

export default function MeetingRoomPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const router = useRouter();
  const { data: meeting, isLoading } = useMeeting(id);
  const { data: token } = useMeetingToken(id);
  const { data: currentUser } = useCurrentUser();
  const { mutate: leaveMeeting } = useLeaveMeeting();
  const { mutate: endMeeting } = useEndMeeting();

  const {
    isMicOn, isCameraOn, isScreenSharing, isHandRaised,
    toggleMic, toggleCamera, toggleScreenShare, toggleHandRaise,
    elapsedSeconds, tick, setMeeting, reset,
  } = useMeetingStore();

  const [showParticipants, setShowParticipants] = useState(false);
  const [showChat, setShowChat] = useState(false);
  const [showEndModal, setShowEndModal] = useState(false);

  // Timer
  useEffect(() => {
    const interval = setInterval(tick, 1000);
    return () => clearInterval(interval);
  }, [tick]);

  // Set meeting data
  useEffect(() => {
    if (meeting) setMeeting(meeting);
  }, [meeting, setMeeting]);

  // Cleanup on unmount
  useEffect(() => {
    return () => reset();
  }, [reset]);

  const isHost = meeting?.host?.id === currentUser?.id;

  const handleLeave = () => {
    leaveMeeting(id, { onSuccess: () => router.push("/meetings") });
  };

  const handleEnd = () => {
    endMeeting(id, { onSuccess: () => router.push("/meetings") });
  };

  const copyCode = () => {
    if (meeting?.code) {
      navigator.clipboard.writeText(meeting.code);
      toast.success("Meeting code copied!");
    }
  };

  if (isLoading) return <PageSpinner />;

  return (
    <div className="flex h-full flex-col bg-[#0A0A0F]">
      {/* Top bar */}
      <div className="flex items-center justify-between px-4 py-3 bg-[#111118]">
        <div className="flex items-center gap-3">
          <h2 className="text-sm font-semibold text-white truncate max-w-[200px]">
            {meeting?.title}
          </h2>
          <Badge variant="error" className="text-[10px]">
            {formatTimer(elapsedSeconds)}
          </Badge>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={copyCode}
            className="flex items-center gap-1.5 rounded-lg bg-white/10 px-3 py-1.5 text-xs text-white/70 hover:bg-white/20 transition-colors"
          >
            <Copy className="h-3.5 w-3.5" />
            {meeting?.code}
          </button>
          <button
            onClick={() => setShowParticipants((v) => !v)}
            className="flex items-center gap-1.5 rounded-lg bg-white/10 px-3 py-1.5 text-xs text-white/70 hover:bg-white/20 transition-colors"
          >
            <Users className="h-3.5 w-3.5" />
            {formatParticipantCount(meeting?.participantCount ?? 0)}
          </button>
        </div>
      </div>

      {/* Video grid area */}
      <div className="flex flex-1 overflow-hidden">
        <div className="flex-1 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 p-4 auto-rows-fr">
          {/* Self-view tile */}
          <div className="relative rounded-2xl bg-[#1A1A24] overflow-hidden flex items-center justify-center border border-white/5">
            {isCameraOn ? (
              <div className="absolute inset-0 bg-gradient-to-br from-primary/20 to-transparent" />
            ) : (
              <Avatar
                name={currentUser?.name}
                src={currentUser?.avatar}
                size="xxl"
              />
            )}
            <div className="absolute bottom-3 left-3 flex items-center gap-2">
              <span className="rounded-lg bg-black/60 px-2 py-1 text-xs text-white">
                You {isHost && "(Host)"}
              </span>
              {!isMicOn && (
                <span className="rounded-full bg-error/80 p-1">
                  <MicOff className="h-3 w-3 text-white" />
                </span>
              )}
            </div>
          </div>

          {/* Participant placeholders */}
          {Array.from({ length: Math.min((meeting?.participantCount ?? 1) - 1, 8) }).map((_, i) => (
            <div
              key={i}
              className="relative rounded-2xl bg-[#1A1A24] overflow-hidden flex items-center justify-center border border-white/5"
            >
              <Avatar name={`Participant ${i + 1}`} size="xl" />
              <div className="absolute bottom-3 left-3">
                <span className="rounded-lg bg-black/60 px-2 py-1 text-xs text-white">
                  Participant {i + 1}
                </span>
              </div>
            </div>
          ))}
        </div>

        {/* Side panels */}
        {showParticipants && (
          <div className="w-80 border-l border-white/10 bg-[#111118] p-4 overflow-y-auto">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-semibold text-white">Participants</h3>
              <button onClick={() => setShowParticipants(false)} className="text-white/50 hover:text-white">
                ✕
              </button>
            </div>
            <p className="text-xs text-white/50">
              {formatParticipantCount(meeting?.participantCount ?? 0)} in this meeting
            </p>
          </div>
        )}

        {showChat && (
          <div className="w-80 border-l border-white/10 bg-[#111118] p-4 overflow-y-auto">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-semibold text-white">Chat</h3>
              <button onClick={() => setShowChat(false)} className="text-white/50 hover:text-white">
                ✕
              </button>
            </div>
            <p className="text-xs text-white/50">Meeting chat will appear here</p>
          </div>
        )}
      </div>

      {/* Control bar */}
      <div className="flex items-center justify-center gap-3 px-4 py-4 bg-[#111118]">
        <ControlButton
          icon={isMicOn ? Mic : MicOff}
          active={isMicOn}
          onClick={toggleMic}
          label={isMicOn ? "Mute" : "Unmute"}
        />
        <ControlButton
          icon={isCameraOn ? Camera : CameraOff}
          active={isCameraOn}
          onClick={toggleCamera}
          label={isCameraOn ? "Stop Video" : "Start Video"}
        />
        <ControlButton
          icon={isScreenSharing ? MonitorOff : Monitor}
          active={isScreenSharing}
          onClick={toggleScreenShare}
          label="Share Screen"
        />
        <ControlButton
          icon={Hand}
          active={isHandRaised}
          onClick={toggleHandRaise}
          label="Raise Hand"
          activeColor="bg-warning"
        />
        <ControlButton
          icon={MessageSquare}
          active={showChat}
          onClick={() => { setShowChat((v) => !v); setShowParticipants(false); }}
          label="Chat"
        />

        <div className="mx-2 h-8 w-px bg-white/10" />

        <button
          onClick={isHost ? () => setShowEndModal(true) : handleLeave}
          className="flex h-12 items-center gap-2 rounded-full bg-error px-6 text-sm font-medium text-white hover:bg-error/80 transition-colors"
        >
          <PhoneOff className="h-5 w-5" />
          {isHost ? "End" : "Leave"}
        </button>
      </div>

      {/* End meeting modal */}
      <Modal
        open={showEndModal}
        onClose={() => setShowEndModal(false)}
        title="End Meeting"
        description="This will end the meeting for all participants. Are you sure?"
        confirmLabel="End Meeting"
        onConfirm={handleEnd}
        danger
      />
    </div>
  );
}

function ControlButton({
  icon: Icon,
  active,
  onClick,
  label,
  activeColor,
}: {
  icon: React.ComponentType<{ className?: string }>;
  active: boolean;
  onClick: () => void;
  label: string;
  activeColor?: string;
}) {
  return (
    <button
      onClick={onClick}
      title={label}
      className={`flex h-12 w-12 items-center justify-center rounded-full transition-colors ${
        active
          ? activeColor ?? "bg-white/10 text-white"
          : "bg-white/5 text-white/50 hover:bg-white/10 hover:text-white"
      }`}
    >
      <Icon className="h-5 w-5" />
    </button>
  );
}
