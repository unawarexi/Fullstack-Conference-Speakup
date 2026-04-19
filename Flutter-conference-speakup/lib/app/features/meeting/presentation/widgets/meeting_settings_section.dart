import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/create_meeting_widgets.dart';

class MeetingSettingsSection extends StatelessWidget {
  final String meetingType;
  final bool hasPassword;
  final ValueChanged<bool> onPasswordChanged;
  final TextEditingController passwordCtrl;
  final bool autoRecord;
  final ValueChanged<bool> onAutoRecordChanged;
  final bool waitingRoom;
  final ValueChanged<bool> onWaitingRoomChanged;
  final bool muteOnJoin;
  final ValueChanged<bool> onMuteOnJoinChanged;
  final bool cameraOffOnJoin;
  final ValueChanged<bool> onCameraOffOnJoinChanged;
  final int maxParticipants;
  final ValueChanged<int> onMaxParticipantsChanged;
  final int? durationMinutes;
  final ValueChanged<int?> onDurationChanged;

  const MeetingSettingsSection({
    super.key,
    required this.meetingType,
    required this.hasPassword,
    required this.onPasswordChanged,
    required this.passwordCtrl,
    required this.autoRecord,
    required this.onAutoRecordChanged,
    required this.waitingRoom,
    required this.onWaitingRoomChanged,
    required this.muteOnJoin,
    required this.onMuteOnJoinChanged,
    required this.cameraOffOnJoin,
    required this.onCameraOffOnJoinChanged,
    required this.maxParticipants,
    required this.onMaxParticipantsChanged,
    required this.durationMinutes,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Settings'),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? SColors.darkCard : SColors.lightCard,
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            border: Border.all(
              color: isDark ? SColors.darkBorder : SColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              ToggleRow(
                icon: SIcons.lock,
                title: 'Password Protected',
                subtitle: 'Require password to join',
                value: hasPassword,
                onChanged: onPasswordChanged,
              ),
              if (hasPassword) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  child: CreateMeetingInputField(
                    controller: passwordCtrl,
                    label: '',
                    hint: 'Enter meeting password',
                    icon: SIcons.lock,
                    isDark: isDark,
                    isPassword: true,
                  ),
                ),
              ],
              ToggleRow(
                icon: SIcons.record,
                title: 'Auto Record',
                subtitle: 'Start recording automatically',
                value: autoRecord,
                onChanged: onAutoRecordChanged,
              ),
              ToggleRow(
                icon: Icons.hourglass_empty_rounded,
                title: 'Waiting Room',
                subtitle: 'Approve participants before joining',
                value: waitingRoom,
                onChanged: onWaitingRoomChanged,
              ),
              ToggleRow(
                icon: SIcons.micOff,
                title: 'Mute on Join',
                subtitle: 'Participants muted when joining',
                value: muteOnJoin,
                onChanged: onMuteOnJoinChanged,
              ),
              ToggleRow(
                icon: SIcons.cameraOff,
                title: 'Camera Off on Join',
                subtitle: 'Participants camera off when joining',
                value: cameraOffOnJoin,
                onChanged: onCameraOffOnJoinChanged,
              ),
              // Max participants
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isDark
                            ? SColors.darkElevated
                            : SColors.lightElevated,
                        borderRadius:
                            BorderRadius.circular(SSizes.radiusSm),
                      ),
                      child: Icon(SIcons.participants,
                          size: 17,
                          color: isDark
                              ? SColors.textDarkSecondary
                              : SColors.textLightSecondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Max Participants',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? SColors.textDark
                                  : SColors.textLight,
                            ),
                          ),
                          Text(
                            '$maxParticipants participants',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? SColors.textDarkTertiary
                                  : SColors.textLightTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: CupertinoSlider(
                        value: maxParticipants.toDouble(),
                        min: 2,
                        max: 500,
                        divisions: 498,
                        activeColor: SColors.primary,
                        onChanged: (v) =>
                            onMaxParticipantsChanged(v.round()),
                      ),
                    ),
                  ],
                ),
              ),

              // Duration Picker (only for scheduled/recurring)
              if (meetingType != 'INSTANT')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meeting Duration',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? SColors.textDark
                                    : SColors.textLight,
                              ),
                            ),
                            Text(
                              durationMinutes != null
                                  ? '$durationMinutes min'
                                  : 'No limit',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? SColors.textDarkTertiary
                                    : SColors.textLightTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (durationMinutes != null)
                            GestureDetector(
                              onTap: () => onDurationChanged(null),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(Icons.clear_rounded,
                                    size: 18,
                                    color: isDark
                                        ? SColors.textDarkTertiary
                                        : SColors.textLightTertiary),
                              ),
                            ),
                          SizedBox(
                            width: 140,
                            child: CupertinoSlider(
                              value: (durationMinutes ?? 0).toDouble(),
                              min: 0,
                              max: 480,
                              divisions: 32,
                              activeColor: SColors.primary,
                              onChanged: (v) {
                                final rounded = v.round();
                                onDurationChanged(
                                    rounded == 0 ? null : rounded);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
