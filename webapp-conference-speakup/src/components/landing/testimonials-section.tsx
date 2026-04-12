"use client";

import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";
import { RevealOnScroll, GradientText } from "./motion-primitives";

const testimonials = [
  {
    quote: "SpeakUp replaced three tools for us — Zoom, Otter.ai, and Notion for meeting notes. The AI is genuinely game-changing.",
    name: "Sarah Chen",
    role: "VP Engineering, Stripe",
    avatar: "SC",
    color: "from-blue-500 to-cyan-500",
  },
  {
    quote: "The transcription accuracy is incredible. We've cut our meeting follow-up time by 60% since switching to SpeakUp.",
    name: "Marcus Johnson",
    role: "Product Lead, Figma",
    avatar: "MJ",
    color: "from-purple-500 to-pink-500",
  },
  {
    quote: "Best video quality I've seen. Even with 200+ participants, it just works. The AI copilot surfaces insights I'd otherwise miss.",
    name: "Emma Williams",
    role: "CEO, TechFlow",
    avatar: "EW",
    color: "from-orange-500 to-red-500",
  },
  {
    quote: "We deployed SpeakUp across 50 teams. The analytics dashboard alone justified the switch — finally real visibility into meeting culture.",
    name: "David Park",
    role: "CTO, Databricks",
    avatar: "DP",
    color: "from-green-500 to-emerald-500",
  },
  {
    quote: "The voice commands are incredible. 'Hey SpeakUp, action item for Mike' — and it just works. My team loves it.",
    name: "Lisa Rodriguez",
    role: "Director of Ops, Notion",
    avatar: "LR",
    color: "from-indigo-500 to-violet-500",
  },
  {
    quote: "Enterprise-grade security with consumer-grade UX. SpeakUp is the first video tool our security team approved on first review.",
    name: "James Kim",
    role: "CISO, Cloudflare",
    avatar: "JK",
    color: "from-teal-500 to-cyan-500",
  },
];

function TestimonialCard({
  testimonial,
  index,
}: {
  testimonial: (typeof testimonials)[0];
  index: number;
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 40 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-50px" }}
      transition={{ duration: 0.6, delay: index * 0.1 }}
      whileHover={{ y: -6, scale: 1.02 }}
      className="group relative rounded-3xl border border-border bg-card p-8 h-full"
    >
      {/* Quote mark */}
      <div className="absolute top-6 right-8 text-6xl font-serif text-text-tertiary/10 select-none leading-none">
        &ldquo;
      </div>

      <p className="text-text-secondary leading-relaxed mb-8 relative z-10">
        &ldquo;{testimonial.quote}&rdquo;
      </p>

      <div className="flex items-center gap-3">
        <div className={`flex h-11 w-11 items-center justify-center rounded-full bg-gradient-to-br ${testimonial.color} text-white text-sm font-bold`}>
          {testimonial.avatar}
        </div>
        <div>
          <p className="text-sm font-semibold text-text-primary">{testimonial.name}</p>
          <p className="text-xs text-text-tertiary">{testimonial.role}</p>
        </div>
      </div>
    </motion.div>
  );
}

export function TestimonialsSection() {
  return (
    <section className="py-32 overflow-hidden">
      <div className="mx-auto max-w-7xl px-6">
        <RevealOnScroll>
          <div className="text-center mb-20">
            <h2 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-text-primary tracking-tight">
              Loved by teams
              <br />
              <GradientText>around the world</GradientText>
            </h2>
            <p className="mt-6 text-lg text-text-secondary max-w-2xl mx-auto">
              Join thousands of teams who&apos;ve made SpeakUp their home for collaboration.
            </p>
          </div>
        </RevealOnScroll>

        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {testimonials.map((t, i) => (
            <TestimonialCard key={t.name} testimonial={t} index={i} />
          ))}
        </div>
      </div>
    </section>
  );
}
