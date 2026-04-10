import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/services/storage_service.dart';

// ============================================================================
// SETTINGS STATE
// ============================================================================

class AppSettings {
  // AI Features
  final bool aiCopilotEnabled;
  final bool aiTranscriptionEnabled;
  final bool aiCoachingEnabled;
  final bool aiVoiceAssistantEnabled;

  // General
  final bool notificationsEnabled;

  // Meeting Defaults
  final bool cameraOnByDefault;
  final bool micOnByDefault;
  final bool autoRecordEnabled;

  const AppSettings({
    this.aiCopilotEnabled = true,
    this.aiTranscriptionEnabled = true,
    this.aiCoachingEnabled = false,
    this.aiVoiceAssistantEnabled = true,
    this.notificationsEnabled = true,
    this.cameraOnByDefault = true,
    this.micOnByDefault = true,
    this.autoRecordEnabled = false,
  });

  AppSettings copyWith({
    bool? aiCopilotEnabled,
    bool? aiTranscriptionEnabled,
    bool? aiCoachingEnabled,
    bool? aiVoiceAssistantEnabled,
    bool? notificationsEnabled,
    bool? cameraOnByDefault,
    bool? micOnByDefault,
    bool? autoRecordEnabled,
  }) =>
      AppSettings(
        aiCopilotEnabled: aiCopilotEnabled ?? this.aiCopilotEnabled,
        aiTranscriptionEnabled: aiTranscriptionEnabled ?? this.aiTranscriptionEnabled,
        aiCoachingEnabled: aiCoachingEnabled ?? this.aiCoachingEnabled,
        aiVoiceAssistantEnabled: aiVoiceAssistantEnabled ?? this.aiVoiceAssistantEnabled,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        cameraOnByDefault: cameraOnByDefault ?? this.cameraOnByDefault,
        micOnByDefault: micOnByDefault ?? this.micOnByDefault,
        autoRecordEnabled: autoRecordEnabled ?? this.autoRecordEnabled,
      );
}

// ============================================================================
// SETTINGS NOTIFIER
// ============================================================================

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(_loadFromStorage());

  static AppSettings _loadFromStorage() => AppSettings(
        aiCopilotEnabled: LocalStorageService.aiCopilotEnabled,
        aiTranscriptionEnabled: LocalStorageService.aiTranscriptionEnabled,
        aiCoachingEnabled: LocalStorageService.aiCoachingEnabled,
        aiVoiceAssistantEnabled: LocalStorageService.aiVoiceAssistantEnabled,
        notificationsEnabled: LocalStorageService.notificationsEnabled,
        cameraOnByDefault: LocalStorageService.cameraOnByDefault,
        micOnByDefault: LocalStorageService.micOnByDefault,
        autoRecordEnabled: LocalStorageService.autoRecordEnabled,
      );

  // ── AI Features ──

  void toggleAiCopilot() {
    final v = !state.aiCopilotEnabled;
    state = state.copyWith(aiCopilotEnabled: v);
    LocalStorageService.setAiCopilotEnabled(v);
  }

  void toggleAiTranscription() {
    final v = !state.aiTranscriptionEnabled;
    state = state.copyWith(aiTranscriptionEnabled: v);
    LocalStorageService.setAiTranscriptionEnabled(v);
  }

  void toggleAiCoaching() {
    final v = !state.aiCoachingEnabled;
    state = state.copyWith(aiCoachingEnabled: v);
    LocalStorageService.setAiCoachingEnabled(v);
  }

  void toggleAiVoiceAssistant() {
    final v = !state.aiVoiceAssistantEnabled;
    state = state.copyWith(aiVoiceAssistantEnabled: v);
    LocalStorageService.setAiVoiceAssistantEnabled(v);
  }

  // ── General ──

  void toggleNotifications() {
    final v = !state.notificationsEnabled;
    state = state.copyWith(notificationsEnabled: v);
    LocalStorageService.setNotificationsEnabled(v);
  }

  // ── Meeting Defaults ──

  void toggleCameraDefault() {
    final v = !state.cameraOnByDefault;
    state = state.copyWith(cameraOnByDefault: v);
    LocalStorageService.setCameraOnByDefault(v);
  }

  void toggleMicDefault() {
    final v = !state.micOnByDefault;
    state = state.copyWith(micOnByDefault: v);
    LocalStorageService.setMicOnByDefault(v);
  }

  void toggleAutoRecord() {
    final v = !state.autoRecordEnabled;
    state = state.copyWith(autoRecordEnabled: v);
    LocalStorageService.setAutoRecordEnabled(v);
  }
}
