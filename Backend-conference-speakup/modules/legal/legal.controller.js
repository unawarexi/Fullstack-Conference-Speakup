// ============================================================================
// SpeakUp — Legal Controller
// Serves Terms of Service and Privacy Policy content
// ============================================================================

import * as legalService from "./legal.service.js";
import { HttpStatus } from "../../config/constants.js";

export async function getTermsOfService(_req, res, next) {
  try {
    const data = legalService.getTermsOfService();
    res.status(HttpStatus.OK).json({ success: true, data });
  } catch (error) {
    next(error);
  }
}

export async function getPrivacyPolicy(_req, res, next) {
  try {
    const data = legalService.getPrivacyPolicy();
    res.status(HttpStatus.OK).json({ success: true, data });
  } catch (error) {
    next(error);
  }
}

export async function getAllLegalDocuments(_req, res, next) {
  try {
    const data = legalService.getAllLegalDocuments();
    res.status(HttpStatus.OK).json({ success: true, data });
  } catch (error) {
    next(error);
  }
}
