import admin from "firebase-admin";
import { createRequire } from "module";

/**
 * Load Firebase service account credentials.
 *
 * Production (Render):  reads from FIREBASE_SERVICE_ACCOUNT env var
 *   → Set this on Render as a single env var containing the full JSON string.
 *
 * Local development:    reads the JSON file from disk (gitignored).
 */
function getServiceAccount() {
  // 1. Try environment variable first (production / Render)
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    try {
      return JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    } catch (err) {
      console.error(
        "[Firebase Admin] Failed to parse FIREBASE_SERVICE_ACCOUNT env var:",
        err.message,
      );
      throw new Error(
        "FIREBASE_SERVICE_ACCOUNT env var is not valid JSON. " +
          "Make sure you pasted the entire service account JSON.",
      );
    }
  }

  // 2. Fall back to local JSON file (development)
  try {
    const require = createRequire(import.meta.url);
    return require("./flutter-video-conference-d6300-firebase-adminsdk-ndaaw-3f09ca186e.json");
  } catch {
    throw new Error(
      "Firebase service account not found. " +
        "Set FIREBASE_SERVICE_ACCOUNT env var or place the JSON file in config/.",
    );
  }
}

const serviceAccount = getServiceAccount();

// Only initialize if not already initialized
let adminApp;
if (!admin.apps.length) {
  adminApp = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: serviceAccount.project_id,
  });
  console.log(
    `[Firebase Admin] Initialized with project: ${serviceAccount.project_id}`,
  );
} else {
  adminApp = admin.app();
}

export { adminApp };
export default admin;