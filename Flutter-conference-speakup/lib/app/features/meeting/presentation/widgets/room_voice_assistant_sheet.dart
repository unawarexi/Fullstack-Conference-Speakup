import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/domain/models/ai_models.dart';

class RoomVoiceAssistantSheet extends StatelessWidget {
  final TextEditingController controller;
  final VoiceCommandResult? lastResult;
  final bool isDark;
  final ValueChanged<String> onSend;
  final ValueChanged<Map<String, dynamic>> onConfirm;
  final VoidCallback onClose;

  const RoomVoiceAssistantSheet({
    super.key,
    required this.controller,
    this.lastResult,
    required this.isDark,
    required this.onSend,
    required this.onConfirm,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark ? SColors.darkSurface : SColors.lightSurface;
    final borderColor = isDark ? SColors.darkBorder : SColors.lightBorder;
    final cardColor = isDark ? SColors.darkCard : SColors.lightCard;
    final textPrimary = isDark ? SColors.textDark : SColors.textLight;
    final textSecondary = isDark ? SColors.textDarkSecondary : SColors.textLightSecondary;
    final textTertiary = isDark ? SColors.textDarkTertiary : SColors.textLightTertiary;
    final elevatedColor = isDark ? SColors.darkElevated : SColors.lightElevated;

    return Container(
      padding: const EdgeInsets.all(SSizes.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(SSizes.radiusXl),
        border: Border.all(color: borderColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(SSizes.radiusMd),
                ),
                child: const Icon(Iconsax.microphone_2, size: 18, color: SColors.warning),
              ),
              const SizedBox(width: SSizes.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Assistant',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Type or speak a command',
                      style: TextStyle(
                        color: textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(Icons.close, color: textSecondary, size: 20),
              ),
            ],
          ),

          const SizedBox(height: SSizes.sm + 4),

          // Last result
          if (lastResult != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SSizes.sm + 2),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(SSizes.radiusMd),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: lastResult!.status == 'executed'
                              ? SColors.success
                              : lastResult!.status == 'failed'
                                  ? SColors.error
                                  : SColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        lastResult!.status.toUpperCase(),
                        style: TextStyle(
                          color: textTertiary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  if (lastResult!.command != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      lastResult!.command!,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (lastResult!.result != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      lastResult!.result!,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (lastResult!.needsConfirmation &&
                      lastResult!.parsedParameters != null) ...[
                    const SizedBox(height: SSizes.sm),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => onConfirm(lastResult!.parsedParameters!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: SColors.success.withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(SSizes.radiusSm),
                                border: Border.all(
                                    color: SColors.success.withOpacity(0.3)),
                              ),
                              child: const Center(
                                child: Text(
                                  'Confirm',
                                  style: TextStyle(
                                    color: SColors.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: SSizes.sm),
                        Expanded(
                          child: GestureDetector(
                            onTap: onClose,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: elevatedColor,
                                borderRadius:
                                    BorderRadius.circular(SSizes.radiusSm),
                              ),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: SSizes.sm + 2),
          ],

          // Input
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(SSizes.radiusFull),
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                  child: TextField(
                    controller: controller,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. "Summarize the last 5 minutes"',
                      hintStyle:
                          TextStyle(color: textTertiary, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: SSizes.md, vertical: SSizes.sm + 2),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) onSend(text.trim());
                    },
                  ),
                ),
              ),
              const SizedBox(width: SSizes.sm),
              GestureDetector(
                onTap: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) onSend(text);
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    gradient: SColors.accentGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.send_1, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
