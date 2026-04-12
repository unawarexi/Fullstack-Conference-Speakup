"use client";

import dynamic from "next/dynamic";
import { ScrollProgress } from "@/components/landing/motion-primitives";
import { HeroSection } from "@/components/landing/hero-section";
import { LazySection } from "@/components/landing/lazy-section";

const FeaturesSection = dynamic(
  () => import("@/components/landing/features-section").then((m) => m.FeaturesSection),
  { ssr: false }
);
const AIShowcaseSection = dynamic(
  () => import("@/components/landing/ai-showcase-section").then((m) => m.AIShowcaseSection),
  { ssr: false }
);
const HowItWorksSection = dynamic(
  () => import("@/components/landing/how-it-works-section").then((m) => m.HowItWorksSection),
  { ssr: false }
);
const TestimonialsSection = dynamic(
  () => import("@/components/landing/testimonials-section").then((m) => m.TestimonialsSection),
  { ssr: false }
);
const InfrastructureSection = dynamic(
  () => import("@/components/landing/infrastructure-section").then((m) => m.InfrastructureSection),
  { ssr: false }
);
const PricingSection = dynamic(
  () => import("@/components/landing/pricing-section").then((m) => m.PricingSection),
  { ssr: false }
);
const CTASection = dynamic(
  () => import("@/components/landing/cta-section").then((m) => m.CTASection),
  { ssr: false }
);

export default function LandingPage() {
  return (
    <>
      <ScrollProgress />
      <HeroSection />
      <LazySection>
        <FeaturesSection />
      </LazySection>
      <LazySection>
        <AIShowcaseSection />
      </LazySection>
      <LazySection>
        <HowItWorksSection />
      </LazySection>
      <LazySection>
        <TestimonialsSection />
      </LazySection>
      <LazySection>
        <InfrastructureSection />
      </LazySection>
      <LazySection>
        <PricingSection />
      </LazySection>
      <LazySection>
        <CTASection />
      </LazySection>
    </>
  );
}
