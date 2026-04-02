"use client";

import { useState, useEffect } from "react";
import { BREAKPOINTS } from "@/config/constants";

type Breakpoint = "mobile" | "tablet" | "desktop" | "widescreen";

export function useBreakpoint(): Breakpoint {
  const [bp, setBp] = useState<Breakpoint>("desktop");

  useEffect(() => {
    function update() {
      const w = window.innerWidth;
      if (w < BREAKPOINTS.mobile) setBp("mobile");
      else if (w < BREAKPOINTS.tablet) setBp("tablet");
      else if (w < BREAKPOINTS.desktop) setBp("desktop");
      else setBp("widescreen");
    }
    update();
    window.addEventListener("resize", update);
    return () => window.removeEventListener("resize", update);
  }, []);

  return bp;
}

export function useIsMobile() {
  const bp = useBreakpoint();
  return bp === "mobile" || bp === "tablet";
}
