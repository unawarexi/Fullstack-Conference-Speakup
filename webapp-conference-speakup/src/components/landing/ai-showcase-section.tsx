"use client";

import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";
import {
  Brain,
  FileText,
  Lightbulb,
  MessageSquareQuote,
  Mic2,
  Workflow,
  Sparkles,
} from "lucide-react";
import {
  RevealOnScroll,
  GradientText,
  FloatingElement,
  StaggerContainer,
  StaggerItem,
} from "./motion-primitives";

const aiFeatures = [
  {
    icon: FileText,
    title: "Live Transcription",
    desc: "Every word captured in real-time with speaker identification, 40+ languages, and 99% accuracy.",
  },
  {
    icon: Lightbulb,
    title: "Smart Suggestions",
    desc: "AI surfaces talking points, questions, and insights as your meeting progresses.",
  },
  {
    icon: MessageSquareQuote,
    title: "Meeting Summaries",
    desc: "Auto-generated summaries with action items, decisions, and follow-ups after every meeting.",
  },
  {
    icon: Mic2,
    title: "Voice Commands",
    desc: "\"Hey SpeakUp, schedule a follow-up\" — natural language control for hands-free operation.",
  },
  {
    icon: Workflow,
    title: "Workflow Automation",
    desc: "Auto-create tasks in Jira, send notes to Slack, update CRM — all triggered by meeting events.",
  },
  {
    icon: Brain,
    title: "Emotion Intelligence",
    desc: "Real-time sentiment analysis helps you gauge the room and adjust your communication.",
  },
];

export function AIShowcaseSection() {
  const containerRef = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start end", "end start"],
  });
  const bgY = useTransform(scrollYProgress, [0, 1], ["0%", "20%"]);

  return (
    <section ref={containerRef} className="relative py-32 overflow-hidden bg-surface">
      {/* Animated gradient background */}
      <motion.div
        style={{ y: bgY }}
        className="absolute inset-0 bg-[radial-gradient(ellipse_at_top_right,_var(--primary)_0%,_transparent_50%)] opacity-[0.04]"
      />
      <motion.div
        style={{ y: bgY }}
        className="absolute inset-0 bg-[radial-gradient(ellipse_at_bottom_left,_#8B5CF6_0%,_transparent_50%)] opacity-[0.04]"
      />

      <div className="relative mx-auto max-w-7xl px-6">
        {/* Header */}
        <RevealOnScroll>
          <div className="text-center mb-20">
            <div className="inline-flex items-center gap-2 rounded-full border border-purple-500/20 bg-purple-500/5 px-4 py-1.5 text-sm font-medium text-purple-500 mb-6">
              <Sparkles className="h-4 w-4" />
              AI-Powered
            </div>
            <h2 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-text-primary tracking-tight">
              Your meetings,
              <br />
              <span className="bg-gradient-to-r from-purple-500 via-pink-500 to-orange-500 bg-clip-text text-transparent">
                supercharged by AI
              </span>
            </h2>
            <p className="mt-6 text-lg text-text-secondary max-w-2xl mx-auto">
              SpeakUp&apos;s AI doesn&apos;t just listen — it understands, summarizes,
              and acts on your behalf so you can focus on what matters.
            </p>
          </div>
        </RevealOnScroll>

        {/* AI Feature Cards */}
        <StaggerContainer className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3" staggerDelay={0.1}>
          {aiFeatures.map((feature) => (
            <StaggerItem key={feature.title}>
              <motion.div
                whileHover={{ y: -6 }}
                className="group relative rounded-3xl border border-border bg-card p-8 h-full overflow-hidden"
              >
                {/* Purple glow on hover */}
                <div className="absolute -inset-px rounded-3xl bg-gradient-to-br from-purple-500/20 via-pink-500/20 to-orange-500/20 opacity-0 group-hover:opacity-100 transition-opacity duration-500 -z-10 blur-sm" />

                <div className="mb-5 flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br from-purple-500/10 to-pink-500/10">
                  <feature.icon className="h-6 w-6 text-purple-500" />
                </div>
                <h3 className="text-lg font-bold text-text-primary mb-2">
                  {feature.title}
                </h3>
                <p className="text-sm text-text-secondary leading-relaxed">
                  {feature.desc}
                </p>
              </motion.div>
            </StaggerItem>
          ))}
        </StaggerContainer>

        {/* AI Demo mockup */}
        <RevealOnScroll delay={0.3}>
          <div className="mt-20 relative">
            <div className="mx-auto max-w-4xl rounded-3xl border border-border bg-card/80 backdrop-blur-xl p-8 shadow-2xl shadow-purple-500/5">
              {/* Browser chrome */}
              <div className="flex items-center gap-2 mb-6">
                <div className="flex gap-1.5">
                  <div className="w-3 h-3 rounded-full bg-error/60" />
                  <div className="w-3 h-3 rounded-full bg-warning/60" />
                  <div className="w-3 h-3 rounded-full bg-success/60" />
                </div>
                <div className="flex-1 mx-4 h-8 rounded-lg bg-elevated flex items-center px-4">
                  <span className="text-xs text-text-tertiary">speakup.app/meeting/spk-abc-1234</span>
                </div>
              </div>

              {/* Meeting mockup */}
              <div className="grid grid-cols-3 gap-4">
                {/* Video area */}
                <div className="col-span-2 space-y-4">
                  <div className="aspect-video rounded-2xl bg-elevated flex items-center justify-center">
                    <div className="text-center">
                      <div className="mx-auto w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center mb-3">
                        <Mic2 className="h-8 w-8 text-primary" />
                      </div>
                      <p className="text-sm font-medium text-text-primary">Team Standup</p>
                      <p className="text-xs text-text-tertiary">4 participants</p>
                    </div>
                  </div>
                </div>

                {/* AI sidebar */}
                <div className="space-y-3">
                  <div className="rounded-xl bg-elevated p-4">
                    <p className="text-xs font-semibold text-purple-500 mb-2 flex items-center gap-1">
                      <Sparkles className="h-3 w-3" /> AI Copilot
                    </p>
                    <div className="space-y-2">
                      <FloatingElement yOffset={2} duration={4}>
                        <div className="rounded-lg bg-purple-500/5 border border-purple-500/10 p-2">
                          <p className="text-[10px] text-text-secondary">
                            <span className="text-purple-500 font-medium">Suggestion:</span>{" "}
                            Ask about Q3 timeline
                          </p>
                        </div>
                      </FloatingElement>
                      <div className="rounded-lg bg-card p-2">
                        <p className="text-[10px] text-text-secondary">
                          <span className="text-green-500 font-medium">Action:</span>{" "}
                          Update design specs by Friday
                        </p>
                      </div>
                    </div>
                  </div>
                  <div className="rounded-xl bg-elevated p-4">
                    <p className="text-xs font-semibold text-blue-500 mb-2">Live Transcript</p>
                    <div className="space-y-1.5">
                      <p className="text-[10px] text-text-secondary">
                        <span className="font-medium text-text-primary">Sarah:</span> The new API is ready for review...
                      </p>
                      <p className="text-[10px] text-text-secondary">
                        <span className="font-medium text-text-primary">Mike:</span> Great, I&apos;ll review it today...
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </RevealOnScroll>
      </div>
    </section>
  );
}
