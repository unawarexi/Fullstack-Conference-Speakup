// ============================================================================
// SpeakUp — Auth Controller
// ============================================================================

import * as authService from "./auth.service.js";
import { HttpStatus } from "../../config/constants.js";

export async function signIn(req, res, next) {
  try {
    // The token is already verified by auth middleware — req.firebaseUser is set
    const { user, isNewUser } = await authService.signInUser(req.firebaseUser);

    res.status(isNewUser ? HttpStatus.CREATED : HttpStatus.OK).json({
      success: true,
      message: isNewUser ? "Account created successfully" : "Signed in successfully",
      data: { user },
    });
  } catch (error) {
    next(error);
  }
}

export async function signOut(req, res, next) {
  try {
    await authService.signOutUser(req.user.id);
    res.status(HttpStatus.OK).json({ success: true, message: "Signed out successfully" });
  } catch (error) {
    next(error);
  }
}

export async function getMe(req, res, next) {
  try {
    const user = await authService.getUserProfile(req.user.id);
    if (!user) {
      return res.status(HttpStatus.NOT_FOUND).json({ success: false, message: "User not found" });
    }
    res.status(HttpStatus.OK).json({ success: true, data: { user } });
  } catch (error) {
    next(error);
  }
}

export async function deleteAccount(req, res, next) {
  try {
    await authService.deleteUserAccount(req.user.id, req.user.firebaseUid);
    res.status(HttpStatus.OK).json({ success: true, message: "Account deleted successfully" });
  } catch (error) {
    next(error);
  }
}
