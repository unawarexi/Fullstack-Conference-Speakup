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
    return {
      EMAIL_TITLE: `You're invited to a meeting: ${meeting.title}`,
      GREETING: `Hello ${meeting.inviteeName || "there"},`,
      MAIN_CONTENT: `
        <p><strong>${meeting.hostName}</strong> has invited you to a meeting on SpeakUp.</p>
      `,
      CONTENT_SECTIONS: [
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
        { text: "Join Meeting", url: `${this.baseUrl}/meeting/${meeting.code}`, primary: true },
      ],
      UNSUBSCRIBE_LINK: this.generateUnsubscribeLink(meeting.inviteeId, "meeting"),
    };
  }

  // 3. Recording Ready
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
