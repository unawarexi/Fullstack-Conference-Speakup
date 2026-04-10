import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // TODO: Replace with real analytics data
    final stats = [
      {'label': 'Meetings', 'value': '42', 'icon': Icons.video_call, 'color': SColors.primary, 'change': '+12%', 'isPositive': true},
      {'label': 'Minutes', 'value': '1.2k', 'icon': Icons.timer, 'color': SColors.success, 'change': '+8%', 'isPositive': true},
      {'label': 'Participants', 'value': '320', 'icon': Icons.people, 'color': SColors.info, 'change': '-2%', 'isPositive': false},
      {'label': 'Recordings', 'value': '18', 'icon': Icons.fiber_smart_record, 'color': SColors.error, 'change': '+3%', 'isPositive': true},
    ];

    return Scaffold(
      backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
      appBar: AppBar(
        title: Text('Analytics', style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: isDark ? SColors.textDark : SColors.textLight,
        )),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(title: 'Overview'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: stats.map((s) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: StatCard(
                  label: s['label'] as String,
                  value: s['value'] as String,
                  icon: s['icon'] as IconData,
                  color: s['color'] as Color,
                  change: s['change'] as String?,
                  isPositive: s['isPositive'] as bool,
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'Usage Trends'),
          Container(
            height: 180,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? SColors.darkCard : SColors.lightCard,
              borderRadius: BorderRadius.circular(SSizes.radiusMd),
            ),
            child: const Center(child: Text('TODO: Add charts')), // Placeholder
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'Recent Activity'),
          ...List.generate(5, (i) => DenseTile(
            icon: Icons.event,
            title: 'Meeting #${i + 1}',
            subtitle: DateFormat.yMMMd().format(DateTime.now().subtract(Duration(days: i))),
            trailing: StatusBadge(label: 'Ended', color: SColors.darkMuted),
            onTap: () {},
            hasDivider: i < 4,
          )),
        ],
      ),
    );
  }
}
