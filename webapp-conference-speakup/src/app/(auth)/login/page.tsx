"use client";

import { Button } from "@/components/ui";
import { strings } from "@/config/strings";
import { useGoogleSignIn, useGithubSignIn } from "@/hooks/use-auth";
import Image from "next/image";

export default function LoginPage() {
  const { mutate: googleSignIn, isPending: googlePending } = useGoogleSignIn();
  const { mutate: githubSignIn, isPending: githubPending } = useGithubSignIn();

  const isLoading = googlePending || githubPending;

  return (
    <div className="space-y-8">
      {/* Mobile logo */}
      <div className="flex flex-col items-center lg:hidden mb-4">
        <Image
          src="/logo/emblem.png"
          alt="SpeakUp"
          width={56}
          height={56}
          className="mb-3"
          style={{ width: "auto", height: "auto" }}
          priority
        />
        <h1 className="text-xl font-bold text-text-primary">{strings.app.name}</h1>
      </div>

      <div className="text-center lg:text-left">
        <h2 className="text-2xl font-bold text-text-primary">{strings.auth.loginTitle}</h2>
        <p className="mt-2 text-text-secondary">{strings.auth.loginSubtitle}</p>
      </div>

      <div className="space-y-4">
        <Button
          variant="outline"
          className="w-full h-[52px] gap-3 text-sm font-medium"
          onClick={() => googleSignIn()}
          disabled={isLoading}
          loading={googlePending}
        >
          <Image src="/logo/google.webp" alt="Google" width={20} height={20} style={{ width: 20, height: 20 }} />
          {strings.auth.signInWithGoogle}
        </Button>

        <Button
          variant="outline"
          className="w-full h-[52px] gap-3 text-sm font-medium"
          onClick={() => githubSignIn()}
          disabled={isLoading}
          loading={githubPending}
        >
          <Image src="/logo/github.webp" alt="GitHub" width={20} height={20} style={{ width: 20, height: 20 }} />
          {strings.auth.signInWithGithub}
        </Button>
      </div>

      <p className="text-center text-xs text-text-secondary">
        By continuing, you agree to our{" "}
        <a href="#" className="text-primary hover:underline">Terms of Service</a>{" "}
        and{" "}
        <a href="#" className="text-primary hover:underline">Privacy Policy</a>.
      </p>
    </div>
  );
}
