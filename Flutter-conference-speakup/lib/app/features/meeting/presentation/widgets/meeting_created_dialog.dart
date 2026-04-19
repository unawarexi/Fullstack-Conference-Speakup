import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/button.dart';

class MeetingCreatedDialog extends StatelessWidget {
  final String code;
  final String? password;
  final int inviteCount;
  final VoidCallback onDone;

  const MeetingCreatedDialog({
    super.key,
    required this.code,
    this.password,
    required this.inviteCount,
    required this.onDone,
  });

  static void show(
    BuildContext context, {
    required String code,
    String? password,
    required int inviteCount,
    required VoidCallback onDone,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: isDark ? SColors.darkCard : SColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => MeetingCreatedDialog(
        code: code,
        password: password,
        inviteCount: inviteCount,
        onDone: () {
          Navigator.of(ctx).pop();
          onDone();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meetingLink = 'https://speakup.app/join/$code';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? SColors.darkBorder : SColors.lightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Icon(Icons.check_circle_rounded,
              size: 48, color: SColors.success),
          const SizedBox(height: 12),
          Text(
            'Meeting Created!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? SColors.textDark : SColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          // Meeting code display
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: SColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(SSizes.radiusMd),
              border: Border.all(
                color: SColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: SColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied!')),
                    );
                  },
                  child: const Icon(Icons.copy_rounded,
                      size: 18, color: SColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (inviteCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '$inviteCount invite(s) sent via email',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? SColors.textDarkSecondary
                      : SColors.textLightSecondary,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: SButton(
                  text: 'Share Link',
                  prefixIcon: Icons.share_rounded,
                  variant: SButtonVariant.outline,
                  onPressed: () {
                    final shareText = StringBuffer(
                      'Join my SpeakUp meeting!\n\nCode: $code\nLink: $meetingLink',
                    );
                    if (password != null && password!.isNotEmpty) {
                      shareText.write('\nPassword: $password');
                    }
                    SharePlus.instance.share(
                      ShareParams(text: shareText.toString()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SButton(
                  text: 'Done',
                  prefixIcon: Icons.check_rounded,
                  onPressed: onDone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
