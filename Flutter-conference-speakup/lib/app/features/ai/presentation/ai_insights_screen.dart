import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';

/// All AI insights in one hub — suggestions, predictions, knowledge gaps.
class AIInsightsScreen extends ConsumerWidget {
  const AIInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final countsAsync = ref.watch(analyticsDashboardProvider);
    final counts = countsAsync.valueOrNull?['insightCounts'] as Map<String, dynamic>? ?? {};
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Insights'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: ListView(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
        children: [
          _InsightCategoryCard(
            icon: Icons.auto_awesome_rounded,
            title: 'Meeting Suggestions',
            subtitle: 'AI-generated reasons to connect with your team',
            gradient: SColors.accentGradient,
            isDark: isDark,
            onTap: () => context.push('/ai-insights/meeting-prep'),
          ),
          const SizedBox(height: 12),
          _InsightCategoryCard(
            icon: Icons.psychology_rounded,
            title: 'Coaching Reports',
            subtitle: 'Your speaking performance trends & tips',
            gradient: SColors.primaryGradient,
            isDark: isDark,
            onTap: () => context.push('/ai-insights/coach'),
          ),
          const SizedBox(height: 12),
          _InsightCategoryCard(
            icon: Icons.checklist_rounded,
            title: 'Action Items',
            subtitle: counts['actionItems'] != null ? '${counts['actionItems']} pending items from recent meetings' : 'Track your action items',
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF34D399)],
            ),
            isDark: isDark,
            onTap: () => context.push('/ai-insights/action-items'),
          ),
          const SizedBox(height: 12),
          _InsightCategoryCard(
            icon: Icons.hub_rounded,
            title: 'Relationship Intelligence',
            subtitle: 'Track your interpersonal dynamics',
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
            ),
            isDark: isDark,
            onTap: () => context.push('/ai-insights/relationships'),
          ),
          const SizedBox(height: 12),
          _InsightCategoryCard(
            icon: Icons.trending_up_rounded,
            title: 'Outcome Predictions',
            subtitle: 'AI-estimated meeting success probabilities',
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
            ),
            isDark: isDark,
            onTap: () => context.push('/ai-insights/predictions'),
          ),
          const SizedBox(height: 12),
          _InsightCategoryCard(
            icon: Icons.article_rounded,
            title: 'Meeting Summaries',
            subtitle: 'AI-generated recaps with key decisions',
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFF87171)],
            ),
            isDark: isDark,
            onTap: () => context.push('/ai-insights/summaries'),
          ),
          const SizedBox(height: 12),
          _InsightCategoryCard(
            icon: Icons.document_scanner_rounded,
            title: 'Document Intelligence',
            subtitle: 'Parse, extract & analyze meeting documents',
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
            ),
            isDark: isDark,
            onTap: () => context.push('/ai-insights/documents'),
          ),
          const SizedBox(height: 12),
          _InsightCategoryCard(
            icon: Icons.memory_rounded,
            title: 'Meeting Memory',
            subtitle: 'Search across all meetings semantically',
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
            ),
            isDark: isDark,
            onTap: () => context.push('/ai-insights/memory'),
          ),
        ].animate(interval: 60.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
      ),
    ),
    );
  }
}

class _InsightCategoryCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final bool isDark;
  final VoidCallback? onTap;

  const _InsightCategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.isDark,
    this.onTap,
  });

  @override
  State<_InsightCategoryCard> createState() => _InsightCategoryCardState();
}

class _InsightCategoryCardState extends State<_InsightCategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
          decoration: BoxDecoration(
            color: widget.isDark ? SColors.darkCard : SColors.lightCard,
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            border: Border.all(
              color: widget.isDark ? SColors.darkBorder : SColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: widget.isDark ? SColors.textDark : SColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDark
                            ? SColors.textDarkSecondary
                            : SColors.textLightSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 20,
                  color: widget.isDark
                      ? SColors.textDarkTertiary
                      : SColors.textLightTertiary),
            ],
          ),
        ),
      ),
);
  }
}
