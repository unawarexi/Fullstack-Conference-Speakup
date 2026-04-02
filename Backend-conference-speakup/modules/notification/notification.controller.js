// ============================================================================
// SpeakUp — Notification Controller
// ============================================================================

import * as notificationService from "./notification.service.js";

export async function getNotifications(req, res, next) {
  try {
    const result = await notificationService.getNotifications(req.user.id, req.query);
    res.json({ success: true, data: result });
  } catch (error) { next(error); }
}

export async function getUnreadCount(req, res, next) {
  try {
    const count = await notificationService.getUnreadCount(req.user.id);
    res.json({ success: true, data: { unreadCount: count } });
  } catch (error) { next(error); }
}

export async function markAsRead(req, res, next) {
  try {
    const notification = await notificationService.markAsRead(req.params.id, req.user.id);
    res.json({ success: true, data: { notification } });
  } catch (error) { next(error); }
}

export async function markAllAsRead(req, res, next) {
  try {
    const count = await notificationService.markAllAsRead(req.user.id);
    res.json({ success: true, data: { markedCount: count } });
  } catch (error) { next(error); }
}

export async function deleteNotification(req, res, next) {
  try {
    await notificationService.deleteNotification(req.params.id, req.user.id);
    res.json({ success: true, message: "Notification deleted" });
  } catch (error) { next(error); }
}
