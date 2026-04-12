"use client";

import { motion } from "framer-motion";
import { RevealOnScroll, GradientText, StaggerContainer, StaggerItem } from "./motion-primitives";
import { UserPlus, Video, Sparkles, BarChart3 } from "lucide-react";

const steps = [
  {
    step: "01",
    title: "Create your space",
    description: "Sign up in seconds. Set up your workspace, invite your team, and customize your meeting preferences.",
    icon: UserPlus,
    color: "from-blue-500 to-cyan-500",
    accent: "bg-blue-500/10",
  },
  {
    step: "02",
    title: "Start a meeting",
    description: "One click to launch. Share your unique meeting code or schedule ahead. HD video with AI assistance kicks in automatically.",
    icon: Video,
    color: "from-purple-500 to-pink-500",
    accent: "bg-purple-500/10",
  },
  {
    step: "03",
    title: "Let AI handle the rest",
    description: "Real-time transcription, smart summaries, action items, and insights — all generated automatically as you talk.",
    icon: Sparkles,
    color: "from-orange-500 to-red-500",
    accent: "bg-orange-500/10",
  },
  {
    step: "04",
    title: "Review & act",
    description: "Access your analytics dashboard. See meeting trends, team participation, and AI-generated follow-ups. Ship faster.",
    icon: BarChart3,
    color: "from-green-500 to-emerald-500",
    accent: "bg-green-500/10",
  },
];

export function HowItWorksSection() {
  return (
    <section className="py-32 relative">
      <div className="mx-auto max-w-7xl px-6">
        <RevealOnScroll>
          <div className="text-center mb-20">
            <motion.span
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              className="inline-flex items-center gap-2 rounded-full border border-primary/20 bg-primary/5 px-4 py-1.5 text-sm font-medium text-primary mb-6"
            >
              How it works
            </motion.span>
            <h2 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-text-primary tracking-tight">
              From zero to
              <br />
              <GradientText>productive in minutes</GradientText>
            </h2>
          </div>
        </RevealOnScroll>

        <StaggerContainer className="relative">
          {/* Connection line */}
          <div className="absolute left-1/2 top-0 bottom-0 w-px bg-gradient-to-b from-transparent via-border to-transparent hidden lg:block" />

          <div className="space-y-16 lg:space-y-0 lg:grid lg:grid-cols-4 lg:gap-8">
            {steps.map((step, index) => (
              <StaggerItem key={step.step}>
                <motion.div
                  whileHover={{ y: -6 }}
                  className="relative text-center group"
                >
                  {/* Step number bubble */}
                  <div className="relative mx-auto mb-8">
                    <div className={`mx-auto flex h-20 w-20 items-center justify-center rounded-2xl bg-gradient-to-br ${step.color} shadow-lg group-hover:shadow-xl transition-shadow duration-300`}>
                      <step.icon className="h-9 w-9 text-white" />
                    </div>
                    <span className="absolute -top-3 -right-3 flex h-8 w-8 items-center justify-center rounded-full bg-bg-primary border-2 border-border text-xs font-bold text-text-secondary">
                      {step.step}
                    </span>
                  </div>

                  {/* Arrow connector — visible on large screens only */}
                  {index < steps.length - 1 && (
                    <div className="hidden lg:block absolute top-10 -right-4 text-text-tertiary/30 z-10">
                      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                        <path d="M5 12h14m-7-7 7 7-7 7" />
                      </svg>
                    </div>
                  )}

                  <h3 className="text-xl font-bold text-text-primary mb-3">
                    {step.title}
                  </h3>
                  <p className="text-sm text-text-secondary leading-relaxed max-w-xs mx-auto">
                    {step.description}
                  </p>
                </motion.div>
              </StaggerItem>
            ))}
          </div>
        </StaggerContainer>
      </div>
    </section>
  );
}
