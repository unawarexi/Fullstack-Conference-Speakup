import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// Integrations Hub — connect Slack, Jira, Notion, GitHub, Google Calendar, etc.
class IntegrationsHubScreen extends ConsumerWidget {
  const IntegrationsHubScreen({super.key});

  static const _iconMap = <String, IconData>{
    'calendar': Icons.calendar_today_rounded,
    'slack': Icons.tag_rounded,
    'notion': Icons.description_rounded,
    'jira': Icons.bug_report_rounded,
    'github': Icons.code_rounded,
    'linear': Icons.linear_scale_rounded,
    'salesforce': Icons.cloud_rounded,
    'hubspot': Icons.hub_rounded,
    'confluence': Icons.article_rounded,
    'trello': Icons.view_kanban_rounded,
    'asana': Icons.task_alt_rounded,
    'email': Icons.email_rounded,
    'zoom': Icons.videocam_rounded,
    'teams': Icons.groups_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final toolsAsync = ref.watch(aiToolsSchemaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Integrations'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: toolsAsync.when(
        loading: () => const AILoadingState(message: 'Loading integrations…'),
        error: (err, _) => AIErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(aiToolsSchemaProvider),
        ),
        data: (tools) {
          if (tools.isEmpty) {
            return const AIEmptyState(
              icon: Icons.extension_rounded,
              message: 'No integrations available',
              subMessage: 'Integrations will appear when configured',
            );
          }

          final connected =
              tools.where((t) => t['connected'] == true).toList();
          final available =
              tools.where((t) => t['connected'] != true).toList();

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(aiToolsSchemaProvider),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
              children: [
                if (connected.isNotEmpty) ...[
                  Text('Connected',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? SColors.textDark
                              : SColors.textLight)),
                  const SizedBox(height: 8),
                  ...connected.map((t) => _IntegrationTile(
                        name: t['name'] as String? ?? '',
                        desc: t['description'] as String? ?? '',
                        icon: _iconMap[
                                (t['icon'] as String? ?? '').toLowerCase()] ??
                            Icons.extension_rounded,
                        color: SColors.primary,
                        connected: true,
                        isDark: isDark,
                      )),
                  const SizedBox(height: 20),
                ],
                if (available.isNotEmpty) ...[
                  Text('Available',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? SColors.textDark
                              : SColors.textLight)),
                  const SizedBox(height: 8),
                  ...available.map((t) => _IntegrationTile(
                        name: t['name'] as String? ?? '',
                        desc: t['description'] as String? ?? '',
                        icon: _iconMap[
                                (t['icon'] as String? ?? '').toLowerCase()] ??
                            Icons.extension_rounded,
                        color: SColors.primary,
                        connected: false,
                        isDark: isDark,
                      )),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
                  decoration: BoxDecoration(
                    color: SColors.primary
                        .withValues(alpha: isDark ? 0.08 : 0.05),
                    borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.extension_rounded,
                          size: 20, color: SColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Request Integration',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: SColors.primary)),
                            Text('Don\'t see what you need? Let us know.',
                                style: TextStyle(
                                    fontSize: 11, color: SColors.primary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: SColors.primary, size: 20),
                    ],
                  ),
                ),
              ]
                  .animate(interval: 40.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.04, end: 0),
            ),
          );
        },
      ),
    ),
    );
  }
}

class _IntegrationTile extends StatelessWidget {
  final String name;
  final String desc;
  final IconData icon;
  final Color color;
  final bool connected;
  final bool isDark;
  const _IntegrationTile({required this.name, required this.desc, required this.icon, required this.color, required this.connected, required this.isDark});

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
                  Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                  Text(desc, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
            if (connected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: SColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(SSizes.radiusFull),
                ),
                child: const Text('Connected', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: SColors.success)),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder),
                  borderRadius: BorderRadius.circular(SSizes.radiusFull),
                ),
                child: Text('Connect', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
              ),
          ],
        ),
      ),
    );
  }
}
