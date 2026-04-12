"use client";

import Link from "next/link";
import Image from "next/image";
import { strings } from "@/config/strings";
import { Menu, X, Globe, Mail, Sun, Moon } from "lucide-react";
import type { ReactNode } from "react";
import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useThemeStore } from "@/store/theme-store";

function LandingHeader() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [mounted, setMounted] = useState(false);
  const resolvedTheme = useThemeStore((s) => s.resolvedTheme);
  const toggleDarkMode = useThemeStore((s) => s.toggleDarkMode);

  useEffect(() => {
    setMounted(true);
  }, []);

  const isDark = mounted && resolvedTheme === "dark";

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  const navLinks = [
    { href: "#features", label: "Features" },
    { href: "#pricing", label: "Pricing" },
    { href: "/docs", label: "Docs" },
    { href: "/blog", label: "Blog" },
  ];

  return (
    <>
      <header
        className={`fixed top-0 left-0 right-0 z-50 transition-all duration-500 ${
          scrolled
            ? "bg-bg-primary/80 backdrop-blur-2xl border-b border-border/50 shadow-sm"
            : "bg-transparent"
        }`}
      >
        <div className="mx-auto flex h-18 max-w-7xl items-center justify-between px-6">
          <Link href="/" className="flex items-center gap-2.5 group">
            <Image
              src="/logo/emblem.png"
              alt="SpeakUp"
              width={40}
              height={40}
              className="rounded-xl shadow-lg shadow-primary/20 group-hover:shadow-primary/40 transition-shadow"
              style={{ width: "auto", height: "auto" }}
              priority
            />
            <Image
              src="/logo/logo.png"
              alt="SpeakUp"
              width={120}
              height={32}
              className="hidden sm:block"
              style={{ height: 32, width: "auto" }}
              priority
            />
          </Link>

          <nav className="hidden items-center gap-1 md:flex">
            {navLinks.map((link) => (
              <a
                key={link.label}
                href={link.href}
                className="relative rounded-lg px-4 py-2 text-sm font-medium text-text-secondary hover:text-text-primary transition-colors hover:bg-bg-secondary/50"
              >
                {link.label}
              </a>
            ))}
          </nav>

          <div className="hidden md:flex items-center gap-3">
            <button
              onClick={toggleDarkMode}
              aria-label="Toggle theme"
              className="flex h-10 w-10 items-center justify-center rounded-xl hover:bg-bg-secondary/50 transition-colors text-text-secondary hover:text-text-primary"
            >
              {mounted && (
                <AnimatePresence mode="wait" initial={false}>
                  {isDark ? (
                    <motion.div
                      key="sun"
                      initial={{ scale: 0, rotate: -90 }}
                      animate={{ scale: 1, rotate: 0 }}
                      exit={{ scale: 0, rotate: 90 }}
                      transition={{ duration: 0.2 }}
                    >
                      <Sun className="h-5 w-5" />
                    </motion.div>
                  ) : (
                    <motion.div
                      key="moon"
                      initial={{ scale: 0, rotate: 90 }}
                      animate={{ scale: 1, rotate: 0 }}
                      exit={{ scale: 0, rotate: -90 }}
                      transition={{ duration: 0.2 }}
                    >
                      <Moon className="h-5 w-5" />
                    </motion.div>
                  )}
                </AnimatePresence>
              )}
            </button>
            <Link
              href="/login"
              className="rounded-xl px-5 py-2.5 text-sm font-semibold text-text-primary hover:bg-bg-secondary/50 transition-colors"
            >
              Sign In
            </Link>
            <Link
              href="/auth/register"
              className="rounded-xl bg-primary px-5 py-2.5 text-sm font-bold text-white shadow-lg shadow-primary/20 hover:shadow-primary/30 hover:brightness-110 transition-all"
            >
              Get Started
            </Link>
          </div>

          {/* Mobile menu button */}
          <button
            onClick={() => setMobileOpen(!mobileOpen)}
            className="md:hidden flex h-10 w-10 items-center justify-center rounded-xl hover:bg-bg-secondary transition-colors"
          >
            {mobileOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
          </button>
        </div>
      </header>

      {/* Mobile nav */}
      <AnimatePresence>
        {mobileOpen && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="fixed inset-x-0 top-18 z-40 border-b border-border bg-bg-primary/95 backdrop-blur-2xl md:hidden"
          >
            <div className="px-6 py-6 space-y-1">
              {navLinks.map((link) => (
                <a
                  key={link.label}
                  href={link.href}
                  onClick={() => setMobileOpen(false)}
                  className="block rounded-xl px-4 py-3 text-base font-medium text-text-secondary hover:text-text-primary hover:bg-bg-secondary transition-colors"
                >
                  {link.label}
                </a>
              ))}
              <div className="pt-4 flex flex-col gap-3">
                <button
                  onClick={toggleDarkMode}
                  className="flex items-center gap-3 rounded-xl px-4 py-3 text-base font-medium text-text-secondary hover:text-text-primary hover:bg-bg-secondary transition-colors"
                >
                  {isDark && mounted ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}
                  {isDark && mounted ? "Light Mode" : "Dark Mode"}
                </button>
                <Link
                  href="/login"
                  className="rounded-xl border border-border px-4 py-3 text-center text-sm font-semibold text-text-primary hover:bg-bg-secondary transition-colors"
                >
                  Sign In
                </Link>
                <Link
                  href="/auth/register"
                  className="rounded-xl bg-primary px-4 py-3 text-center text-sm font-bold text-white shadow-lg"
                >
                  Get Started
                </Link>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}

function LandingFooter() {
  const footerSections = [
    {
      title: "Product",
      links: [
        { label: "Features", href: "#features" },
        { label: "Pricing", href: "#pricing" },
        { label: "Security", href: "/security" },
        { label: "Integrations", href: "/integrations" },
        { label: "API", href: "/docs/api" },
      ],
    },
    {
      title: "Resources",
      links: [
        { label: "Documentation", href: "/docs" },
        { label: "Blog", href: "/blog" },
        { label: "Changelog", href: "/changelog" },
        { label: "Status", href: "/status" },
        { label: "Support", href: "/support" },
      ],
    },
    {
      title: "Company",
      links: [
        { label: "About", href: "/about" },
        { label: "Careers", href: "/careers" },
        { label: "Press", href: "/press" },
        { label: "Contact", href: "/contact" },
        { label: "Partners", href: "/partners" },
      ],
    },
    {
      title: "Legal",
      links: [
        { label: "Privacy Policy", href: "/privacy" },
        { label: "Terms of Service", href: "/terms" },
        { label: "Cookie Policy", href: "/cookies" },
        { label: "GDPR", href: "/gdpr" },
      ],
    },
  ];

  const socials = [
    { icon: Globe, href: "#", label: "Website" },
    { icon: Mail, href: "#", label: "Email" },
  ];

  return (
    <footer className="border-t border-border bg-bg-primary">
      <div className="mx-auto max-w-7xl px-6">
        {/* Main footer content */}
        <div className="grid gap-12 py-16 sm:grid-cols-2 lg:grid-cols-6">
          {/* Brand column */}
          <div className="lg:col-span-2">
            <div className="flex items-center gap-2.5 mb-5">
              <Image
                src="/logo/emblem.png"
                alt="SpeakUp"
                width={40}
                height={40}
                className="rounded-xl"
                style={{ width: "auto", height: "auto" }}
              />
              <Image
                src="/logo/logo.png"
                alt="SpeakUp"
                width={120}
                height={32}
                style={{ height: 32, width: "auto" }}
              />
            </div>
            <p className="text-sm text-text-secondary leading-relaxed max-w-xs mb-6">
              The AI-powered video conferencing platform built for modern teams.
              Crystal-clear meetings with intelligent insights.
            </p>
            <div className="flex gap-3">
              {socials.map((social) => (
                <a
                  key={social.label}
                  href={social.href}
                  aria-label={social.label}
                  className="flex h-10 w-10 items-center justify-center rounded-xl border border-border text-text-tertiary hover:text-text-primary hover:border-primary/30 hover:bg-primary/5 transition-all"
                >
                  <social.icon className="h-4 w-4" />
                </a>
              ))}
            </div>
          </div>

          {/* Link columns */}
          {footerSections.map((section) => (
            <div key={section.title}>
              <h4 className="mb-4 text-sm font-bold text-text-primary">
                {section.title}
              </h4>
              <ul className="space-y-3">
                {section.links.map((link) => (
                  <li key={link.label}>
                    <a
                      href={link.href}
                      className="text-sm text-text-tertiary hover:text-text-primary transition-colors"
                    >
                      {link.label}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        {/* Bottom bar */}
        <div className="flex flex-col items-center justify-between gap-4 border-t border-border py-6 sm:flex-row">
          <p className="text-sm text-text-tertiary">
            © {new Date().getFullYear()} {strings.app.name}. All rights reserved.
          </p>
          <div className="flex items-center gap-6">
            <a href="/privacy" className="text-xs text-text-tertiary hover:text-text-primary transition-colors">
              Privacy
            </a>
            <a href="/terms" className="text-xs text-text-tertiary hover:text-text-primary transition-colors">
              Terms
            </a>
            <a href="/cookies" className="text-xs text-text-tertiary hover:text-text-primary transition-colors">
              Cookies
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
}

export default function LandingLayout({ children }: { children: ReactNode }) {
  useEffect(() => {
    let lenis: InstanceType<typeof import("lenis").default> | undefined;
    let raf: number;
    let mounted = true;

    import("lenis").then(({ default: Lenis }) => {
      if (!mounted) return;
      lenis = new Lenis({
        duration: 1.2,
        easing: (t: number) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
        smoothWheel: true,
        touchMultiplier: 1.5,
      });

      function loop(time: number) {
        lenis?.raf(time);
        raf = requestAnimationFrame(loop);
      }
      raf = requestAnimationFrame(loop);
    });

    return () => {
      mounted = false;
      cancelAnimationFrame(raf);
      lenis?.destroy();
    };
  }, []);

  return (
    <>
      <LandingHeader />
      <main className="relative flex-1">{children}</main>
      <LandingFooter />
    </>
  );
}
