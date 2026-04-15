import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';
import 'package:flutter_conference_speakup/app/domain/models/ai_models.dart';

/// AI Workflow Automation — pre/post-meeting automated actions.
class AIWorkflowsScreen extends ConsumerWidget {
  const AIWorkflowsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workflowsAsync = ref.watch(aiActiveWorkflowsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workflow Automation'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: workflowsAsync.when(
        loading: () => const AILoadingState(message: 'Loading workflows…'),
        error: (err, _) => AIErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(aiActiveWorkflowsProvider),
        ),
        data: (workflows) {
          if (workflows.isEmpty) {
            return const AIEmptyState(
              icon: Icons.auto_fix_high_rounded,
              message: 'No workflows found',
              subMessage: 'Workflows will appear when configured',
            );
          }

          final running =
              workflows.where((w) => w.status == 'running').toList();
          final completed =
              workflows.where((w) => w.status == 'completed').toList();
          final failed =
              workflows.where((w) => w.status == 'failed').toList();
          final other = workflows
              .where((w) =>
                  w.status != 'running' &&
                  w.status != 'completed' &&
                  w.status != 'failed')
              .toList();

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(aiActiveWorkflowsProvider),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
              children: [
                if (running.isNotEmpty) ...[
                  Text('Running',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? SColors.textDark
                              : SColors.textLight)),
                  const SizedBox(height: 10),
                  ...running
                      .map((w) => _WorkflowCard(workflow: w, isDark: isDark)),
                  const SizedBox(height: 20),
                ],
                if (completed.isNotEmpty) ...[
                  Text('Completed',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? SColors.textDark
                              : SColors.textLight)),
                  const SizedBox(height: 10),
                  ...completed
                      .map((w) => _WorkflowCard(workflow: w, isDark: isDark)),
                  const SizedBox(height: 20),
                ],
                if (failed.isNotEmpty) ...[
                  Text('Failed',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? SColors.textDark
                              : SColors.textLight)),
                  const SizedBox(height: 10),
                  ...failed
                      .map((w) => _WorkflowCard(workflow: w, isDark: isDark)),
                  const SizedBox(height: 20),
                ],
                if (other.isNotEmpty) ...[
                  Text('Other',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? SColors.textDark
                              : SColors.textLight)),
                  const SizedBox(height: 10),
                  ...other
                      .map((w) => _WorkflowCard(workflow: w, isDark: isDark)),
                ],
              ]
                  .animate(interval: 50.ms)
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

class _WorkflowCard extends StatelessWidget {
  final WorkflowStatus workflow;
  final bool isDark;
  const _WorkflowCard({required this.workflow, required this.isDark});

  Color get _statusColor => switch (workflow.status) {
        'running' => SColors.primary,
        'completed' => SColors.success,
        'failed' => SColors.error,
        _ => SColors.warning,
      };

  IconData get _statusIcon => switch (workflow.status) {
        'running' => Icons.play_circle_rounded,
        'completed' => Icons.check_circle_rounded,
        'failed' => Icons.error_rounded,
        _ => Icons.pending_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final stepsTotal = workflow.steps.length;
    final stepsDone =
        workflow.steps.where((s) => s.status == 'completed').length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(
              color: isDark ? SColors.darkBorder : SColors.lightBorder,
              width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_statusIcon, color: _statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(workflow.workflowId,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? SColors.textDark
                                    : SColors.textLight))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(SSizes.radiusFull),
                      ),
                      child: Text(
                        workflow.status[0].toUpperCase() +
                            workflow.status.substring(1),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _statusColor),
                      ),
                    ),
                  ]),
                  if (workflow.currentStep != null) ...[
                    const SizedBox(height: 3),
                    Text('Step: ${workflow.currentStep}',
                        style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? SColors.textDarkSecondary
                                : SColors.textLightSecondary)),
                  ],
                  if (stepsTotal > 0) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: workflow.progress > 0
                            ? workflow.progress
                            : (stepsTotal > 0
                                ? stepsDone / stepsTotal
                                : 0),
                        backgroundColor:
                            _statusColor.withValues(alpha: 0.1),
                        valueColor:
                            AlwaysStoppedAnimation(_statusColor),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text('$stepsDone / $stepsTotal steps',
                        style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? SColors.textDarkSecondary
                                : SColors.textLightSecondary)),
                  ],
                  if (workflow.error != null) ...[
                    const SizedBox(height: 4),
                    Text(workflow.error!,
                        style: const TextStyle(
                            fontSize: 10, color: SColors.error)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
