"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { RevealOnScroll, GradientText, MagneticHover } from "./motion-primitives";
import { Check, Sparkles, Zap, Building2 } from "lucide-react";
import Link from "next/link";

const plans = [
  {
    name: "Free",
    price: "$0",
    period: "forever",
    description: "Perfect for individuals and small teams getting started.",
    icon: Zap,
    color: "from-blue-500 to-cyan-500",
    popular: false,
    features: [
      "Up to 10 participants per meeting",
      "40 minute meeting limit",
      "HD video & audio",
      "Basic screen sharing",
      "5 GB cloud storage",
      "Meeting chat",
      "Basic AI transcription",
    ],
  },
  {
    name: "Pro",
    price: "$12",
    period: "per user / month",
    description: "For growing teams who need more power and AI features.",
    icon: Sparkles,
    color: "from-purple-500 to-pink-500",
    popular: true,
    features: [
      "Up to 100 participants",
      "Unlimited meeting duration",
      "4K video & spatial audio",
      "Advanced screen sharing",
      "100 GB cloud storage",
      "AI meeting copilot",
      "Smart summaries & action items",
      "Real-time transcription",
      "Meeting analytics",
      "Custom branding",
      "Priority support",
    ],
  },
  {
    name: "Enterprise",
    price: "Custom",
    period: "contact sales",
    description: "For organizations needing enterprise-grade security and scale.",
    icon: Building2,
    color: "from-orange-500 to-red-500",
    popular: false,
    features: [
      "Unlimited participants",
      "Unlimited everything",
      "4K + recording",
      "SSO & SCIM provisioning",
      "Unlimited cloud storage",
      "Advanced AI suite",
      "Custom AI model training",
      "Full API access",
      "Advanced analytics & reporting",
      "Dedicated account manager",
      "99.99% SLA guarantee",
      "Custom integrations",
    ],
  },
];

function PricingToggle({
  annual,
  setAnnual,
}: {
  annual: boolean;
  setAnnual: (v: boolean) => void;
}) {
  return (
    <div className="flex items-center justify-center gap-4 mb-16">
      <span className={`text-sm font-medium transition-colors ${!annual ? "text-text-primary" : "text-text-tertiary"}`}>
        Monthly
      </span>
      <button
        onClick={() => setAnnual(!annual)}
        className={`relative h-8 w-14 rounded-full transition-colors ${annual ? "bg-primary" : "bg-border"}`}
      >
        <motion.div
          layout
          transition={{ type: "spring", stiffness: 500, damping: 30 }}
          className="absolute top-1 h-6 w-6 rounded-full bg-white shadow-sm"
          style={{ left: annual ? "calc(100% - 1.75rem)" : "0.25rem" }}
        />
      </button>
      <span className={`text-sm font-medium transition-colors ${annual ? "text-text-primary" : "text-text-tertiary"}`}>
        Annual
        <span className="ml-2 rounded-full bg-green-500/10 px-2 py-0.5 text-xs text-green-600 dark:text-green-400 font-semibold">
          Save 20%
        </span>
      </span>
    </div>
  );
}

function PricingCard({
  plan,
  annual,
  index,
}: {
  plan: (typeof plans)[0];
  annual: boolean;
  index: number;
}) {
  const displayPrice =
    plan.price === "$12"
      ? annual
        ? "$10"
        : "$12"
      : plan.price;

  return (
    <motion.div
      initial={{ opacity: 0, y: 40 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ duration: 0.6, delay: index * 0.15 }}
      whileHover={{ y: -8 }}
      className={`relative rounded-3xl border p-8 lg:p-10 h-full flex flex-col ${
        plan.popular
          ? "border-primary/40 bg-primary/[0.03] shadow-xl shadow-primary/5"
          : "border-border bg-card"
      }`}
    >
      {plan.popular && (
        <div className="absolute -top-4 left-1/2 -translate-x-1/2">
          <span className="rounded-full bg-primary px-4 py-1.5 text-xs font-bold text-white shadow-lg shadow-primary/20">
            Most popular
          </span>
        </div>
      )}

      <div className="mb-8">
        <div className={`inline-flex h-12 w-12 items-center justify-center rounded-2xl bg-gradient-to-br ${plan.color} mb-4`}>
          <plan.icon className="h-6 w-6 text-white" />
        </div>
        <h3 className="text-2xl font-bold text-text-primary">{plan.name}</h3>
        <p className="text-sm text-text-secondary mt-1">{plan.description}</p>
      </div>

      <div className="mb-8">
        <div className="flex items-baseline gap-1">
          <AnimatePresence mode="wait">
            <motion.span
              key={displayPrice}
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 10 }}
              className="text-5xl font-extrabold text-text-primary tracking-tight"
            >
              {displayPrice}
            </motion.span>
          </AnimatePresence>
          {plan.price !== "Custom" && (
            <span className="text-sm text-text-tertiary ml-1">/ {plan.period}</span>
          )}
        </div>
        {plan.price === "Custom" && (
          <span className="text-sm text-text-tertiary">{plan.period}</span>
        )}
      </div>

      <ul className="space-y-3 mb-10 flex-1">
        {plan.features.map((f) => (
          <li key={f} className="flex items-start gap-3 text-sm">
            <Check className="mt-0.5 h-4 w-4 flex-shrink-0 text-green-500" />
            <span className="text-text-secondary">{f}</span>
          </li>
        ))}
      </ul>

      <MagneticHover strength={4}>
        <Link
          href={plan.price === "Custom" ? "/contact" : "/auth/register"}
          className={`flex w-full items-center justify-center rounded-2xl px-6 py-4 text-sm font-bold transition-all duration-300 ${
            plan.popular
              ? "bg-primary text-white shadow-lg shadow-primary/25 hover:shadow-xl hover:shadow-primary/30 hover:brightness-110"
              : "bg-bg-secondary text-text-primary border border-border hover:border-primary/30 hover:bg-primary/5"
          }`}
        >
          {plan.price === "Custom" ? "Contact Sales" : "Get Started"}
        </Link>
      </MagneticHover>
    </motion.div>
  );
}

export function PricingSection() {
  const [annual, setAnnual] = useState(true);

  return (
    <section id="pricing" className="py-32 relative">
      {/* Background glow */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-primary/[0.03] rounded-full blur-3xl" />
      </div>

      <div className="mx-auto max-w-7xl px-6 relative z-10">
        <RevealOnScroll>
          <div className="text-center mb-12">
            <motion.span
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              className="inline-flex items-center gap-2 rounded-full border border-primary/20 bg-primary/5 px-4 py-1.5 text-sm font-medium text-primary mb-6"
            >
              Pricing
            </motion.span>
            <h2 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-text-primary tracking-tight">
              Simple, transparent
              <br />
              <GradientText>pricing for everyone</GradientText>
            </h2>
            <p className="mt-6 text-lg text-text-secondary max-w-2xl mx-auto">
              Start free. Upgrade when you need more. No hidden fees, no surprises.
            </p>
          </div>
        </RevealOnScroll>

        <PricingToggle annual={annual} setAnnual={setAnnual} />

        <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-3 items-stretch">
          {plans.map((plan, i) => (
            <PricingCard key={plan.name} plan={plan} annual={annual} index={i} />
          ))}
        </div>
      </div>
    </section>
  );
}
