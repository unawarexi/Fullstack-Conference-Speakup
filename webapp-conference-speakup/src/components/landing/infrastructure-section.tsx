"use client";

import { motion } from "framer-motion";
import { RevealOnScroll, GradientText, StaggerContainer, StaggerItem } from "./motion-primitives";
import { Globe2, Shield, Wifi, Server, Lock, Gauge } from "lucide-react";

const stats = [
  { value: "99.99%", label: "Uptime SLA" },
  { value: "< 50ms", label: "Avg Latency" },
  { value: "30+", label: "Global Regions" },
  { value: "SOC 2", label: "Certified" },
];

const features = [
  {
    icon: Globe2,
    title: "Global edge network",
    description: "Low-latency media routing across 30+ regions. Your meetings are always fast, no matter where your team is.",
  },
  {
    icon: Shield,
    title: "End-to-end encryption",
    description: "AES-256 encryption for all media streams. Your conversations stay private, always.",
  },
  {
    icon: Wifi,
    title: "Adaptive streaming",
    description: "Intelligent bitrate adaptation. Crystal-clear video on fast connections, smooth audio on slow ones.",
  },
  {
    icon: Server,
    title: "Redundant architecture",
    description: "Multi-region failover with zero downtime. If one server goes down, your meeting doesn't.",
  },
  {
    icon: Lock,
    title: "SOC 2 Type II",
    description: "Enterprise-grade compliance. Regular audits, pen testing, and full incident response protocols.",
  },
  {
    icon: Gauge,
    title: "Real-time monitoring",
    description: "Granular quality metrics, network diagnostics, and proactive issue detection for every meeting.",
  },
];

export function InfrastructureSection() {
  return (
    <section className="py-32 relative">
      {/* Subtle grid background */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div
          className="absolute inset-0 opacity-[0.02]"
          style={{
            backgroundImage:
              "radial-gradient(circle at 1px 1px, currentColor 1px, transparent 0)",
            backgroundSize: "40px 40px",
          }}
        />
      </div>

      <div className="mx-auto max-w-7xl px-6 relative z-10">
        <RevealOnScroll>
          <div className="text-center mb-20">
            <motion.span
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              className="inline-flex items-center gap-2 rounded-full border border-primary/20 bg-primary/5 px-4 py-1.5 text-sm font-medium text-primary mb-6"
            >
              Infrastructure
            </motion.span>
            <h2 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-text-primary tracking-tight">
              Built for scale,
              <br />
              <GradientText>engineered for trust</GradientText>
            </h2>
          </div>
        </RevealOnScroll>

        {/* Stats bar */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-20"
        >
          {stats.map((stat, i) => (
            <motion.div
              key={stat.label}
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.1 }}
              className="rounded-2xl border border-border bg-card p-6 text-center"
            >
              <p className="text-3xl sm:text-4xl font-extrabold text-primary tracking-tight">
                {stat.value}
              </p>
              <p className="text-sm text-text-tertiary mt-1">{stat.label}</p>
            </motion.div>
          ))}
        </motion.div>

        {/* Features grid */}
        <StaggerContainer className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {features.map((feature) => (
            <StaggerItem key={feature.title}>
              <motion.div
                whileHover={{ y: -4 }}
                className="group rounded-2xl border border-border bg-card p-8 h-full transition-colors hover:border-primary/20"
              >
                <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary/10 mb-5 group-hover:bg-primary/15 transition-colors">
                  <feature.icon className="h-6 w-6 text-primary" />
                </div>
                <h3 className="text-lg font-bold text-text-primary mb-2">
                  {feature.title}
                </h3>
                <p className="text-sm text-text-secondary leading-relaxed">
                  {feature.description}
                </p>
              </motion.div>
            </StaggerItem>
          ))}
        </StaggerContainer>
      </div>
    </section>
  );
}
