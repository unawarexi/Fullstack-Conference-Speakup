// ============================================================================
// SpeakUp — Privacy Policy
// Comprehensive privacy policy for the video conferencing platform
// Last updated: 2026-04-06
// ============================================================================

export const privacyPolicy = {
  title: "Privacy Policy",
  effectiveDate: "2026-04-06",
  lastUpdated: "2026-04-06",
  version: "1.0.0",

  sections: [
    // ── 1. Introduction ──
    {
      id: "introduction",
      heading: "1. Introduction",
      body: `SpeakUp ("we", "us", or "our") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your personal information when you use our video conferencing platform and related services (the "Service"). By using the Service, you consent to the data practices described in this policy. This policy applies to all users worldwide and is designed to comply with GDPR (EU), CCPA (California), PIPEDA (Canada), LGPD (Brazil), and other applicable data protection regulations.`,
    },

    // ── 2. Information We Collect ──
    {
      id: "info-collected",
      heading: "2. Information We Collect",
      body: `We collect the following categories of information:`,
      subsections: [
        {
          heading: "2.1 Information You Provide",
          items: [
            "Account information — Name, email address, profile photo (provided via Google or GitHub OAuth)",
            "Profile data — Bio, display name, and avatar that you choose to add or update",
            "Meeting content — Chat messages, shared files, and uploaded media during meetings",
            "Recordings — Audio and video recordings when you enable the recording feature",
            "Payment information — Billing details processed securely through Stripe (we do not store card numbers)",
            "Support communications — Messages, emails, and feedback you send to our support team",
            "Survey responses — Feedback and preferences you voluntarily share",
          ],
        },
        {
          heading: "2.2 Information Collected Automatically",
          items: [
            "Device information — Device model, operating system, unique device identifiers, browser type",
            "Usage data — Features used, meeting duration, frequency, participant counts, and interaction patterns",
            "Log data — IP address, access timestamps, referral URLs, pages viewed, crash reports",
            "Network data — Connection quality metrics, bandwidth, latency measurements for call optimization",
            "Location data — Approximate geographic location derived from IP address (not precise GPS)",
            "Cookies and similar technologies — Session identifiers, preferences, and analytics tokens",
            "Performance data — App load times, error rates, and API response times for service reliability",
          ],
        },
        {
          heading: "2.3 Information from Third Parties",
          items: [
            "Google OAuth — Name, email, profile photo, and unique Google identifier",
            "GitHub OAuth — Username, email, avatar URL, and unique GitHub identifier",
            "Firebase — Authentication tokens, push notification tokens (FCM), and crash analytics",
            "Stripe — Subscription status, payment history, and billing events (no card details)",
            "Analytics providers — Aggregated usage patterns and demographic insights",
          ],
        },
      ],
    },

    // ── 3. How We Use Your Information ──
    {
      id: "how-we-use",
      heading: "3. How We Use Your Information",
      body: `We use the collected information for the following purposes:`,
      items: [
        "Service delivery — Providing, maintaining, and improving the video conferencing platform",
        "Authentication — Verifying your identity and securing your account via Firebase + OAuth",
        "Communication — Sending transactional emails (welcome, meeting invites, receipts) and service announcements",
        "Meeting facilitation — Connecting participants, managing rooms, enabling chat and screen sharing",
        "Recording & storage — Processing, encrypting, and storing meeting recordings as requested by the host",
        "Billing — Processing subscription payments, generating invoices, and managing plan upgrades/downgrades",
        "Analytics — Generating meeting insights, usage dashboards, and engagement metrics for hosts",
        "Security — Detecting and preventing fraud, abuse, and unauthorized access through rate limiting and anomaly detection",
        "Performance optimization — Monitoring system health, optimizing video quality, and reducing latency",
        "Customer support — Responding to requests, troubleshooting issues, and providing technical assistance",
        "Legal compliance — Meeting regulatory obligations and responding to lawful requests from authorities",
        "AI features — Powering transcription, summaries, captions, and intelligent search (with user consent)",
        "Product improvement — Analyzing aggregated, anonymized usage data to enhance features and user experience",
        "Push notifications — Delivering real-time meeting reminders, chat notifications, and system alerts via FCM",
      ],
    },

    // ── 4. Legal Basis for Processing ──
    {
      id: "legal-basis",
      heading: "4. Legal Basis for Processing (GDPR)",
      body: `For users in the European Economic Area (EEA), we process personal data under the following legal bases:`,
      items: [
        "Contractual necessity — Processing required to provide the Service (account creation, meeting hosting, billing)",
        "Legitimate interests — Analytics, security monitoring, fraud prevention, and service improvement",
        "Consent — Optional features such as AI transcription, marketing communications, and cookies",
        "Legal obligation — Tax records, regulatory reporting, and responding to lawful data access requests",
      ],
      footer: `You may withdraw consent at any time for consent-based processing without affecting the lawfulness of prior processing.`,
    },

    // ── 5. Data Sharing ──
    {
      id: "data-sharing",
      heading: "5. How We Share Your Information",
      body: `We do not sell your personal information. We share data only in the following limited circumstances:`,
      items: [
        "Service providers — Trusted third-party vendors who assist in operating the Service (hosting, payment processing, email delivery, analytics) under strict data processing agreements",
        "Meeting participants — Your display name, avatar, and online status are visible to other meeting participants",
        "With your consent — When you explicitly authorize sharing (e.g., enabling calendar integrations)",
        "Legal requirements — When required by law, regulation, legal process, or governmental request",
        "Business transfers — In connection with a merger, acquisition, or sale of assets (with prior notice)",
        "Safety — When necessary to protect the rights, property, or safety of SpeakUp, our users, or the public",
        "Aggregated data — Non-identifiable, aggregated statistics may be shared for industry reports or research",
      ],
      footer: `All third-party service providers are contractually bound to process data only as instructed and to maintain appropriate security measures.`,
    },

    // ── 6. Data Retention ──
    {
      id: "data-retention",
      heading: "6. Data Retention",
      body: `We retain your personal data only for as long as necessary to fulfill the purposes outlined in this policy:`,
      items: [
        "Account data — Retained for the lifetime of your account plus 30 days after deletion",
        "Meeting metadata — Retained for 12 months after the meeting for analytics purposes",
        "Chat messages — Retained for 90 days after the associated meeting ends",
        "Recordings — Free plan: 7 days; Pro plan: 6 months; Enterprise plan: as configured (up to unlimited)",
        "Payment records — Retained for 7 years as required by tax and financial regulations",
        "Log data — Automatically purged after 90 days",
        "AI-processed data — Transcriptions and summaries are deleted within 24 hours unless recording is enabled",
        "Analytics data — Aggregated and anonymized after 12 months",
        "Support tickets — Retained for 2 years after resolution for quality assurance",
      ],
      footer: `When data reaches the end of its retention period, it is securely deleted or anonymized. You can request earlier deletion of your data at any time (see Section 8).`,
    },

    // ── 7. Data Security ──
    {
      id: "data-security",
      heading: "7. Data Security",
      body: `We take the security of your data seriously and implement comprehensive measures:`,
      items: [
        "Encryption in transit — All data transmitted between your device and our servers uses TLS 1.3",
        "Encryption at rest — Stored data is encrypted using AES-256 encryption",
        "End-to-end encryption — Video, audio, and chat streams are encrypted end-to-end during meetings",
        "Access controls — Strict role-based access controls limit employee access to user data",
        "Infrastructure security — Hosted on hardened cloud infrastructure with Cloudflare DDoS protection",
        "Authentication — Firebase OAuth 2.0 with token-based session management and automatic token rotation",
        "Monitoring — Real-time threat detection using Sentry error tracking and Prometheus alerting",
        "Penetration testing — Regular third-party security assessments and vulnerability scanning",
        "Incident response — Documented incident response procedures with 72-hour breach notification (GDPR)",
        "Backup — Encrypted daily backups with geographic redundancy and tested recovery procedures",
        "Rate limiting — API rate limiting to prevent brute-force and abuse attacks",
        "Input validation — Server-side validation with Zod schemas to prevent injection attacks",
      ],
      footer: `Despite our security measures, no system is completely immune to threats. We encourage you to use strong, unique credentials and enable biometric authentication where available.`,
    },

    // ── 8. Your Rights ──
    {
      id: "your-rights",
      heading: "8. Your Rights",
      body: `Depending on your jurisdiction, you have the following rights regarding your personal data:`,
      items: [
        "Access — Request a copy of the personal data we hold about you",
        "Rectification — Request correction of inaccurate or incomplete personal data",
        "Erasure — Request deletion of your personal data ('Right to be Forgotten')",
        "Portability — Receive your data in a structured, machine-readable format (JSON export)",
        "Restriction — Request temporary restriction of processing your data",
        "Objection — Object to processing based on legitimate interests, including profiling",
        "Withdraw consent — Withdraw previously given consent at any time without affecting prior processing",
        "Non-discrimination — Exercise your rights without receiving discriminatory treatment (CCPA)",
        "Opt out of AI — Disable AI-powered features including transcription and analytics",
        "Account deletion — Delete your account and all associated data through the app settings",
      ],
      footer: `To exercise any of these rights, contact us at privacy@speakup.app or use the in-app privacy settings. We will respond within 30 days (or sooner as required by law). We may request identity verification before processing your request.`,
    },

    // ── 9. Cookies ──
    {
      id: "cookies",
      heading: "9. Cookies & Tracking Technologies",
      body: `We use the following tracking technologies:`,
      items: [
        "Essential cookies — Required for authentication, session management, and security (cannot be disabled)",
        "Analytics cookies — Help us understand how users interact with the Service (can be disabled)",
        "Performance cookies — Monitor system health and optimize video call quality",
        "Firebase tokens — Used for push notification delivery and crash reporting",
        "Local storage — Stores user preferences, theme settings, and cached data for offline access",
      ],
      footer: `You can manage cookie preferences through your browser settings or our in-app privacy controls. Disabling certain cookies may limit the Service's functionality.`,
    },

    // ── 10. Children's Privacy ──
    {
      id: "children",
      heading: "10. Children's Privacy",
      body: `SpeakUp is not directed at children under the age of 16. We do not knowingly collect personal information from children under 16. If we become aware that we have collected data from a child under 16 without parental consent, we will take steps to delete that information as quickly as possible. If you believe a child under 16 has provided us with personal information, please contact us at privacy@speakup.app.`,
    },

    // ── 11. International Transfers ──
    {
      id: "international-transfers",
      heading: "11. International Data Transfers",
      body: `Your data may be processed in countries other than your country of residence. We ensure appropriate safeguards for international transfers:`,
      items: [
        "Standard Contractual Clauses (SCCs) approved by the European Commission",
        "Data Processing Agreements (DPAs) with all third-party processors",
        "Adequacy decisions where applicable",
        "Additional technical and organizational measures as recommended by supervisory authorities",
      ],
      footer: `By using the Service, you acknowledge that your data may be transferred to and processed in the United States and other countries where our service providers operate.`,
    },

    // ── 12. AI & Automated Decisions ──
    {
      id: "ai-processing",
      heading: "12. AI Processing & Automated Decision-Making",
      body: `SpeakUp uses AI technologies to enhance the conferencing experience:`,
      items: [
        "Meeting transcription — Speech-to-text processing during meetings (opt-in per meeting)",
        "Smart summaries — AI-generated meeting recaps, action items, and key decisions",
        "Noise suppression — AI-powered background noise removal for clearer audio",
        "Engagement analytics — Anonymized sentiment and participation metrics for meeting hosts",
        "Search — AI-powered search across meeting history, transcripts, and chat messages",
        "Captions — Real-time closed captions for accessibility",
      ],
      footer: `AI processing is performed in real time and data is not retained after the session unless recording is enabled. You can opt out of AI features at the meeting or account level. No automated decisions are made that produce legal or similarly significant effects on you without human review.`,
    },

    // ── 13. California Privacy Rights ──
    {
      id: "ccpa",
      heading: "13. California Privacy Rights (CCPA/CPRA)",
      body: `California residents have additional rights under the CCPA/CPRA:`,
      items: [
        "Right to know — Request disclosure of data collected, used, shared, or sold in the past 12 months",
        "Right to delete — Request deletion of personal information with certain exceptions",
        "Right to opt out of sale — We do not sell personal information",
        "Right to non-discrimination — Equal service regardless of privacy rights exercised",
        "Right to correct — Request correction of inaccurate personal information",
        "Right to limit use of sensitive data — Restrict processing of sensitive personal information",
      ],
      footer: `To exercise these rights, contact us at privacy@speakup.app or use the in-app privacy controls. We will verify your identity before processing any request.`,
    },

    // ── 14. Changes ──
    {
      id: "changes",
      heading: "14. Changes to This Privacy Policy",
      body: `We may update this Privacy Policy from time to time to reflect changes in our practices, technology, legal requirements, or other factors. Material changes will be communicated via email and/or in-app notification at least 30 days before taking effect. The "Last Updated" date at the top of this policy indicates when it was last revised. Your continued use of the Service after changes become effective constitutes acceptance of the updated policy.`,
    },

    // ── 15. Data Protection Officer ──
    {
      id: "dpo",
      heading: "15. Data Protection Officer",
      body: `If you have concerns about our data practices or wish to exercise your rights, you may contact our Data Protection Officer:`,
      items: [
        "Email: dpo@speakup.app",
        "Privacy inquiries: privacy@speakup.app",
        "General support: support@speakup.app",
      ],
      footer: `You also have the right to lodge a complaint with your local data protection supervisory authority if you believe your data protection rights have been violated.`,
    },

    // ── 16. Contact ──
    {
      id: "contact",
      heading: "16. Contact Us",
      body: `For any questions, concerns, or requests regarding this Privacy Policy or your personal data, please reach out to us:`,
      items: [
        "Email: privacy@speakup.app",
        "Support: support@speakup.app",
        "Website: https://speakup.app/privacy",
      ],
    },
  ],
};

export default privacyPolicy;
