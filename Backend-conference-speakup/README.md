prisma:query INSERT INTO "public"."participants" ("id","meeting_id","user_id","role","joined_at","is_muted","is_camera_off","is_screen_sharing","is_hand_raised") VALUES ($1,$2,$3,CAST($4::text AS "public"."ParticipantRole"),$5,$6,$7,$8,$9) RETURNING "public"."participants"."id", "public"."participants"."meeting_id", "public"."participants"."user_id", "public"."participants"."role"::text, "public"."participants"."joined_at", "public"."participants"."left_at", "public"."participants"."is_muted", "public"."participants"."is_camera_off", "public"."participants"."is_screen_sharing", "public"."participants"."is_hand_raised"
4:23:07 PM [INFO] [MeetingService] Meeting created {"meetingId":"cmnvwxxoo0004izlq3od10dyn","code":"spk-4x67-ng9g","type":"INSTANT"}
4:23:07 PM [HTTP] [HTTP] POST /api/v1/meetings 201 {"requestId":"6c42b827-0570-444c-a134-2cba2e064e5c","method":"POST","url":"/api/v1/meetings","statusCode":201,"duration":"4686ms","ip":"::ffff:127.0.0.1","userAgent":"Dart/3.11 (dart:io)","userId":"cmnvbabj30000bglqk1dyrbpd"}



flutter: │ 🐛 {title: Flutter meeting, description: this meeting isn to discus the next flutter sprint, type: INSTANT, scheduledAt: null, maxParticipants: 100, password: 0000, settings: {autoRecord: true, waitingRoom: true, muteOnJoin: true, cameraOffOnJoin: true}}
flutter: └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
flutter: ┌─────────────────────────────────────────────────────────────────────









flutter: │ 🐛 {"success":true,"data":{"meeting":{"id":"cmnvwxxoo0004izlq3od10dyn","code":"spk-4x67-ng9g","title":"Flutter meeting","description":"this meeting isn to discus the next flutter sprint","hostId":"cmnvbabj30000bglqk1dyrbpd","type":"INSTANT","status":"LIVE","scheduledAt":"1970-01-01T00:00:00.000Z","startedAt":"2026-04-12T15:23:03.861Z","endedAt":null,"maxParticipants":100,"isRecording":false,"settings":{"autoRecord":true,"muteOnJoin":true,"waitingRoom":true,"cameraOffOnJoin":true},"createdAt":"2026-04-12T15:23:06.312Z","updatedAt":"2026-04-12T15:23:06.312Z","host":{"id":"cmnvbabj30000bglqk1dyrbpd","fullName":"Unaware Xi","avatar":"https://lh3.googleusercontent.com/a/ACg8ocKH1aJR97QTJWC8ukI4bdqj2H68lZzcaSTeJDN7GveIfFJABA=s96-c","email":"unawarexi@gmail.com"},"meetingLink":"https://speakup.app/join/spk-4x67-ng9g","deepLink":"speakup://meet/spk-4x67-ng9g"}}}