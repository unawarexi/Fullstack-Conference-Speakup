import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// AI Relationship Intelligence — interpersonal dynamics tracking.
class AIRelationshipsScreen extends ConsumerWidget {
  const AIRelationshipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardAsync = ref.watch(analyticsDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relationship Intelligence'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: dashboardAsync.when(
        loading: () => const AILoadingState(message: 'Loading relationships…'),
        error: (err, _) => AIErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(analyticsDashboardProvider),
        ),
        data: (dashboard) {
          final connections = (dashboard['connections'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final needsAttention = (dashboard['needsAttention'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final commStyles = (dashboard['communicationStyles'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          final totalMeetings = dashboard['totalMeetings'] ?? 0;
          final uniqueContacts = dashboard['uniqueContacts'] ?? 0;

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
            children: [
              // Summary
              Container(
                padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)]),
                  borderRadius: BorderRadius.circular(SSizes.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hub_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your Network Health', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text('$uniqueContacts active connections · ${needsAttention.length} need attention',
                              style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Needs attention
              if (needsAttention.isNotEmpty) ...[
                _title('Needs Reconnection', isDark),
                const SizedBox(height: 8),
                ...needsAttention.map((c) => _ContactCard(
                  c['name'] as String? ?? '',
                  c['role'] as String? ?? '',
                  c['note'] as String? ?? '',
                  (c['urgency'] as String? ?? '') == 'high' ? SColors.error : SColors.warning,
                  isDark: isDark,
                )),
                const SizedBox(height: 20),
              ],

              // Communication styles
              if (commStyles.isNotEmpty) ...[
                _title('Communication Preferences', isDark),
                const SizedBox(height: 8),
                ...commStyles.map((s) => _StyleCard(
                  s['name'] as String? ?? '',
                  s['style'] as String? ?? '',
                  s['detail'] as String? ?? '',
                  Icons.person_rounded,
                  isDark: isDark,
                )),
                const SizedBox(height: 20),
              ],

              // Stats
              _title('This Month', isDark),
              const SizedBox(height: 8),
              _StatRow('Total meetings', '$totalMeetings', isDark: isDark),
              _StatRow('Unique contacts', '$uniqueContacts', isDark: isDark),

              if (connections.isEmpty && needsAttention.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: AIEmptyState(icon: Icons.hub_rounded, message: 'No relationship data yet'),
                ),
            ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
          );
        },
      ),
    ),
    );
  }

  Widget _title(String text, bool isDark) => Text(text,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight));
}

class _ContactCard extends StatelessWidget {
  final String name;
  final String role;
  final String note;
  final Color urgency;
  final bool isDark;
  const _ContactCard(this.name, this.role, this.note, this.urgency, {required this.isDark});

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
            CircleAvatar(radius: 18, backgroundColor: urgency.withValues(alpha: 0.12),
                child: Text(name[0], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: urgency))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                    const SizedBox(width: 6),
                    Text('· $role', style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                  ]),
                  const SizedBox(height: 3),
                  Text(note, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleCard extends StatelessWidget {
  final String name;
  final String style;
  final String detail;
  final IconData icon;
  final bool isDark;
  const _StyleCard(this.name, this.style, this.detail, this.icon, {required this.isDark});

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
            Container(width: 36, height: 36,
              decoration: BoxDecoration(color: SColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: SColors.primary, size: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$name — $style', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                  const SizedBox(height: 2),
                  Text(detail, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _StatRow(this.label, this.value, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
        ],
      ),
    );
  }
}
