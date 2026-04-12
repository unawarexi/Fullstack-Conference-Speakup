"use client";

import { motion } from "framer-motion";
import {
  Video,
  Monitor,
  MessageSquare,
  Calendar,
  Shield,
  Users,
  Brain,
  Mic,
  BarChart3,
  Globe,
  Zap,
  Lock,
} from "lucide-react";
import {
  RevealOnScroll,
  StaggerContainer,
  StaggerItem,
  GradientText,
  ParallaxSection,
} from "./motion-primitives";

const features = [
  {
    icon: Video,
    title: "4K Video Calls",
    description: "Crystal-clear video with adaptive bitrate streaming. Auto-adjusts quality based on your connection for the smoothest experience.",
    color: "from-blue-500 to-cyan-500",
    bg: "bg-blue-500/10",
  },
  {
    icon: Brain,
    title: "AI Copilot",
    description: "Real-time meeting transcription, smart suggestions, action items extraction, and post-meeting summaries — all powered by AI.",
    color: "from-purple-500 to-pink-500",
    bg: "bg-purple-500/10",
  },
  {
    icon: Monitor,
    title: "Screen Sharing",
    description: "Share your entire screen, application windows, or individual tabs with ultra-low latency and full annotation tools.",
    color: "from-green-500 to-emerald-500",
    bg: "bg-green-500/10",
  },
  {
    icon: MessageSquare,
    title: "Real-Time Chat",
    description: "Persistent meeting chat with threads, reactions, file sharing, and smart notifications. Works during and after meetings.",
    color: "from-orange-500 to-amber-500",
    bg: "bg-orange-500/10",
  },
  {
    icon: Calendar,
    title: "Smart Scheduling",
    description: "AI-powered scheduling that finds the perfect time for everyone. Integrates with Google Calendar, Outlook, and Apple Calendar.",
    color: "from-pink-500 to-rose-500",
    bg: "bg-pink-500/10",
  },
  {
    icon: Shield,
    title: "Enterprise Security",
    description: "End-to-end encryption, SSO/SAML, SOC 2 Type II compliant, and granular admin controls for complete peace of mind.",
    color: "from-indigo-500 to-violet-500",
    bg: "bg-indigo-500/10",
  },
  {
    icon: Mic,
    title: "Voice Assistant",
    description: "Control meetings with your voice — schedule, record, mute, and navigate hands-free with natural language commands.",
    color: "from-teal-500 to-cyan-500",
    bg: "bg-teal-500/10",
  },
  {
    icon: BarChart3,
    title: "Analytics Dashboard",
    description: "Track meeting quality, participant engagement, talk-time distribution, and team productivity metrics in real-time.",
    color: "from-amber-500 to-yellow-500",
    bg: "bg-amber-500/10",
  },
  {
    icon: Globe,
    title: "Global Infrastructure",
    description: "Servers across 6 continents with sub-100ms latency. Automatic region selection ensures the best connection everywhere.",
    color: "from-red-500 to-orange-500",
    bg: "bg-red-500/10",
  },
];

export function FeaturesSection() {
  return (
    <section id="features" className="relative py-32 overflow-hidden">
      {/* Background grid pattern */}
      <div className="absolute inset-0 bg-[linear-gradient(to_right,var(--border)_1px,transparent_1px),linear-gradient(to_bottom,var(--border)_1px,transparent_1px)] bg-[size:64px_64px] opacity-30" />

      <div className="relative mx-auto max-w-7xl px-6">
        {/* Section Header */}
        <RevealOnScroll>
          <div className="text-center mb-20">
            <div className="inline-flex items-center gap-2 rounded-full border border-primary/20 bg-primary/5 px-4 py-1.5 text-sm font-medium text-primary mb-6">
              <Zap className="h-4 w-4" />
              Powerful Features
            </div>
            <h2 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-text-primary tracking-tight">
              Everything you need,
              <br />
              <GradientText>nothing you don&apos;t</GradientText>
            </h2>
            <p className="mt-6 text-lg text-text-secondary max-w-2xl mx-auto">
              Built for modern teams who demand the best. Every feature designed
              to eliminate friction and amplify collaboration.
            </p>
          </div>
        </RevealOnScroll>

        {/* Feature Grid */}
        <StaggerContainer className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3" staggerDelay={0.08}>
          {features.map((feature, i) => (
            <StaggerItem key={feature.title}>
              <motion.div
                whileHover={{ y: -8, scale: 1.02 }}
                transition={{ type: "spring", stiffness: 300, damping: 20 }}
                className="group relative rounded-3xl border border-border bg-card/80 backdrop-blur-sm p-8 h-full overflow-hidden"
              >
                {/* Hover glow */}
                <div className={`absolute inset-0 bg-gradient-to-br ${feature.color} opacity-0 group-hover:opacity-[0.03] transition-opacity duration-500`} />

                {/* Icon */}
                <div className={`mb-6 flex h-14 w-14 items-center justify-center rounded-2xl ${feature.bg} transition-transform duration-300 group-hover:scale-110`}>
                  <feature.icon className="h-7 w-7 text-text-primary" />
                </div>

                <h3 className="text-xl font-bold text-text-primary mb-3">
                  {feature.title}
                </h3>
                <p className="text-text-secondary leading-relaxed">
                  {feature.description}
                </p>

                {/* Bottom accent line */}
                <div className={`absolute bottom-0 left-0 right-0 h-[2px] bg-gradient-to-r ${feature.color} scale-x-0 group-hover:scale-x-100 transition-transform duration-500 origin-left`} />
              </motion.div>
            </StaggerItem>
          ))}
        </StaggerContainer>
      </div>
    </section>
  );
}
