"use client";

import Link from "next/link";
import Image from "next/image";
import dynamic from "next/dynamic";
import { motion } from "framer-motion";
import { ArrowRight, Sparkles, Play } from "lucide-react";
import { Button } from "@/components/ui";
import {
  RevealOnScroll,
  GradientText,
  AnimatedCounter,
  MagneticHover,
} from "./motion-primitives";

const HeroScene = dynamic(
  () => import("./hero-scene").then((m) => m.HeroScene),
  { ssr: false }
);

export function HeroSection() {
  return (
    <section className="relative min-h-[100vh] flex items-center overflow-hidden">
      {/* 3D Background */}
      <HeroScene />

      {/* Subtle grid pattern behind everything */}
      <div className="absolute inset-0 bg-[linear-gradient(to_right,var(--border)_1px,transparent_1px),linear-gradient(to_bottom,var(--border)_1px,transparent_1px)] bg-[size:80px_80px] opacity-20 z-[1]" />

      {/* Gradient overlays */}
      <div className="absolute inset-0 bg-gradient-to-b from-background/30 via-transparent to-background z-[1]" />
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top_right,_var(--primary)_0%,_transparent_60%)] opacity-[0.06] z-[1]" />
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_bottom_left,_#8B5CF6_0%,_transparent_60%)] opacity-[0.04] z-[1]" />

      <div className="relative z-[2] mx-auto max-w-7xl w-full px-6 py-28 sm:py-36">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-8 items-center">
          {/* Left — Copy */}
          <div className="max-w-2xl">
            {/* Badge */}
            <RevealOnScroll delay={0}>
              <motion.div
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.5 }}
                className="inline-flex items-center gap-2 rounded-full border border-primary/20 bg-primary/5 backdrop-blur-sm px-4 py-1.5 text-xs sm:text-sm font-medium text-primary mb-6"
              >
                <Sparkles className="h-3.5 w-3.5" />
                <span>AI-Powered Conferencing</span>
                <span className="h-1 w-1 rounded-full bg-primary animate-pulse" />
                <span className="text-text-secondary text-xs">Beta</span>
              </motion.div>
            </RevealOnScroll>

            {/* Headline */}
            <RevealOnScroll delay={0.1}>
              <h1 className="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-extrabold tracking-tight text-text-primary leading-[1.05]">
                Meetings
                <br />
                that <GradientText>move you</GradientText>
                <br />
                <span className="text-text-tertiary">forward.</span>
              </h1>
            </RevealOnScroll>

            {/* Subtitle */}
            <RevealOnScroll delay={0.2}>
              <p className="mt-6 max-w-lg text-base sm:text-lg text-text-secondary leading-relaxed">
                Crystal-clear video, real-time AI transcription, smart scheduling,
                and collaboration tools — all in one beautiful platform.
              </p>
            </RevealOnScroll>

            {/* CTAs */}
            <RevealOnScroll delay={0.3}>
              <div className="mt-8 flex flex-wrap items-center gap-4">
                <MagneticHover>
                  <Link href="/login">
                    <Button size="lg" className="gap-2 px-8 h-13 text-sm rounded-2xl shadow-lg shadow-primary/25 hover:shadow-xl hover:shadow-primary/30 transition-shadow">
                      Start for Free
                      <ArrowRight className="h-4 w-4" />
                    </Button>
                  </Link>
                </MagneticHover>
                <MagneticHover>
                  <button className="group flex items-center gap-3 h-13 px-6 rounded-2xl border border-border bg-card/50 backdrop-blur-sm text-text-primary hover:border-primary/30 transition-colors">
                    <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary/10 group-hover:bg-primary/20 transition-colors">
                      <Play className="h-3.5 w-3.5 text-primary ml-0.5" />
                    </div>
                    <span className="text-sm font-medium">Watch Demo</span>
                  </button>
                </MagneticHover>
              </div>
            </RevealOnScroll>

            {/* Stats row */}
            <RevealOnScroll delay={0.5}>
              <div className="mt-12 flex gap-8 sm:gap-12">
                {[
                  { target: 10000, suffix: "+", label: "Active Users" },
                  { target: 50000, suffix: "+", label: "Meetings" },
                  { target: 99, suffix: ".9%", label: "Uptime" },
                ].map((stat) => (
                  <div key={stat.label}>
                    <p className="text-2xl sm:text-3xl font-bold text-text-primary">
                      <AnimatedCounter target={stat.target} suffix={stat.suffix} />
                    </p>
                    <p className="mt-0.5 text-xs text-text-tertiary">{stat.label}</p>
                  </div>
                ))}
              </div>
            </RevealOnScroll>
          </div>

          {/* Right — Floating emblem visual */}
          <RevealOnScroll delay={0.4} direction="right">
            <div className="hidden lg:flex items-center justify-center relative">
              {/* Glow behind emblem */}
              <div className="absolute w-72 h-72 bg-primary/15 rounded-full blur-3xl" />
              <div className="absolute w-48 h-48 bg-[#8B5CF6]/10 rounded-full blur-2xl translate-x-12 translate-y-8" />
              <motion.div
                animate={{ y: [-8, 8, -8], rotate: [0, 2, 0, -2, 0] }}
                transition={{ duration: 6, repeat: Infinity, ease: "easeInOut" }}
              >
                <Image
                  src="/logo/emblem.png"
                  alt="SpeakUp"
                  width={280}
                  height={280}
                  className="drop-shadow-2xl relative z-10"
                  style={{ width: "auto", height: "auto" }}
                  priority
                />
              </motion.div>
            </div>
          </RevealOnScroll>
        </div>
      </div>

      {/* Scroll indicator */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 2 }}
        className="absolute bottom-8 left-1/2 -translate-x-1/2 z-[2]"
      >
        <motion.div
          animate={{ y: [0, 10, 0] }}
          transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
          className="w-5 h-8 rounded-full border-2 border-text-tertiary/30 flex items-start justify-center pt-1.5"
        >
          <div className="w-1 h-1 rounded-full bg-primary" />
        </motion.div>
      </motion.div>
    </section>
  );
}
