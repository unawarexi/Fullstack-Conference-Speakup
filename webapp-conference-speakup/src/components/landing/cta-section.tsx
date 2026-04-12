"use client";

import { motion } from "framer-motion";
import { GradientText, MagneticHover, ParallaxSection } from "./motion-primitives";
import { ArrowRight } from "lucide-react";
import Link from "next/link";

const logos = [
  "Stripe",
  "Figma",
  "Notion",
  "Vercel",
  "Linear",
  "Raycast",
  "Supabase",
  "Prisma",
];

function LogoBanner() {
  return (
    <div className="relative overflow-hidden py-8 mb-20">
      <div className="absolute left-0 top-0 bottom-0 w-32 bg-linear-to-r from-bg-primary to-transparent z-10" />
      <div className="absolute right-0 top-0 bottom-0 w-32 bg-linear-to-l from-bg-primary to-transparent z-10" />
      <motion.div
        animate={{ x: [0, -1200] }}
        transition={{ duration: 30, repeat: Infinity, ease: "linear" }}
        className="flex gap-16 whitespace-nowrap"
      >
        {[...logos, ...logos, ...logos].map((logo, i) => (
          <span
            key={`${logo}-${i}`}
            className="text-2xl font-bold text-text-tertiary/30 select-none"
          >
            {logo}
          </span>
        ))}
      </motion.div>
    </div>
  );
}

export function CTASection() {
  return (
    <section className="py-32 relative overflow-hidden">
      {/* Background effects */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-0 left-1/4 w-96 h-96 bg-primary/10 rounded-full blur-3xl" />
        <div className="absolute bottom-0 right-1/4 w-96 h-96 bg-purple-500/10 rounded-full blur-3xl" />
      </div>

      <div className="mx-auto max-w-7xl px-6 relative z-10">
        <LogoBanner />

        <ParallaxSection speed={0.3}>
          <div className="relative rounded-[2rem] border border-border bg-card/80 backdrop-blur-xl p-12 sm:p-16 lg:p-24 text-center overflow-hidden">
            {/* Grid pattern overlay */}
            <div
              className="absolute inset-0 opacity-[0.015]"
              style={{
                backgroundImage:
                  "linear-gradient(to right, currentColor 1px, transparent 1px), linear-gradient(to bottom, currentColor 1px, transparent 1px)",
                backgroundSize: "60px 60px",
              }}
            />

            {/* Gradient border overlay */}
            <div className="absolute inset-0 rounded-[2rem] bg-gradient-to-br from-primary/5 via-transparent to-purple-500/5" />

            <div className="relative z-10">
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6 }}
              >
                <h2 className="text-4xl sm:text-5xl lg:text-7xl font-extrabold text-text-primary tracking-tight leading-[1.1]">
                  Ready to transform
                  <br />
                  <GradientText>how you meet?</GradientText>
                </h2>
                <p className="mt-6 text-lg sm:text-xl text-text-secondary max-w-2xl mx-auto">
                  Join 10,000+ teams already using SpeakUp. Start for free — no credit card required.
                </p>
              </motion.div>

              <motion.div
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: 0.2 }}
                className="flex flex-col sm:flex-row items-center justify-center gap-4 mt-10"
              >
                <MagneticHover strength={6}>
                  <Link
                    href="/auth/register"
                    className="group inline-flex items-center gap-3 rounded-2xl bg-primary px-8 py-4 text-base font-bold text-white shadow-xl shadow-primary/25 hover:shadow-2xl hover:shadow-primary/30 transition-all duration-300 hover:brightness-110"
                  >
                    Start for Free
                    <ArrowRight className="h-5 w-5 transition-transform group-hover:translate-x-1" />
                  </Link>
                </MagneticHover>
                <MagneticHover strength={4}>
                  <Link
                    href="#pricing"
                    className="inline-flex items-center gap-2 rounded-2xl border border-border bg-bg-primary px-8 py-4 text-base font-bold text-text-primary hover:bg-bg-secondary transition-all duration-300"
                  >
                    View Pricing
                  </Link>
                </MagneticHover>
              </motion.div>

              <motion.p
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6, delay: 0.4 }}
                className="mt-6 text-sm text-text-tertiary"
              >
                Free forever for small teams · No credit card needed · Setup in 2 minutes
              </motion.p>
            </div>
          </div>
        </ParallaxSection>
      </div>
    </section>
  );
}
