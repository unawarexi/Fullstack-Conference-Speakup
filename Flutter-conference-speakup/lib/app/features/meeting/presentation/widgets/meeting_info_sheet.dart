import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';

/// Meeting info + share bottom sheet.
class MeetingInfoSheet extends StatelessWidget {
  final MeetingModel meeting;
  final VoidCallback onClose;

  const MeetingInfoSheet({
    super.key,
    required this.meeting,
    required this.onClose,
  });

  String get _meetingLink => 'https://speakup.app/join/${meeting.code}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? SColors.darkSurface : SColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? SColors.darkBorder : SColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            meeting.title,
            style: TextStyle(
              color: isDark ? SColors.textDark : SColors.textLight,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (meeting.description != null &&
              meeting.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              meeting.description!,
              style: TextStyle(
                color: isDark
                    ? SColors.textDarkSecondary
                    : SColors.textLightSecondary,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 16),

          // Meeting code
          _InfoRow(
            icon: Iconsax.code,
            label: 'Meeting Code',
            value: meeting.code,
            isDark: isDark,
            onCopy: () => _copyToClipboard(context, meeting.code),
          ),

          const SizedBox(height: 10),

          // Link
          _InfoRow(
            icon: Iconsax.link,
            label: 'Invite Link',
            value: _meetingLink,
            isDark: isDark,
            onCopy: () => _copyToClipboard(context, _meetingLink),
          ),

          const SizedBox(height: 10),

          // Host
          _InfoRow(
            icon: Iconsax.user,
            label: 'Host',
            value: meeting.hostName ?? 'Unknown',
            isDark: isDark,
          ),

          const SizedBox(height: 10),

          // Type
          _InfoRow(
            icon: Iconsax.video,
            label: 'Type',
            value: meeting.type.name.toUpperCase(),
            isDark: isDark,
          ),

          const SizedBox(height: 20),

          // Share button
          GestureDetector(
            onTap: () => _share(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: SColors.primaryGradient,
                borderRadius: BorderRadius.circular(SSizes.radiusMd),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.share, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Share Meeting Link',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _share(BuildContext context) {
    final text =
        'Join my SpeakUp meeting!\n\n'
        '${meeting.title}\n'
        'Code: ${meeting.code}\n'
        'Link: $_meetingLink';
    SharePlus.instance.share(ShareParams(text: text));
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final VoidCallback? onCopy;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isDark ? SColors.darkCard : SColors.lightElevated,
            borderRadius: BorderRadius.circular(SSizes.radiusSm),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isDark
                ? SColors.textDarkSecondary
                : SColors.textLightSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark
                      ? SColors.textDarkTertiary
                      : SColors.textLightTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? SColors.textDark : SColors.textLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            onPressed: onCopy,
            icon: Icon(
              Iconsax.copy,
              size: 16,
              color: SColors.primary,
            ),
          ),
      ],
    );
  }
}
