// ============================================================================
// SpeakUp — Terms of Service
// Comprehensive legal terms for the video conferencing platform
// Last updated: 2026-04-06
// ============================================================================

export const termsOfService = {
  title: "Terms of Service",
  effectiveDate: "2026-04-06",
  lastUpdated: "2026-04-06",
  version: "1.0.0",

  sections: [
    // ── 1. Acceptance ──
    {
      id: "acceptance",
      heading: "1. Acceptance of Terms",
      body: `By accessing or using the SpeakUp video conferencing platform ("Service"), you agree to be bound by these Terms of Service ("Terms"). If you are using the Service on behalf of an organization, you represent and warrant that you have the authority to bind that organization to these Terms. If you do not agree to these Terms, you may not access or use the Service.`,
    },

    // ── 2. Service Description ──
    {
      id: "service-description",
      heading: "2. Description of Service",
      body: `SpeakUp is a real-time video conferencing and collaboration platform that provides:`,
      items: [
        "HD video and audio conferencing with up to 1,000 participants",
        "Real-time text chat within meetings and direct messaging",
        "Screen sharing and collaborative presentation tools",
        "Meeting recording, storage, and playback capabilities",
        "Meeting scheduling, calendar integration, and room management",
        "Push notifications and in-app alerts",
        "End-to-end encryption for secure communications",
        "Analytics dashboards for meeting insights and usage tracking",
        "AI-powered features including meeting transcription, smart summaries, and real-time captions (coming soon)",
        "AI assistant for action items, topic extraction, and meeting highlights (planned)",
      ],
    },

    // ── 3. Eligibility ──
    {
      id: "eligibility",
      heading: "3. Eligibility",
      body: `You must be at least 16 years of age to use the Service. By using SpeakUp, you represent and warrant that you meet this age requirement. If you are under 18, you must have the consent of a parent or legal guardian. We reserve the right to request proof of age at any time and to terminate accounts that do not meet the eligibility requirements.`,
    },

    // ── 4. Account Registration ──
    {
      id: "accounts",
      heading: "4. Account Registration & Security",
      body: `To access certain features, you must create an account using Google OAuth or GitHub OAuth authentication. You agree to:`,
      items: [
        "Provide accurate and complete information during registration",
        "Maintain the security of your authentication credentials",
        "Promptly notify us of any unauthorized access to your account",
        "Accept responsibility for all activities that occur under your account",
        "Not share your account credentials or transfer your account to any third party",
        "Enable additional security measures such as biometric authentication when available",
      ],
      footer: `We reserve the right to suspend or terminate accounts that violate these Terms or exhibit suspicious activity. You may delete your account at any time through the app settings.`,
    },

    // ── 5. Subscription Plans ──
    {
      id: "subscriptions",
      heading: "5. Subscription Plans & Billing",
      body: `SpeakUp offers the following subscription tiers:`,
      items: [
        "Free Plan — Up to 50 participants, 60-minute meeting limit, basic features",
        "Pro Plan — Up to 300 participants, 8-hour meetings, recording, priority support",
        "Enterprise Plan — Up to 1,000 participants, unlimited duration, advanced analytics, custom branding, dedicated support, AI features",
      ],
      footer: `Paid subscriptions are billed on a recurring monthly or annual basis through Stripe. You may upgrade, downgrade, or cancel your subscription at any time. Cancellations take effect at the end of the current billing period. Refunds are provided in accordance with applicable law and our refund policy. We reserve the right to modify pricing with 30 days' advance notice.`,
    },

    // ── 6. Acceptable Use ──
    {
      id: "acceptable-use",
      heading: "6. Acceptable Use Policy",
      body: `You agree not to use the Service to:`,
      items: [
        "Violate any applicable local, national, or international law or regulation",
        "Transmit any content that is unlawful, harmful, threatening, abusive, harassing, defamatory, vulgar, obscene, or otherwise objectionable",
        "Impersonate any person or entity or misrepresent your affiliation with a person or entity",
        "Upload or transmit malware, viruses, or any destructive code",
        "Attempt to disrupt, overload, or interfere with the Service's infrastructure",
        "Harvest, scrape, or collect personal data of other users without consent",
        "Use automated bots or scripts to access the Service without our written permission",
        "Circumvent, disable, or otherwise interfere with security-related features",
        "Record meetings without the knowledge and consent of all participants where required by law",
        "Use the Service for cryptocurrency mining, unauthorized data processing, or any illegal commercial purpose",
        "Engage in spam, phishing, or social engineering attacks through the platform",
      ],
      footer: `We reserve the right to investigate violations and take appropriate action, including suspending or terminating your account and reporting illegal activity to law enforcement authorities.`,
    },

    // ── 7. Intellectual Property ──
    {
      id: "intellectual-property",
      heading: "7. Intellectual Property Rights",
      body: `The Service, including its source code, design, logos, trademarks, and all associated content, is the exclusive property of SpeakUp and its licensors. You are granted a limited, non-exclusive, non-transferable, revocable license to use the Service in accordance with these Terms. You may not copy, modify, distribute, sell, lease, or create derivative works based on the Service without our express written consent. All user-generated content (messages, recordings, files) remains the property of the respective user or organization. By uploading content, you grant SpeakUp a limited license to process and store it solely for the purpose of providing the Service.`,
    },

    // ── 8. Meeting Recordings ──
    {
      id: "recordings",
      heading: "8. Meeting Recordings & Content",
      body: `When recording is enabled during a meeting:`,
      items: [
        "All participants are notified that recording is in progress via a visible indicator",
        "The meeting host is responsible for obtaining consent from all participants before recording",
        "Recordings are stored securely using industry-standard encryption",
        "Recordings are accessible only to the meeting host and authorized participants",
        "You may download or delete your recordings at any time",
        "Recordings on the Free plan are retained for 7 days; Pro and Enterprise plans have extended retention",
        "We do not access, review, or use your recording content for advertising or training purposes",
      ],
      footer: `You are solely responsible for compliance with applicable recording consent laws in your jurisdiction (e.g., two-party consent laws). SpeakUp is not liable for any unauthorized recording by participants.`,
    },

    // ── 9. AI Features ──
    {
      id: "ai-features",
      heading: "9. AI-Powered Features (Current & Planned)",
      body: `SpeakUp incorporates and plans to expand artificial intelligence features, including:`,
      items: [
        "Real-time meeting transcription and closed captions",
        "AI-generated meeting summaries and action items",
        "Smart topic detection and agenda tracking",
        "Intelligent noise suppression and audio enhancement",
        "AI assistant for searching meeting history and extracting insights",
        "Automated meeting highlights and key moment detection",
        "Sentiment analysis and engagement scoring for meeting analytics",
        "Smart scheduling suggestions based on participant availability",
      ],
      footer: `AI features process data in real time and do not permanently store transcription data beyond the meeting session unless you explicitly enable recording. AI models are designed to operate with minimal data retention. Enterprise customers can opt out of AI processing entirely. AI-generated outputs are provided as-is and should be reviewed for accuracy.`,
    },

    // ── 10. Privacy ──
    {
      id: "privacy",
      heading: "10. Privacy & Data Protection",
      body: `Your privacy is important to us. Our collection, use, and protection of your personal data is governed by our Privacy Policy, which is incorporated by reference into these Terms. By using the Service, you consent to the data practices described in the Privacy Policy. We are committed to compliance with GDPR, CCPA, and other applicable data protection regulations.`,
    },

    // ── 11. Security ──
    {
      id: "security",
      heading: "11. Security Measures",
      body: `SpeakUp employs industry-standard security measures to protect your data:`,
      items: [
        "End-to-end encryption for video, audio, and chat communications",
        "TLS 1.3 encryption for all data in transit",
        "AES-256 encryption for data at rest",
        "SOC 2 Type II compliance (in progress)",
        "Regular third-party security audits and penetration testing",
        "Firebase Authentication with OAuth 2.0 for secure sign-in",
        "Rate limiting and DDoS protection via Cloudflare",
        "Automated threat detection and anomaly monitoring",
        "Secure WebSocket connections for real-time communications",
        "Role-based access control for meeting management",
      ],
      footer: `While we take extensive measures to protect your data, no method of electronic transmission or storage is 100% secure. We cannot guarantee absolute security.`,
    },

    // ── 12. Service Availability ──
    {
      id: "availability",
      heading: "12. Service Availability & SLA",
      body: `We strive to maintain 99.9% uptime for the Service. However, we do not guarantee uninterrupted access. The Service may be temporarily unavailable due to:`,
      items: [
        "Scheduled maintenance (announced at least 48 hours in advance)",
        "Emergency security patches or critical updates",
        "Force majeure events beyond our reasonable control",
        "Third-party service outages (cloud providers, CDN, DNS)",
      ],
      footer: `Enterprise customers receive a Service Level Agreement (SLA) with specific uptime guarantees and remedies for downtime. We will make reasonable efforts to notify users of planned outages.`,
    },

    // ── 13. Third-Party Services ──
    {
      id: "third-party",
      heading: "13. Third-Party Integrations",
      body: `The Service integrates with and relies upon third-party services including:`,
      items: [
        "Google Firebase — Authentication, push notifications, and analytics",
        "LiveKit — Real-time video and audio infrastructure",
        "Stripe — Payment processing and subscription billing",
        "Cloudinary — Media storage and optimization",
        "Redis / BullMQ — Background job processing and caching",
        "Apache Kafka — Event streaming and real-time data pipelines",
        "PostgreSQL — Primary data storage",
        "Cloudflare — CDN, DDoS protection, and DNS management",
        "Sentry — Error tracking and monitoring",
        "Prometheus / Grafana — System observability and metrics",
      ],
      footer: `Your use of third-party services is subject to their respective terms and privacy policies. We are not responsible for the practices or content of third-party services.`,
    },

    // ── 14. Limitation of Liability ──
    {
      id: "liability",
      heading: "14. Limitation of Liability",
      body: `To the maximum extent permitted by applicable law, SpeakUp and its affiliates, officers, directors, employees, and agents shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to loss of profits, data, use, goodwill, or other intangible losses, resulting from: (a) your access to or use of (or inability to access or use) the Service; (b) any conduct or content of any third party on the Service; (c) any content obtained from the Service; (d) unauthorized access, use, or alteration of your transmissions or content. Our total aggregate liability for all claims arising out of or relating to the Service shall not exceed the greater of the amount you paid us in the twelve (12) months preceding the claim or fifty US dollars ($50).`,
    },

    // ── 15. Disclaimer of Warranties ──
    {
      id: "warranties",
      heading: "15. Disclaimer of Warranties",
      body: `The Service is provided on an "AS IS" and "AS AVAILABLE" basis without warranties of any kind, whether express or implied, including but not limited to implied warranties of merchantability, fitness for a particular purpose, non-infringement, and any warranties arising out of course of dealing or usage of trade. We do not warrant that the Service will be uninterrupted, timely, secure, or error-free, or that defects will be corrected.`,
    },

    // ── 16. Indemnification ──
    {
      id: "indemnification",
      heading: "16. Indemnification",
      body: `You agree to indemnify, defend, and hold harmless SpeakUp and its affiliates, officers, directors, employees, and agents from and against any and all claims, damages, obligations, losses, liabilities, costs, and expenses (including reasonable attorneys' fees) arising from: (a) your use of and access to the Service; (b) your violation of any term of these Terms; (c) your violation of any third-party right, including any intellectual property, publicity, or privacy right; (d) your user content or any content uploaded through your account.`,
    },

    // ── 17. Termination ──
    {
      id: "termination",
      heading: "17. Termination",
      body: `Either party may terminate these Terms at any time. You may terminate by deleting your account through the app settings or contacting our support team. We may terminate or suspend your access immediately, without prior notice, if we reasonably believe you have violated these Terms. Upon termination:`,
      items: [
        "Your right to access and use the Service ceases immediately",
        "We may delete your account data after a 30-day grace period",
        "Recordings and files will be made available for download during the grace period",
        "Provisions that by their nature should survive termination will survive (including intellectual property, limitation of liability, indemnification, and dispute resolution)",
      ],
    },

    // ── 18. Dispute Resolution ──
    {
      id: "disputes",
      heading: "18. Dispute Resolution",
      body: `Any dispute arising from or relating to these Terms or the Service shall first be attempted to be resolved through informal negotiation. If the dispute cannot be resolved through negotiation within 30 days, it shall be resolved through binding arbitration under the rules of the American Arbitration Association (AAA). The arbitration shall be conducted in English. Each party shall bear its own costs. Class action lawsuits, class-wide arbitrations, and representative actions are not permitted. Nothing in this section prevents either party from seeking injunctive relief in a court of competent jurisdiction.`,
    },

    // ── 19. Changes to Terms ──
    {
      id: "changes",
      heading: "19. Changes to These Terms",
      body: `We reserve the right to modify these Terms at any time. Material changes will be communicated via email notification and/or in-app announcement at least 30 days before taking effect. Your continued use of the Service after changes become effective constitutes acceptance of the revised Terms. If you do not agree to the revised Terms, you must discontinue use of the Service and delete your account.`,
    },

    // ── 20. Governing Law ──
    {
      id: "governing-law",
      heading: "20. Governing Law",
      body: `These Terms shall be governed by and construed in accordance with the laws of the State of Delaware, United States, without regard to its conflict of law principles. Any legal proceedings shall be brought in the state or federal courts located in Delaware.`,
    },

    // ── 21. Miscellaneous ──
    {
      id: "miscellaneous",
      heading: "21. General Provisions",
      body: `These Terms constitute the entire agreement between you and SpeakUp regarding the Service. If any provision of these Terms is found to be unenforceable, the remaining provisions will remain in full force and effect. Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights. Any waiver of any provision will only be effective if in writing and signed by us. You may not assign or transfer these Terms without our prior written consent. We may assign these Terms without restriction.`,
    },

    // ── 22. Contact ──
    {
      id: "contact",
      heading: "22. Contact Information",
      body: `If you have any questions about these Terms of Service, please contact us:`,
      items: [
        "Email: legal@speakup.app",
        "Support: support@speakup.app",
        "Website: https://speakup.app/legal",
      ],
    },
  ],
};

export default termsOfService;
