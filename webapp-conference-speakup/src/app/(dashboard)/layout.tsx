"use client";

import Link from "next/link";
import Image from "next/image";
import { usePathname } from "next/navigation";
import { useState, useEffect } from "react";
import { cn } from "@/lib/utils";
import { Avatar, CountBadge, Dropdown, DropdownItem } from "@/components/ui";
import { strings } from "@/config/strings";
import { useCurrentUser, useSignOut } from "@/hooks/use-auth";
import { useUnreadCount } from "@/hooks/use-notifications";
import { useThemeStore } from "@/store/theme-store";
import { motion, AnimatePresence } from "framer-motion";
import {
  Bell,
  Home,
  MessageSquare,
  Moon,
  Settings,
  Sun,
  LogOut,
  Calendar,
  Disc,
  BarChart3,
  CreditCard,
  Search,
  Sparkles,
} from "lucide-react";
import type { ReactNode } from "react";

const navItems = [
  { href: "/home", label: "Home", icon: Home },
  { href: "/meetings", label: "Meetings", icon: Calendar },
  { href: "/chat", label: "Chat", icon: MessageSquare },
  { href: "/recordings", label: "Recordings", icon: Disc },
  { href: "/ai", label: "AI Assistant", icon: Sparkles },
  { href: "/analytics", label: "Analytics", icon: BarChart3 },
  { href: "/search", label: "Search", icon: Search },
  { href: "/billing", label: "Billing", icon: CreditCard },
  { href: "/notifications", label: "Notifications", icon: Bell },
  { href: "/settings", label: "Settings", icon: Settings },
];

function Sidebar() {
  const pathname = usePathname();
  const { data: unread } = useUnreadCount();

  return (
    <aside className="hidden lg:flex lg:w-64 flex-col border-r border-border bg-card">
      {/* Logo */}
      <div className="flex h-16 items-center gap-2.5 px-6 border-b border-border">
        <Image
          src="/logo/emblem.png"
          alt="SpeakUp"
          width={36}
          height={36}
          style={{ width: "auto", height: "auto" }}
          className="rounded-xl"
        />
        <span className="text-lg font-bold text-text-primary">{strings.app.name}</span>
      </div>

      {/* Nav */}
      <nav className="flex-1 overflow-y-auto p-4 space-y-1">
        {navItems.map((item) => {
          const isActive = pathname.startsWith(item.href);
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-colors",
                isActive
                  ? "bg-primary/10 text-primary"
                  : "text-text-secondary hover:bg-elevated hover:text-text-primary"
              )}
            >
              <item.icon className="h-5 w-5" />
              <span className="flex-1">{item.label}</span>
              {item.href === "/notifications" && unread ? (
                <CountBadge count={unread} />
              ) : null}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}

function TopBar() {
  const { data: user } = useCurrentUser();
  const { mutate: signOut } = useSignOut();
  const resolvedTheme = useThemeStore((s) => s.resolvedTheme);
  const toggleDarkMode = useThemeStore((s) => s.toggleDarkMode);
  const pathname = usePathname();
  const { data: unread } = useUnreadCount();
  const [mounted, setMounted] = useState(false);

  useEffect(() => { setMounted(true); }, []);

  const isDark = mounted && resolvedTheme === "dark";
  const pageTitle = navItems.find((n) => pathname.startsWith(n.href))?.label ?? "";

  return (
    <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-border bg-card/80 backdrop-blur-lg px-6">
      {/* Mobile logo */}
      <div className="flex items-center gap-3 lg:hidden">
        <Image
          src="/logo/emblem.png"
          alt="SpeakUp"
          width={32}
          height={32}
          style={{ width: "auto", height: "auto" }}
          className="rounded-lg"
        />
      </div>

      <h1 className="hidden lg:block text-lg font-semibold text-text-primary">{pageTitle}</h1>

      <div className="flex items-center gap-3">
        {/* Theme toggle */}
        <button
          onClick={toggleDarkMode}
          aria-label="Toggle theme"
          className="flex h-9 w-9 items-center justify-center rounded-xl text-text-secondary hover:bg-elevated transition-colors"
        >
          {mounted && (
            <AnimatePresence mode="wait" initial={false}>
              {isDark ? (
                <motion.div
                  key="sun"
                  initial={{ scale: 0, rotate: -90 }}
                  animate={{ scale: 1, rotate: 0 }}
                  exit={{ scale: 0, rotate: 90 }}
                  transition={{ duration: 0.15 }}
                >
                  <Sun className="h-5 w-5" />
                </motion.div>
              ) : (
                <motion.div
                  key="moon"
                  initial={{ scale: 0, rotate: 90 }}
                  animate={{ scale: 1, rotate: 0 }}
                  exit={{ scale: 0, rotate: -90 }}
                  transition={{ duration: 0.15 }}
                >
                  <Moon className="h-5 w-5" />
                </motion.div>
              )}
            </AnimatePresence>
          )}
        </button>

        {/* Notifications */}
        <Link
          href="/notifications"
          className="relative flex h-9 w-9 items-center justify-center rounded-xl text-text-secondary hover:bg-elevated transition-colors lg:hidden"
        >
          <Bell className="h-5 w-5" />
          {unread ? (
            <span className="absolute -top-0.5 -right-0.5">
              <CountBadge count={unread} />
            </span>
          ) : null}
        </Link>

        {/* Profile dropdown */}
        <Dropdown
          align="right"
          trigger={
            <Avatar
              src={user?.avatar}
              name={user?.name}
              size="sm"
              className="cursor-pointer"
            />
          }
        >
          <div className="px-3 py-2 border-b border-border mb-1">
            <p className="text-sm font-medium text-text-primary">{user?.name}</p>
            <p className="text-xs text-text-secondary truncate">{user?.email}</p>
          </div>
          <DropdownItem icon={<Settings className="h-4 w-4" />} onClick={() => {}}>
            <Link href="/settings">Settings</Link>
          </DropdownItem>
          <DropdownItem icon={<LogOut className="h-4 w-4" />} danger onClick={() => signOut()}>
            Sign Out
          </DropdownItem>
        </Dropdown>
      </div>
    </header>
  );
}

function MobileNav() {
  const pathname = usePathname();
  const mobileItems = [navItems[0], navItems[1], navItems[2], navItems[4], navItems[8]]; // Home, Meetings, Chat, AI, Notifications

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-40 flex border-t border-border bg-card lg:hidden">
      {mobileItems.map((item) => {
        const isActive = pathname.startsWith(item.href);
        return (
          <Link
            key={item.href}
            href={item.href}
            className={cn(
              "flex flex-1 flex-col items-center gap-0.5 py-2 text-[10px] font-medium transition-colors",
              isActive ? "text-primary" : "text-text-secondary"
            )}
          >
            <item.icon className="h-5 w-5" />
            <span>{item.label}</span>
          </Link>
        );
      })}
    </nav>
  );
}

export default function DashboardLayout({ children }: { children: ReactNode }) {
  return (
    <div className="flex h-screen bg-background">
      <Sidebar />
      <div className="flex flex-1 flex-col overflow-hidden">
        <TopBar />
        <main className="flex-1 overflow-y-auto pb-20 lg:pb-0">{children}</main>
        <MobileNav />
      </div>
    </div>
  );
}
