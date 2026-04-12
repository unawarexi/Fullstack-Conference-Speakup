"use client";

import { useRef, useState, useEffect, type ReactNode } from "react";

/**
 * Wraps a landing page section and defers rendering until
 * the element is within `rootMargin` of the viewport.
 * Once activated it stays mounted (no unmounting on scroll-away).
 */
export function LazySection({
  children,
  className = "",
  fallback,
  rootMargin = "200px",
}: {
  children: ReactNode;
  className?: string;
  fallback?: ReactNode;
  rootMargin?: string;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setVisible(true);
          observer.disconnect();
        }
      },
      { rootMargin }
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, [rootMargin]);

  return (
    <div ref={ref} className={className}>
      {visible
        ? children
        : (fallback ?? <div className="min-h-[60vh]" />)}
    </div>
  );
}
