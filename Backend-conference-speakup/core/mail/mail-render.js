import fs from "fs";
import path from "path";
import { dirname } from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const TEMPLATE_PATH = path.join(__dirname, "template", "base.html");

function safeReplace(template, pattern, replacement) {
  return template.replace(pattern, () => replacement);
}

function renderContentSections(sections = []) {
  if (!Array.isArray(sections) || sections.length === 0) return "";
  return sections
    .map(
      (s) => `
      <div class="content-section">
        ${s.title ? `<div class="section-title">${s.title}</div>` : ""}
        <div>${s.content || ""}</div>
      </div>
    `,
    )
    .join("");
}

function renderExamDetails(details = []) {
  if (!Array.isArray(details) || details.length === 0) return "";
  const rows = details
    .map(
      (d) => `
      <div class="detail-row">
        <div class="detail-label">${d.label}</div>
        <div class="detail-value">${d.value}</div>
      </div>
    `,
    )
    .join("");
  return `
    <div class="details-card">
      <div class="section-title" style="border-bottom: none; padding-bottom: 0; margin-bottom: 16px;">Details</div>
      ${rows}
    </div>
  `;
}

function renderButtons(buttons = []) {
  if (!Array.isArray(buttons) || buttons.length === 0) return "";
  return `
    <div class="button-container">
      ${buttons
        .map(
          (b) =>
            `<a href="${b.url || "#"}" class="${b.primary ? "primary-button" : "secondary-button"}" style="margin-right:8px">${b.text}</a>`,
        )
        .join("")}
    </div>
  `;
}

function renderAttachments(attachments = []) {
  if (!Array.isArray(attachments) || attachments.length === 0) return "";

  const attachmentItems = attachments
    .map(
      (a) => `
      <div class="attachment-item">
        <div class="attachment-icon">📎</div>
        <div class="attachment-info">
          <div class="attachment-name">${a.name || "Unnamed file"}</div>
          <div class="attachment-size">${a.size || "Unknown size"}</div>
        </div>
      </div>
    `,
    )
    .join("");

  return `
    <div class="attachments-section">
      <div class="section-title" style="border-bottom: none; padding-bottom: 0; margin-bottom: 16px;">Attachments</div>
      ${attachmentItems}
    </div>
  `;
}

function renderFeatureCards(showFeatureCards = false) {
  if (!showFeatureCards) return "";

  return `
    <div class="feature-cards">
      <div class="feature-card">
        <div class="feature-icon">🎥</div>
        <div class="feature-title">HD Video</div>
        <div class="feature-description">Crystal-clear video and audio for all your meetings.</div>
      </div>
      <div class="feature-card">
        <div class="feature-icon">�</div>
        <div class="feature-title">Real-time Chat</div>
        <div class="feature-description">Collaborate with in-meeting chat, reactions, and screen sharing.</div>
      </div>
      <div class="feature-card">
        <div class="feature-icon">�</div>
        <div class="feature-title">Cloud Recording</div>
        <div class="feature-description">Record meetings and access them anytime from the cloud.</div>
      </div>
    </div>
  `;
}

// Read and cache template
let cachedTemplate = null;
function getTemplate() {
  if (cachedTemplate) return cachedTemplate;
  cachedTemplate = fs.readFileSync(TEMPLATE_PATH, "utf8");
  return cachedTemplate;
}

export function render(templateData = {}) {
  let html = getTemplate();

  // Inject logo URL from environment variable
  const logoUrl = process.env.SPEAKUP_LOGO_URL || "https://via.placeholder.com/64x64.png?text=SpeakUp";
  html = html.replace(/{{LOGO_URL}}/g, logoUrl);

  // Basic replacements
  html = html.replace(/{{EMAIL_TITLE}}/g, templateData.EMAIL_TITLE || "");
  html = html.replace(/{{GREETING}}/g, templateData.GREETING || "");
  html = html.replace(/{{MAIN_CONTENT}}/g, templateData.MAIN_CONTENT || "");
  html = html.replace(
    /{{ADDITIONAL_CONTENT}}/g,
    templateData.ADDITIONAL_CONTENT || "",
  );
  html = html.replace(
    /{{UNSUBSCRIBE_LINK}}/g,
    templateData.UNSUBSCRIBE_LINK || "",
  );

  // CONTENT_SECTIONS block
  html = safeReplace(
    html,
    /{{#if CONTENT_SECTIONS}}[\s\S]*?{{\/if}}/g,
    renderContentSections(templateData.CONTENT_SECTIONS),
  );

  // EXAM_DETAILS block (Now mapped to Generic Details)
  html = safeReplace(
    html,
    /{{#if EXAM_DETAILS}}[\s\S]*?{{\/if}}/g,
    renderExamDetails(templateData.EXAM_DETAILS),
  );

  // BUTTONS block
  html = safeReplace(
    html,
    /{{#if BUTTONS}}[\s\S]*?{{\/if}}/g,
    renderButtons(templateData.BUTTONS),
  );

  // INFO_BOX block (simple injection)
  if (templateData.INFO_BOX) {
    const infoHtml = `
      <div class="info-box ${templateData.INFO_BOX.type || ""}">
        ${templateData.INFO_BOX.title ? `<div class="info-box-title">${templateData.INFO_BOX.title}</div>` : ""}
        <div class="info-box-content">${templateData.INFO_BOX.content || ""}</div>
      </div>
    `;
    html = safeReplace(html, /{{#if INFO_BOX}}[\s\S]*?{{\/if}}/g, infoHtml);
  } else {
    html = html.replace(/{{#if INFO_BOX}}[\s\S]*?{{\/if}}/g, "");
  }

  // ATTACHMENTS block (conditional)
  html = safeReplace(
    html,
    /{{#if ATTACHMENTS}}[\s\S]*?{{\/if}}/g,
    renderAttachments(templateData.ATTACHMENTS),
  );

  // FEATURE_CARDS block (conditional)
  html = safeReplace(
    html,
    /{{#if FEATURE_CARDS}}[\s\S]*?{{\/if}}/g,
    renderFeatureCards(templateData.FEATURE_CARDS),
  );

  // Enhanced cleanup of remaining handlebars-like syntax
  // This handles multiple edge cases:

  // 1. Remove nested conditionals that weren't rendered (e.g., {{#if NESTED}}...{{/if}})
  html = html.replace(/{{#if\s+[^}]*}}[\s\S]*?{{\/if}}/gi, "");

  // 2. Remove each loops that weren't rendered (e.g., {{#each ITEMS}}...{{/each}})
  html = html.replace(/{{#each\s+[^}]*}}[\s\S]*?{{\/each}}/gi, "");

  // 3. Remove unless conditionals (e.g., {{#unless VAR}}...{{/unless}})
  html = html.replace(/{{#unless\s+[^}]*}}[\s\S]*?{{\/unless}}/gi, "");

  // 4. Remove with blocks (e.g., {{#with OBJ}}...{{/with}})
  html = html.replace(/{{#with\s+[^}]*}}[\s\S]*?{{\/with}}/gi, "");

  // 5. Remove any standalone closing tags that might be left (e.g., {{/if}}, {{/each}})
  html = html.replace(/{{\/[^}]+}}/gi, "");

  // 6. Remove any opening block helpers that might be left (e.g., {{#if}}, {{#each}})
  html = html.replace(/{{#[^}]+}}/gi, "");

  // 7. Remove simple variable placeholders (e.g., {{VAR_NAME}})
  html = html.replace(/{{[^#\/][^}]*}}/g, "");

  // 8. Remove triple-brace unescaped variables (e.g., {{{VAR}}})
  html = html.replace(/{{{[^}]*}}}/g, "");

  // 9. Final catch-all for any malformed handlebars syntax
  html = html.replace(/{{[^}]*}}/g, "");

  // 10. Clean up excessive whitespace left by removed blocks
  html = html.replace(/\n\s*\n\s*\n/g, "\n\n"); // Replace 3+ newlines with 2
  html = html.replace(/>\s+</g, "><"); // Remove whitespace between tags (optional, be careful)

  // 11. Remove HTML comments that might contain handlebars (edge case)
  html = html.replace(/<!--[\s\S]*?-->/g, "");

  return html;
}