import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// Meeting Templates — pre-built & custom templates for recurring meeting types.
class MeetingTemplatesScreen extends ConsumerWidget {
  const MeetingTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analyticsAsync = ref.watch(analyticsDashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Templates'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add_rounded, color: isDark ? SColors.textDark : SColors.textLight),
          ),
        ],
      ),
      body: ResponsiveBody(child: ListView(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
        children: [
          Text('AI-Generated', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          analyticsAsync.when(
            loading: () => const AILoadingState(message: 'Loading templates...'),
            error: (e, _) => AIErrorState(message: e.toString(), onRetry: () => ref.invalidate(analyticsDashboardProvider)),
            data: (data) {
              final templates = (data['templates'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              final aiTemplates = templates.where((t) => t['aiGenerated'] == true).toList();
              final prebuiltTemplates = templates.where((t) => t['aiGenerated'] != true).toList();
              final userTemplates = (data['userTemplates'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (aiTemplates.isEmpty)
                    const AIEmptyState(icon: Icons.auto_awesome_rounded, message: 'No AI templates yet', subMessage: 'AI will generate templates based on your meeting patterns')
                  else
                    ...aiTemplates.map((t) => _TemplateTile(
                      title: t['title'] as String? ?? '',
                      desc: t['desc'] as String? ?? '',
                      icon: Icons.auto_awesome_rounded,
                      color: SColors.primary,
                      aiGenerated: true,
                      isDark: isDark,
                    )),
                  const SizedBox(height: 20),
                  Text('Pre-built', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                  const SizedBox(height: 8),
                  if (prebuiltTemplates.isEmpty)
                    Text('No pre-built templates available', style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary))
                  else
                    ...prebuiltTemplates.map((t) => _TemplateTile(
                      title: t['title'] as String? ?? '',
                      desc: t['desc'] as String? ?? '',
                      icon: Icons.description_rounded,
                      color: SColors.primary,
                      aiGenerated: false,
                      isDark: isDark,
                    )),
                  const SizedBox(height: 16),
                  Text('Your Templates', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                  const SizedBox(height: 8),
                  if (userTemplates.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(SSizes.lg),
                      decoration: BoxDecoration(
                        color: isDark ? SColors.darkCard : SColors.lightCard,
                        borderRadius: BorderRadius.circular(SSizes.radiusMd),
                        border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.note_add_rounded, size: 32, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
                          const SizedBox(height: 8),
                          Text('No custom templates yet', style: TextStyle(fontSize: 13, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                          const SizedBox(height: 4),
                          Text('Create one from scratch or save an existing meeting as a template', style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary), textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  else
                    ...userTemplates.map((t) => _TemplateTile(
                      title: t['title'] as String? ?? '',
                      desc: t['desc'] as String? ?? '',
                      icon: Icons.person_rounded,
                      color: SColors.success,
                      aiGenerated: false,
                      isDark: isDark,
                    )),
                ],
              );
            },
          ),
        ].animate(interval: 40.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
      ),
    ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final bool aiGenerated;
  final bool isDark;
  const _TemplateTile({required this.title, required this.desc, required this.icon, required this.color, required this.aiGenerated, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight))),
                      if (aiGenerated) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: SColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('AI', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: SColors.primary)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(desc, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 18, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
          ],
        ),
      ),
);
  }
}
