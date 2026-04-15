import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/app/domain/models/ai_models.dart';
import 'package:flutter_conference_speakup/app/features/ai/usecases/action_items_usecase.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// AI-extracted action items from meetings, grouped by status.
class AIActionItemsScreen extends ConsumerStatefulWidget {
  const AIActionItemsScreen({super.key});

  @override
  ConsumerState<AIActionItemsScreen> createState() => _AIActionItemsScreenState();
}

class _AIActionItemsScreenState extends ConsumerState<AIActionItemsScreen> {
  int _filter = 0; // 0=all, 1=pending, 2=done

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemsAsync = ref.watch(allActionItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Action Items'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: itemsAsync.when(
        data: (items) {
          final filtered = _filter == 0
              ? items
              : _filter == 1
                  ? items.where((i) => !i.isCompleted).toList()
                  : items.where((i) => i.isCompleted).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(SSizes.md, SSizes.sm, SSizes.md, SSizes.sm),
                child: Row(
                  children: [
                    AIFilterChip(label: 'All', selected: _filter == 0, onTap: () => setState(() => _filter = 0), isDark: isDark),
                    const SizedBox(width: 8),
                    AIFilterChip(label: 'Pending', selected: _filter == 1, onTap: () => setState(() => _filter = 1), isDark: isDark),
                    const SizedBox(width: 8),
                    AIFilterChip(label: 'Done', selected: _filter == 2, onTap: () => setState(() => _filter = 2), isDark: isDark),
                  ],
                ),
              ),
              if (filtered.isEmpty)
                Expanded(child: AIEmptyState(
                  icon: Icons.check_circle_outline_rounded,
                  message: _filter == 2 ? 'No completed items' : 'No action items yet',
                  subMessage: 'Action items will appear after AI analyzes your meetings',
                ))
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => ref.invalidate(allActionItemsProvider),
                    color: SColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: SSizes.md),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _ActionItemTile(item: item, isDark: isDark);
                      },
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const AILoadingState(message: 'Loading action items...'),
        error: (e, _) => AIErrorState(
          message: 'Failed to load action items',
          onRetry: () => ref.invalidate(allActionItemsProvider),
        ),
      ),
    ),
    );
  }
}

class _ActionItemTile extends StatelessWidget {
  final ActionItem item;
  final bool isDark;
  const _ActionItemTile({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AIInsightCard(
      isDark: isDark,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: item.isCompleted ? SColors.success : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: item.isCompleted ? SColors.success : (isDark ? SColors.darkBorder : SColors.lightBorder),
                width: 1.5,
              ),
            ),
            child: item.isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: item.isCompleted
                        ? (isDark ? SColors.textDarkTertiary : SColors.textLightTertiary)
                        : (isDark ? SColors.textDark : SColors.textLight),
                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (item.assignee != null || item.deadline != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    [if (item.assignee != null) item.assignee!, if (item.deadline != null) item.deadline!].join(' · '),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AIPriorityDot(priority: item.priority),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}
