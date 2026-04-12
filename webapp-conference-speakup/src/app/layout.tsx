import type { Metadata } from "next";
import { Poppins } from "next/font/google";
import { Providers } from "@/components/providers";
import "./globals.css";

const poppins = Poppins({
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700"],
  variable: "--font-poppins",
});

export const metadata: Metadata = {
  title: "SpeakUp — Video Conferencing, Reimagined",
  description:
    "Experience seamless, high-quality video meetings with screen sharing, real-time chat, and smart scheduling — all in one platform.",
  keywords: ["video conferencing", "meetings", "screen sharing", "chat", "speakup"],
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${poppins.variable} h-full antialiased`} suppressHydrationWarning>
      <head>
        {/* Inline script prevents FOUC by applying theme before paint */}
        <script
          dangerouslySetInnerHTML={{
            __html: `(function(){try{var t=JSON.parse(localStorage.getItem("speakup-theme")||"{}").state?.theme||"system";var d=document.documentElement;d.classList.remove("light","dark");if(t==="system"){d.classList.add(window.matchMedia("(prefers-color-scheme:dark)").matches?"dark":"light")}else{d.classList.add(t)}d.style.colorScheme=d.classList.contains("dark")?"dark":"light"}catch(e){}})()`,
          }}
        />
      </head>
      <body className="min-h-full flex flex-col font-sans">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
