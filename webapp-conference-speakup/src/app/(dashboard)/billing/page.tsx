"use client";

import { Card, Spinner } from "@/components/ui";
import { useSubscription } from "@/hooks/use-billing";
import { api } from "@/lib/api-client";
import { endpoints } from "@/config/endpoints";
import {
  CreditCard,
  Check,
  ArrowRight,
  Sparkles,
  Zap,
  Building2,
  ExternalLink,
} from "lucide-react";

const plans = [
  {
    id: "free" as const,
    name: "Free",
    price: "$0",
    period: "forever",
    icon: Zap,
    color: "from-blue-500 to-cyan-500",
    features: [
      "Up to 10 participants",
      "40 minute limit",
      "HD video & audio",
      "Basic screen sharing",
      "5 GB storage",
    ],
  },
  {
    id: "pro" as const,
    name: "Pro",
    price: "$12",
    period: "/month",
    icon: Sparkles,
    color: "from-purple-500 to-pink-500",
    features: [
      "Up to 100 participants",
      "Unlimited duration",
      "4K video & spatial audio",
      "AI meeting copilot",
      "100 GB storage",
      "Meeting analytics",
      "Priority support",
    ],
  },
  {
    id: "enterprise" as const,
    name: "Enterprise",
    price: "Custom",
    period: "",
    icon: Building2,
    color: "from-orange-500 to-red-500",
    features: [
      "Unlimited everything",
      "SSO & SCIM",
      "Custom AI models",
      "Dedicated manager",
      "99.99% SLA",
    ],
  },
];

async function handleCheckout(planId: string) {
  try {
    const { data } = await api.post(endpoints.billing.checkout, { plan: planId });
    if (data?.data?.url) {
      window.location.href = data.data.url;
    }
  } catch {
    // Checkout errors handled by API client interceptor
  }
}

async function handleManage() {
  try {
    const { data } = await api.post(endpoints.billing.portal);
    if (data?.data?.url) {
      window.location.href = data.data.url;
    }
  } catch {
    // Portal errors handled by API client interceptor
  }
}

export default function BillingPage() {
  const { data: subscription, isLoading } = useSubscription();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Spinner size="lg" />
      </div>
    );
  }

  const currentPlan = subscription?.plan ?? "free";
  const status = subscription?.status ?? "active";

  return (
    <div className="mx-auto max-w-6xl p-6 space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-text-primary">Billing</h1>
        <p className="mt-1 text-text-secondary">Manage your subscription and billing</p>
      </div>

      {/* Current plan card */}
      <Card className="p-6">
        <div className="flex items-center justify-between flex-wrap gap-4">
          <div className="flex items-center gap-4">
            <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-primary/10">
              <CreditCard className="h-6 w-6 text-primary" />
            </div>
            <div>
              <p className="text-sm text-text-secondary">Current plan</p>
              <p className="text-xl font-bold text-text-primary capitalize">{currentPlan}</p>
            </div>
          </div>
          <div className="flex items-center gap-3">
            <span
              className={`rounded-full px-3 py-1 text-xs font-semibold ${
                status === "active"
                  ? "bg-green-500/10 text-green-600 dark:text-green-400"
                  : status === "trialing"
                  ? "bg-blue-500/10 text-blue-600 dark:text-blue-400"
                  : "bg-orange-500/10 text-orange-600 dark:text-orange-400"
              }`}
            >
              {status}
            </span>
            {currentPlan !== "free" && (
              <button
                onClick={handleManage}
                className="flex items-center gap-2 rounded-xl border border-border px-4 py-2 text-sm font-medium text-text-primary hover:bg-bg-secondary transition-colors"
              >
                Manage
                <ExternalLink className="h-3.5 w-3.5" />
              </button>
            )}
          </div>
        </div>

        {subscription?.currentPeriodEnd && (
          <p className="mt-3 text-sm text-text-tertiary">
            {status === "active" ? "Renews" : "Expires"} on{" "}
            {new Date(subscription.currentPeriodEnd).toLocaleDateString("en-US", {
              month: "long",
              day: "numeric",
              year: "numeric",
            })}
          </p>
        )}
      </Card>

      {/* Plans grid */}
      <div>
        <h2 className="text-lg font-semibold text-text-primary mb-4">Available plans</h2>
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {plans.map((plan) => {
            const isCurrent = currentPlan === plan.id;
            return (
              <Card
                key={plan.id}
                className={`p-6 flex flex-col relative ${
                  isCurrent ? "border-primary/40 shadow-lg shadow-primary/5" : ""
                }`}
              >
                {isCurrent && (
                  <span className="absolute -top-3 left-4 rounded-full bg-primary px-3 py-1 text-xs font-bold text-white">
                    Current
                  </span>
                )}

                <div className={`inline-flex h-11 w-11 items-center justify-center rounded-xl bg-gradient-to-br ${plan.color} mb-4`}>
                  <plan.icon className="h-5 w-5 text-white" />
                </div>

                <h3 className="text-xl font-bold text-text-primary">{plan.name}</h3>
                <div className="flex items-baseline gap-1 mt-1 mb-4">
                  <span className="text-3xl font-extrabold text-text-primary">{plan.price}</span>
                  {plan.period && (
                    <span className="text-sm text-text-tertiary">{plan.period}</span>
                  )}
                </div>

                <ul className="space-y-2.5 mb-6 flex-1">
                  {plan.features.map((f) => (
                    <li key={f} className="flex items-center gap-2.5 text-sm text-text-secondary">
                      <Check className="h-4 w-4 text-green-500 shrink-0" />
                      {f}
                    </li>
                  ))}
                </ul>

                <button
                  disabled={isCurrent}
                  onClick={() => {
                    if (plan.id === "enterprise") {
                      window.location.href = "/contact";
                    } else {
                      handleCheckout(plan.id);
                    }
                  }}
                  className={`flex w-full items-center justify-center gap-2 rounded-xl px-4 py-3 text-sm font-bold transition-all ${
                    isCurrent
                      ? "bg-bg-secondary text-text-tertiary cursor-not-allowed"
                      : "bg-primary text-white hover:brightness-110 shadow-lg shadow-primary/20"
                  }`}
                >
                  {isCurrent ? "Current Plan" : plan.id === "enterprise" ? "Contact Sales" : "Upgrade"}
                  {!isCurrent && <ArrowRight className="h-4 w-4" />}
                </button>
              </Card>
            );
          })}
        </div>
      </div>
    </div>
  );
}
