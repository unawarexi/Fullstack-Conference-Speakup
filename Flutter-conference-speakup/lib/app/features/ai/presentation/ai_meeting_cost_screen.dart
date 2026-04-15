import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// AI Meeting Cost Calculator — estimates time & money spent in meetings.
class AIMeetingCostScreen extends ConsumerWidget {
  const AIMeetingCostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardAsync = ref.watch(analyticsDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Cost'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: dashboardAsync.when(
        loading: () => const AILoadingState(message: 'Calculating costs…'),
        error: (e, _) => AIErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(analyticsDashboardProvider),
        ),
        data: (dashboard) {
          final costData = dashboard['meeting_cost'] as Map<String, dynamic>? ?? {};
          final monthlyTotal = (costData['monthly_total'] as num?) ?? 0;
          final averageCost = (costData['average_cost'] as num?) ?? 0;
          final currency = costData['currency'] as String? ?? 'USD';
          final expensiveMeetings = (costData['expensive_meetings'] as List<dynamic>?) ?? [];
          final savingsTips = (costData['savings_tips'] as List<dynamic>?) ?? [];

          final currencySymbol = currency == 'USD' ? '\$' : currency;

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
            children: [
              // Monthly overview
              Container(
                padding: const EdgeInsets.all(SSizes.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFF87171)]),
                  borderRadius: BorderRadius.circular(SSizes.radiusMd),
                ),
                child: Column(
                  children: [
                    const Text('This Month\'s Meeting Cost', style: TextStyle(fontSize: 13, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text('$currencySymbol${monthlyTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('Avg $currencySymbol${averageCost.toStringAsFixed(0)} per meeting', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Cost breakdown
              Row(
                children: [
                  Expanded(child: _CostCard(label: 'Avg. per meeting', value: '$currencySymbol${averageCost.toStringAsFixed(0)}', icon: Icons.attach_money_rounded, isDark: isDark)),
                  const SizedBox(width: 10),
                  Expanded(child: _CostCard(label: 'Monthly total', value: '$currencySymbol${monthlyTotal.toStringAsFixed(0)}', icon: Icons.calendar_month_rounded, isDark: isDark)),
                ],
              ),
              const SizedBox(height: 16),
              // Top expensive meetings
              if (expensiveMeetings.isNotEmpty) ...[
                Text('Most Expensive Meetings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                const SizedBox(height: 8),
                ...expensiveMeetings.map((item) {
                  final m = item as Map<String, dynamic>;
                  final title = m['title'] as String? ?? m['name'] as String? ?? 'Unknown';
                  final cost = (m['cost'] as num?) ?? 0;
                  final attendees = (m['attendees'] as num?) ?? 0;
                  final duration = m['duration'] as String? ?? '';
                  return _ExpensiveTile(
                    title: title,
                    cost: '$currencySymbol${cost.toStringAsFixed(0)}',
                    attendees: attendees.toInt(),
                    duration: duration,
                    isDark: isDark,
                  );
                }),
                const SizedBox(height: 16),
              ],
              // AI recommendations
              if (savingsTips.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
                  decoration: BoxDecoration(
                    color: SColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
                    borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 16, color: SColors.primary),
                          SizedBox(width: 8),
                          Text('AI Cost Reduction Tips', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...savingsTips.map((tip) {
                        if (tip is Map<String, dynamic>) {
                          final text = tip['tip'] as String? ?? tip['description'] as String? ?? '';
                          final saving = tip['saving'] as String? ?? '';
                          return _SaveTip(tip: text, saving: saving);
                        }
                        return _SaveTip(tip: tip.toString(), saving: '');
                      }),
                    ],
                  ),
                ),
            ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
          );
        },
      ),
    ),
    );
  }
}

class _CostCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;
  const _CostCard({required this.label, required this.value, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
      decoration: BoxDecoration(
        color: isDark ? SColors.darkCard : SColors.lightCard,
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
        border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: SColors.primary),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
        ],
      ),
    );
  }
}

class _ExpensiveTile extends StatelessWidget {
  final String title;
  final String cost;
  final int attendees;
  final String duration;
  final bool isDark;
  const _ExpensiveTile({required this.title, required this.cost, required this.attendees, required this.duration, required this.isDark});

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                  Text('${attendees > 0 ? '$attendees people' : ''}${attendees > 0 && duration.isNotEmpty ? ' · ' : ''}$duration', style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
            Text(cost, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: SColors.error)),
          ],
        ),
      ),
    );
  }
}

class _SaveTip extends StatelessWidget {
  final String tip;
  final String saving;
  const _SaveTip({required this.tip, required this.saving});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 12, color: SColors.primary)),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 12, color: SColors.primary))),
          if (saving.isNotEmpty)
            Text(saving, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SColors.success)),
        ],
      ),
    );
  }
}
