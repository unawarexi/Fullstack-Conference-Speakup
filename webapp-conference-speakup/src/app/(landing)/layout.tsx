"use client";

import Link from "next/link";
import { Button } from "@/components/ui";
import { strings } from "@/config/strings";
import { Video } from "lucide-react";
import type { ReactNode } from "react";

function LandingHeader() {
  return (
    <header className="sticky top-0 z-40 border-b border-border/50 bg-card/80 backdrop-blur-lg">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-6">
        <Link href="/" className="flex items-center gap-2">
          <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary">
            <Video className="h-5 w-5 text-white" />
          </div>
          <span className="text-lg font-bold text-textPrimary">{strings.app.name}</span>
        </Link>

        <nav className="hidden items-center gap-8 md:flex">
          <a href="#features" className="text-sm text-textSecondary hover:text-textPrimary transition-colors">
            Features
          </a>
          <a href="#pricing" className="text-sm text-textSecondary hover:text-textPrimary transition-colors">
            Pricing
          </a>
        </nav>

        <div className="flex items-center gap-3">
          <Link href="/login">
            <Button variant="ghost" size="sm">Sign In</Button>
          </Link>
          <Link href="/login">
            <Button size="sm">Get Started</Button>
          </Link>
        </div>
      </div>
    </header>
  );
}

function LandingFooter() {
  return (
    <footer className="border-t border-border bg-surface">
      <div className="mx-auto max-w-7xl px-6 py-12">
        <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
          <div>
            <div className="flex items-center gap-2 mb-4">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary">
                <Video className="h-4 w-4 text-white" />
              </div>
              <span className="font-bold text-textPrimary">{strings.app.name}</span>
            </div>
            <p className="text-sm text-textSecondary">{strings.app.tagline}</p>
          </div>
          <div>
            <h4 className="mb-3 text-sm font-semibold text-textPrimary">Product</h4>
            <ul className="space-y-2 text-sm text-textSecondary">
              <li><a href="#features" className="hover:text-primary transition-colors">Features</a></li>
              <li><a href="#pricing" className="hover:text-primary transition-colors">Pricing</a></li>
              <li><a href="#" className="hover:text-primary transition-colors">Security</a></li>
            </ul>
          </div>
          <div>
            <h4 className="mb-3 text-sm font-semibold text-textPrimary">Company</h4>
            <ul className="space-y-2 text-sm text-textSecondary">
              <li><a href="#" className="hover:text-primary transition-colors">About</a></li>
              <li><a href="#" className="hover:text-primary transition-colors">Blog</a></li>
              <li><a href="#" className="hover:text-primary transition-colors">Careers</a></li>
            </ul>
          </div>
          <div>
            <h4 className="mb-3 text-sm font-semibold text-textPrimary">Legal</h4>
            <ul className="space-y-2 text-sm text-textSecondary">
              <li><a href="#" className="hover:text-primary transition-colors">Privacy Policy</a></li>
              <li><a href="#" className="hover:text-primary transition-colors">Terms of Service</a></li>
            </ul>
          </div>
        </div>
        <div className="mt-10 border-t border-border pt-6 text-center text-sm text-textSecondary">
          © {new Date().getFullYear()} {strings.app.name}. All rights reserved.
        </div>
      </div>
    </footer>
  );
}

export default function LandingLayout({ children }: { children: ReactNode }) {
  return (
    <>
      <LandingHeader />
      <main className="flex-1">{children}</main>
      <LandingFooter />
    </>
  );
}
