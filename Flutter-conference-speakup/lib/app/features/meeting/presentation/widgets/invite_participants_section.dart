import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';

class InviteParticipantsSection extends StatelessWidget {
  final String meetingType;
  final TextEditingController emailCtrl;
  final List<String> inviteEmails;
  final VoidCallback onAddEmail;
  final ValueChanged<String> onRemoveEmail;

  const InviteParticipantsSection({
    super.key,
    required this.meetingType,
    required this.emailCtrl,
    required this.inviteEmails,
    required this.onAddEmail,
    required this.onRemoveEmail,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: meetingType == 'INSTANT'
              ? 'Call Participants'
              : 'Invite Participants',
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? SColors.darkCard : SColors.lightCard,
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            border: Border.all(
              color: isDark ? SColors.darkBorder : SColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? SColors.textDark : SColors.textLight,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter email address',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? SColors.textDarkTertiary
                                : SColors.textLightTertiary,
                          ),
                          prefixIcon: Icon(Icons.email_outlined,
                              size: 17,
                              color: isDark
                                  ? SColors.textDarkTertiary
                                  : SColors.textLightTertiary),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 40, minHeight: 40),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (_) => onAddEmail(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onAddEmail,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: SColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(SSizes.radiusSm),
                      ),
                      child: const Icon(Icons.add_rounded,
                          size: 18, color: SColors.primary),
                    ),
                  ),
                ],
              ),
              if (inviteEmails.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: inviteEmails.map((email) {
                    return Chip(
                      label: Text(email,
                          style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => onRemoveEmail(email),
                      backgroundColor: isDark
                          ? SColors.darkElevated
                          : SColors.lightElevated,
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
              if (inviteEmails.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    meetingType == 'INSTANT'
                        ? 'Add people to call — they\'ll get a notification or email invite'
                        : 'Invites are optional — share the code after creating',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? SColors.textDarkTertiary
                          : SColors.textLightTertiary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
