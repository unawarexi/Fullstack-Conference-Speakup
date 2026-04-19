// SpeakUp — Email content generator

class EmailContentGenerator {
  constructor() {
    this.baseUrl = process.env.FRONTEND_URL || "https://speakup.app";
    this.supportEmail = "support@speakup.app";
    this.unsubscribeBaseUrl = `${this.baseUrl}/unsubscribe`;
  }

  generateUnsubscribeLink(userId, emailType) {
    return `${this.unsubscribeBaseUrl}?user=${userId || ""}&type=${emailType || "general"}`;
  }

  // 1. Welcome Email
  welcomeEmail(user) {
    return {
      EMAIL_TITLE: "Welcome to SpeakUp",
      GREETING: `Hello ${user.name || "there"},`,
      MAIN_CONTENT: `
        <p>Welcome to <strong>SpeakUp</strong>! We're excited to have you on board.</p>
        <p>Start hosting and joining video meetings with crystal-clear audio and video.</p>
      `,
      CONTENT_SECTIONS: [
        {
          title: "Get Started",
          content: `<p>Create your first meeting, invite participants, and enjoy real-time collaboration with screen sharing, chat, and recording.</p>`,
        },
      ],
      BUTTONS: [
        { text: "Go to Dashboard", url: `${this.baseUrl}/dashboard`, primary: true },
      ],
      FEATURE_CARDS: true,
      UNSUBSCRIBE_LINK: this.generateUnsubscribeLink(user.id, "welcome"),
    };
  }

  // 2. Meeting Invitation
  meetingInvite(meeting) {
    const isInstant = meeting.isInstant || false;
    return {
      EMAIL_TITLE: isInstant
        ? `${meeting.hostName} is calling you on SpeakUp`
        : `You're invited to a meeting: ${meeting.title}`,
      GREETING: `Hello ${meeting.inviteeName || "there"},`,
      MAIN_CONTENT: isInstant
        ? `<p><strong>${meeting.hostName}</strong> is calling you right now on SpeakUp. Tap below to join.</p>`
        : `<p><strong>${meeting.hostName}</strong> has invited you to a meeting on SpeakUp.</p>`,
      CONTENT_SECTIONS: isInstant ? [] : [
        {
          title: "Meeting Details",
          content: `
            <ul style="margin-left:18px;color:#475569;">
              <li><strong>Title:</strong> ${meeting.title}</li>
              <li><strong>Date:</strong> ${meeting.date || "—"}</li>
              <li><strong>Time:</strong> ${meeting.time || "—"}</li>
              <li><strong>Code:</strong> ${meeting.code || "—"}</li>
            </ul>
          `,
        },
      ],
      BUTTONS: [
        { text: isInstant ? "Join Call Now" : "Join Meeting", url: `${this.baseUrl}/meeting/${meeting.code}`, primary: true },
      ],
      UNSUBSCRIBE_LINK: this.generateUnsubscribeLink(meeting.inviteeId, "meeting"),
    };
  }

  // 2b. Meeting Invite — Download App (for unregistered users)
  meetingInviteDownload(data) {
    const isInstant = data.isInstant;
    const avatarHtml = data.hostAvatar
      ? `<img src="${data.hostAvatar}" alt="${data.hostName}" style="width:56px;height:56px;border-radius:50%;object-fit:cover;margin-bottom:8px;" />`
      : `<div style="width:56px;height:56px;border-radius:50%;background:#6366F1;color:#fff;display:flex;align-items:center;justify-content:center;font-size:22px;font-weight:700;margin-bottom:8px;">${(data.hostName || "?")[0].toUpperCase()}</div>`;

    return {
      EMAIL_TITLE: isInstant
        ? `${data.hostName} is calling you on SpeakUp`
        : `You're invited to "${data.title}" on SpeakUp`,
      GREETING: `Hello ${data.inviteeName || "there"},`,
      MAIN_CONTENT: `
        <div style="text-align:center;padding:16px 0;">
          ${avatarHtml}
          <p style="font-size:16px;margin:8px 0 4px;">
            <strong>${data.hostName}</strong>
            ${data.hostEmail ? `<br/><span style="font-size:13px;color:#64748B;">${data.hostEmail}</span>` : ""}
          </p>
          <p style="font-size:15px;margin-top:12px;">
            ${isInstant
              ? `is calling you right now on <strong>SpeakUp</strong>.`
              : `invited you to <strong>"${data.title}"</strong> on SpeakUp.`
            }
          </p>
        </div>
      `,
      CONTENT_SECTIONS: [
        ...(isInstant ? [] : [{
          title: "Meeting Details",
          content: `
            <ul style="margin-left:18px;color:#475569;">
              <li><strong>Title:</strong> ${data.title}</li>
              <li><strong>Date:</strong> ${data.date || "—"}</li>
              <li><strong>Time:</strong> ${data.time || "—"}</li>
              <li><strong>Code:</strong> ${data.code || "—"}</li>
            </ul>
          `,
        }]),
        {
          title: "Get SpeakUp",
          content: `
            <p style="color:#475569;">Download SpeakUp to join ${isInstant ? "the call" : "the meeting"}. It's free and takes less than a minute.</p>
            <div style="text-align:center;padding:12px 0;">
              <a href="${data.appLinks?.googlePlay || "#"}" style="display:inline-block;margin:6px 8px;padding:10px 20px;background:#1a1a1a;color:#fff;text-decoration:none;border-radius:8px;font-weight:600;font-size:13px;">
                ▶ Google Play
              </a>
              <a href="${data.appLinks?.appleStore || "#"}" style="display:inline-block;margin:6px 8px;padding:10px 20px;background:#1a1a1a;color:#fff;text-decoration:none;border-radius:8px;font-weight:600;font-size:13px;">
                 App Store
              </a>
            </div>
            <p style="text-align:center;color:#94A3B8;font-size:12px;margin-top:4px;">
              Or join from your browser: <a href="${data.appLinks?.webApp}/meeting/${data.code}" style="color:#6366F1;">${data.appLinks?.webApp}/meeting/${data.code}</a>
            </p>
          `,
        },
      ],
      BUTTONS: [
        { text: isInstant ? "Join Call Now" : "Join Meeting", url: `${this.baseUrl}/meeting/${data.code}`, primary: true },
      ],
      UNSUBSCRIBE_LINK: this.generateUnsubscribeLink(null, "meeting"),
    };
  }

  // 3. Meeting Reminder
  meetingReminder(data) {
    const isStarting = data.reminderType === "MEETING_STARTING";
    return {
      EMAIL_TITLE: isStarting
        ? `Meeting starting now: ${data.meetingTitle}`
        : `Meeting reminder: ${data.meetingTitle} starts soon`,
      GREETING: `Hello ${data.inviteeName || "there"},`,
      MAIN_CONTENT: isStarting
        ? `<p>Your meeting <strong>"${data.meetingTitle}"</strong> is starting now!</p>`
        : `<p>Your meeting <strong>"${data.meetingTitle}"</strong> starts in 5 minutes.</p>`,
      CONTENT_SECTIONS: [
        {
          title: "Meeting Details",
          content: `
            <ul style="margin-left:18px;color:#475569;">
              <li><strong>Title:</strong> ${data.meetingTitle}</li>
              <li><strong>Time:</strong> ${data.scheduledTime || "—"}</li>
              <li><strong>Code:</strong> ${data.code || "—"}</li>
              <li><strong>Host:</strong> ${data.hostName || "—"}</li>
            </ul>
          `,
        },
      ],
      BUTTONS: [
        { text: "Join Meeting", url: `${this.baseUrl}/meeting/${data.code}`, primary: true },
      ],
      UNSUBSCRIBE_LINK: this.generateUnsubscribeLink(null, "meeting"),
    };
  }

  // 4. Recording Ready
  recordingReady(recording) {
    return {
      EMAIL_TITLE: "Your Recording is Ready",
      GREETING: `Hello ${recording.userName || "there"},`,
      MAIN_CONTENT: `
        <p>The recording for <strong>"${recording.meetingTitle}"</strong> is now available for download.</p>
      `,
      BUTTONS: [
        { text: "View Recording", url: `${this.baseUrl}/recordings/${recording.id}`, primary: true },
      ],
      UNSUBSCRIBE_LINK: this.generateUnsubscribeLink(recording.userId, "recording"),
    };
  }

  // 4. Subscription Confirmation
  subscriptionConfirmed(subscription) {
    return {
      EMAIL_TITLE: "Subscription Confirmed",
      GREETING: `Hello ${subscription.userName || "there"},`,
      MAIN_CONTENT: `
        <p>Your <strong>${subscription.planName}</strong> subscription is now active.</p>
      `,
      CONTENT_SECTIONS: [
        {
          title: "Subscription Details",
          content: `
            <ul style="margin-left:18px;color:#475569;">
              <li><strong>Plan:</strong> ${subscription.planName}</li>
              <li><strong>Start:</strong> ${subscription.startDate}</li>
              <li><strong>Next Renewal:</strong> ${subscription.endDate || "N/A"}</li>
            </ul>
          `,
        },
      ],
      BUTTONS: [
        { text: "Manage Subscription", url: `${this.baseUrl}/settings/billing`, primary: true },
      ],
      UNSUBSCRIBE_LINK: this.generateUnsubscribeLink(subscription.userId, "billing"),
    };
  }

  // 5. Payment Receipt
  paymentReceipt(transaction) {
    return {
      EMAIL_TITLE: "Payment Successful",
      GREETING: `Hello ${transaction.userName || "there"},`,
      MAIN_CONTENT: `
        <p>Your payment of <strong>${transaction.currency} ${transaction.amount}</strong> was successful.</p>
      `,
      CONTENT_SECTIONS: [
        {
          title: "Transaction Details",
          content: `
            <ul style="margin-left:18px;color:#475569;">
              <li><strong>Reference:</strong> ${transaction.reference || "—"}</li>
              <li><strong>Date:</strong> ${transaction.date || new Date().toLocaleString()}</li>
              <li><strong>Amount:</strong> ${transaction.currency} ${transaction.amount}</li>
              <li><strong>Plan:</strong> ${transaction.planName || "SpeakUp Pro"}</li>
            </ul>
          `,
        },
      ],
      BUTTONS: [
        { text: "View Billing", url: `${this.baseUrl}/settings/billing`, primary: true },
      ],
      UNSUBSCRIBE_LINK: this.generateUnsubscribeLink(transaction.userId, "billing"),
    };
  }

  // 6. Goodbye Email
  goodbyeEmail(user) {
    return {
      EMAIL_TITLE: "We're Sorry to See You Go",
      GREETING: `Goodbye ${user.name || "there"},`,
      MAIN_CONTENT: `
        <p>Your SpeakUp account has been deleted.</p>
        <p>If you ever change your mind, you can sign up again anytime.</p>
      `,
      BUTTONS: [
        { text: "Come Back Anytime", url: `${this.baseUrl}/`, primary: true },
      ],
      UNSUBSCRIBE_LINK: this.generateUnsubscribeLink(user.id, "goodbye"),
    };
  }

  // 7. Meeting Duration Warning (5 min before end)
  meetingDurationWarning(data) {
    return {
      EMAIL_TITLE: `Meeting ending soon: ${data.meetingTitle}`,
      GREETING: `Hello ${data.hostName || "there"},`,
      MAIN_CONTENT: `
        <p>Your meeting <strong>"${data.meetingTitle}"</strong> will end in <strong>${data.remainingMinutes} minutes</strong>.</p>
        <p>The meeting was set to last ${data.durationMinutes} minutes.</p>
      `,
      CONTENT_SECTIONS: [
        {
          title: "Meeting Details",
          content: `
            <ul style="margin-left:18px;color:#475569;">
              <li><strong>Title:</strong> ${data.meetingTitle}</li>
              <li><strong>Code:</strong> ${data.code || "—"}</li>
              <li><strong>Duration:</strong> ${data.durationMinutes} minutes</li>
            </ul>
          `,
        },
      ],
      BUTTONS: [
        { text: "Go to Meeting", url: `${this.baseUrl}/meeting/${data.code}`, primary: true },
      ],
      UNSUBSCRIBE_LINK: this.generateUnsubscribeLink(null, "meeting"),
    };
  }

  // 8. Meeting Duration Expired
  meetingDurationExpired(data) {
    return {
      EMAIL_TITLE: `Meeting ended: ${data.meetingTitle}`,
      GREETING: `Hello ${data.hostName || "there"},`,
      MAIN_CONTENT: `
        <p>Your meeting <strong>"${data.meetingTitle}"</strong> has ended after reaching its ${data.durationMinutes}-minute time limit.</p>
        <p>You can recreate this meeting from your meeting history if needed.</p>
      `,
      CONTENT_SECTIONS: [
        {
          title: "What's next?",
          content: `<p>Visit your meeting history to recreate this meeting with the same settings, or create a new one from scratch.</p>`,
        },
      ],
      BUTTONS: [
        { text: "View Meeting History", url: `${this.baseUrl}/meetings`, primary: true },
        { text: "Create New Meeting", url: `${this.baseUrl}/meetings/create` },
      ],
      UNSUBSCRIBE_LINK: this.generateUnsubscribeLink(null, "meeting"),
    };
  }

  generateFooterContent(unsubscribeLink) {
    return `
      <div style="margin-top: 20px; padding-top: 12px; border-top: 1px solid #E2E8F0; color: #64748B; font-size: 12px;">
        <p>This message was sent by SpeakUp. If you no longer wish to receive these emails, <a href="${unsubscribeLink}" style="color:#94A3B8;">unsubscribe here</a>.</p>
        <p>SpeakUp | Video Conferencing Platform</p>
        <p>Support: <a href="mailto:${this.supportEmail}" style="color:#94A3B8;">${this.supportEmail}</a></p>
      </div>
    `;
  }
}

export default new EmailContentGenerator();
