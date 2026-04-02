import { Video } from "lucide-react";
import { strings } from "@/config/strings";
import type { ReactNode } from "react";

export default function AuthLayout({ children }: { children: ReactNode }) {
  return (
    <div className="flex min-h-screen">
      {/* Left panel — branding */}
      <div className="hidden lg:flex lg:w-1/2 items-center justify-center bg-gradient-to-br from-primary to-primary/80 p-12">
        <div className="max-w-md text-center text-white">
          <div className="mx-auto mb-8 flex h-20 w-20 items-center justify-center rounded-3xl bg-white/20 backdrop-blur-sm">
            <Video className="h-10 w-10 text-white" />
          </div>
          <h1 className="mb-4 text-4xl font-bold">{strings.app.name}</h1>
          <p className="text-lg text-white/80">{strings.app.tagline}</p>
        </div>
      </div>

      {/* Right panel — form */}
      <div className="flex w-full items-center justify-center p-6 lg:w-1/2 bg-background">
        <div className="w-full max-w-md">{children}</div>
      </div>
    </div>
  );
}
