// ============================================================================
// SpeakUp — User Controller
// ============================================================================

import * as userService from "./user.service.js";
import { HttpStatus } from "../../config/constants.js";

export async function getProfile(req, res, next) {
  try {
    const user = await userService.getUserById(req.user.id);
    if (!user) return res.status(HttpStatus.NOT_FOUND).json({ success: false, message: "User not found" });
    res.json({ success: true, data: { user } });
  } catch (error) { next(error); }
}

export async function updateProfile(req, res, next) {
  try {
    const user = await userService.updateUser(req.user.id, req.body);
    res.json({ success: true, data: { user } });
  } catch (error) { next(error); }
}

export async function updateAvatar(req, res, next) {
  try {
    if (!req.file?.buffer) {
      return res.status(HttpStatus.BAD_REQUEST).json({ success: false, message: "No image file provided" });
    }
    const user = await userService.updateUserAvatar(req.user.id, req.file.buffer);
    res.json({ success: true, data: { user } });
  } catch (error) { next(error); }
}

export async function getDevices(req, res, next) {
  try {
    const devices = await userService.getUserDevices(req.user.id);
    res.json({ success: true, data: { devices } });
  } catch (error) { next(error); }
}

export async function registerDevice(req, res, next) {
  try {
    const device = await userService.registerUserDevice(req.user.id, req.body);
    res.status(HttpStatus.CREATED).json({ success: true, data: { device } });
  } catch (error) { next(error); }
}

export async function removeDevice(req, res, next) {
  try {
    await userService.removeUserDevice(req.user.id, req.params.deviceId);
    res.json({ success: true, message: "Device removed" });
  } catch (error) { next(error); }
}

export async function updateOnlineStatus(req, res, next) {
  try {
    await userService.setOnlineStatus(req.user.id, req.body.isOnline);
    res.json({ success: true, message: "Status updated" });
  } catch (error) { next(error); }
}
