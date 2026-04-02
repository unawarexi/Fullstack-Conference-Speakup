import Link from "next/link";
import { Button } from "@/components/ui";
import { strings } from "@/config/strings";
import {
  Video,
  Monitor,
  MessageSquare,
  Calendar,
  Shield,
  Users,
  ArrowRight,
  Check,
  Sparkles,
  Zap,
} from "lucide-react";

const features = [
  {
    icon: Video,
    title: strings.landing.feature1Title,
    description: strings.landing.feature1Desc,
  },
  {
    icon: Monitor,
    title: strings.landing.feature2Title,
    description: strings.landing.feature2Desc,
  },
  {
    icon: MessageSquare,
    title: strings.landing.feature3Title,
    description: strings.landing.feature3Desc,
  },
  {
    icon: Calendar,
    title: strings.landing.feature4Title,
    description: strings.landing.feature4Desc,
  },
  {
    icon: Shield,
    title: strings.landing.feature5Title,
    description: strings.landing.feature5Desc,
  },
  {
    icon: Users,
    title: strings.landing.feature6Title,
    description: strings.landing.feature6Desc,
  },
];

const plans = [
  {
    name: "Free",
    price: "$0",
    period: "forever",
    description: "For individuals and small teams getting started",
    features: [
      "Up to 40-minute meetings",
      "100 participants per meeting",
      "Screen sharing",
      "Basic chat",
      "5 GB cloud storage",
    ],
    cta: "Get Started",
    popular: false,
  },
  {
    name: "Pro",
    price: "$12",
    period: "/month",
    description: "For growing teams that need more power",
    features: [
      "Unlimited meeting duration",
      "500 participants per meeting",
      "HD recording & transcription",
      "Advanced chat & channels",
      "100 GB cloud storage",
      "Custom branding",
      "Priority support",
    ],
    cta: "Start Free Trial",
    popular: true,
  },
  {
    name: "Enterprise",
    price: "Custom",
    period: "",
    description: "For organizations with advanced needs",
    features: [
      "Everything in Pro",
      "Unlimited participants",
      "SSO & SAML",
      "Dedicated account manager",
      "Unlimited cloud storage",
      "SLA guarantee",
      "Custom integrations",
      "On-premise deployment",
    ],
    cta: "Contact Sales",
    popular: false,
  },
];

export default function LandingPage() {
  return (
    <>
      {/* ── Hero ──────────────────────────────────────────── */}
      <section className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-primary/5 via-transparent to-transparent" />
        <div className="relative mx-auto max-w-7xl px-6 py-24 sm:py-32 lg:py-40 text-center">
          <div className="inline-flex items-center gap-2 rounded-full bg-primary/10 px-4 py-1.5 text-sm font-medium text-primary mb-8">
            <Sparkles className="h-4 w-4" />
            Now Available
          </div>

          <h1 className="mx-auto max-w-4xl text-4xl font-bold tracking-tight text-textPrimary sm:text-5xl lg:text-6xl">
            {strings.landing.heroTitle}
          </h1>

          <p className="mx-auto mt-6 max-w-2xl text-lg text-textSecondary">
            {strings.landing.heroSubtitle}
          </p>

          <div className="mt-10 flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
            <Link href="/login">
              <Button size="lg" className="gap-2 px-8">
                {strings.landing.ctaStart}
                <ArrowRight className="h-4 w-4" />
              </Button>
            </Link>
            <a href="#features">
              <Button variant="outline" size="lg" className="px-8">
                Learn More
              </Button>
            </a>
          </div>

          {/* Stats */}
          <div className="mt-16 grid grid-cols-3 gap-8 mx-auto max-w-lg">
            {[
              { value: "10K+", label: "Active Users" },
              { value: "50K+", label: "Meetings Hosted" },
              { value: "99.9%", label: "Uptime" },
            ].map((stat) => (
              <div key={stat.label}>
                <p className="text-2xl font-bold text-textPrimary sm:text-3xl">{stat.value}</p>
                <p className="text-sm text-textSecondary">{stat.label}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── Features ──────────────────────────────────────── */}
      <section id="features" className="py-24 bg-surface">
        <div className="mx-auto max-w-7xl px-6">
          <div className="text-center mb-16">
            <div className="inline-flex items-center gap-2 rounded-full bg-primary/10 px-4 py-1.5 text-sm font-medium text-primary mb-4">
              <Zap className="h-4 w-4" />
              Features
            </div>
            <h2 className="text-3xl font-bold text-textPrimary sm:text-4xl">
              Everything You Need for Seamless Meetings
            </h2>
            <p className="mt-4 text-lg text-textSecondary max-w-2xl mx-auto">
              Powerful features built for modern teams
            </p>
          </div>

          <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-3">
            {features.map((feature) => (
              <div
                key={feature.title}
                className="group rounded-2xl border border-border bg-card p-8 transition-all hover:border-primary/30 hover:shadow-lg"
              >
                <div className="mb-5 flex h-12 w-12 items-center justify-center rounded-xl bg-primary/10 text-primary transition-colors group-hover:bg-primary group-hover:text-white">
                  <feature.icon className="h-6 w-6" />
                </div>
                <h3 className="text-lg font-semibold text-textPrimary">{feature.title}</h3>
                <p className="mt-2 text-sm text-textSecondary leading-relaxed">{feature.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── Pricing ──────────────────────────────────────── */}
      <section id="pricing" className="py-24">
        <div className="mx-auto max-w-7xl px-6">
          <div className="text-center mb-16">
            <h2 className="text-3xl font-bold text-textPrimary sm:text-4xl">
              Simple, Transparent Pricing
            </h2>
            <p className="mt-4 text-lg text-textSecondary">
              Choose the plan that works best for your team
            </p>
          </div>

          <div className="grid gap-8 lg:grid-cols-3 max-w-5xl mx-auto">
            {plans.map((plan) => (
              <div
                key={plan.name}
                className={`relative rounded-2xl border p-8 ${
                  plan.popular
                    ? "border-primary bg-card shadow-xl scale-105"
                    : "border-border bg-card"
                }`}
              >
                {plan.popular && (
                  <span className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-primary px-4 py-1 text-xs font-semibold text-white">
                    Most Popular
                  </span>
                )}
                <h3 className="text-xl font-bold text-textPrimary">{plan.name}</h3>
                <p className="mt-1 text-sm text-textSecondary">{plan.description}</p>
                <div className="mt-6 flex items-baseline gap-1">
                  <span className="text-4xl font-bold text-textPrimary">{plan.price}</span>
                  {plan.period && (
                    <span className="text-textSecondary">{plan.period}</span>
                  )}
                </div>
                <ul className="mt-8 space-y-3">
                  {plan.features.map((f) => (
                    <li key={f} className="flex items-start gap-3 text-sm text-textSecondary">
                      <Check className="h-5 w-5 shrink-0 text-success" />
                      {f}
                    </li>
                  ))}
                </ul>
                <Link href="/login" className="mt-8 block">
                  <Button
                    variant={plan.popular ? "primary" : "outline"}
                    className="w-full"
                  >
                    {plan.cta}
                  </Button>
                </Link>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── CTA ──────────────────────────────────────────── */}
      <section className="py-24 bg-primary">
        <div className="mx-auto max-w-3xl px-6 text-center text-white">
          <h2 className="text-3xl font-bold sm:text-4xl">Ready to transform your meetings?</h2>
          <p className="mt-4 text-lg text-white/80">
            Join thousands of teams already using SpeakUp for seamless collaboration.
          </p>
          <Link href="/login">
            <Button
              size="lg"
              className="mt-8 bg-white text-primary hover:bg-white/90 gap-2 px-8"
            >
              Get Started Free
              <ArrowRight className="h-4 w-4" />
            </Button>
          </Link>
        </div>
      </section>
    </>
  );
}
