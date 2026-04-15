import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// People Directory — contacts with AI relationship scores and meeting affinity.
class PeopleDirectoryScreen extends ConsumerStatefulWidget {
  const PeopleDirectoryScreen({super.key});

  @override
  ConsumerState<PeopleDirectoryScreen> createState() => _PeopleDirectoryScreenState();
}

class _PeopleDirectoryScreenState extends ConsumerState<PeopleDirectoryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analyticsAsync = ref.watch(analyticsDashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(fontSize: 14, color: isDark ? SColors.textDark : SColors.textLight),
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: TextStyle(color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
                filled: true,
                fillColor: isDark ? SColors.darkCard : SColors.lightCard,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(SSizes.radiusMd), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: analyticsAsync.when(
              loading: () => const AILoadingState(message: 'Loading contacts...'),
              error: (e, _) => AIErrorState(message: e.toString(), onRetry: () => ref.invalidate(analyticsDashboardProvider)),
              data: (data) {
                final allPeople = (data['people'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                final filtered = _query.isEmpty
                    ? allPeople
                    : allPeople.where((p) =>
                        (p['name'] as String? ?? '').toLowerCase().contains(_query.toLowerCase()) ||
                        (p['role'] as String? ?? '').toLowerCase().contains(_query.toLowerCase())).toList();
                final strongCount = allPeople.where((p) => (p['score'] as int? ?? 0) >= 70).length;
                final needAttentionCount = allPeople.where((p) => (p['score'] as int? ?? 0) < 50).length;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: SSizes.md),
                      child: Row(
                        children: [
                          _StatChip(label: '${allPeople.length} contacts', isDark: isDark),
                          const SizedBox(width: 8),
                          _StatChip(label: '$strongCount strong', isDark: isDark),
                          const SizedBox(width: 8),
                          _StatChip(label: '$needAttentionCount need attention', isDark: isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: AIEmptyState(icon: Icons.people_rounded, message: 'No contacts found'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: SSizes.md),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final p = filtered[index];
                                final person = _Person(
                                  name: p['name'] as String? ?? '',
                                  role: p['role'] as String? ?? '',
                                  meetings: p['meetings'] as int? ?? 0,
                                  lastMet: p['lastMet'] as String? ?? '',
                                  score: p['score'] as int? ?? 0,
                                );
                                return _PersonTile(person: person, isDark: isDark)
                                    .animate()
                                    .fadeIn(duration: 200.ms, delay: (index * 40).ms)
                                    .slideY(begin: 0.03, end: 0);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _Person {
  final String name;
  final String role;
  final int meetings;
  final String lastMet;
  final int score; // relationship strength 0-100
  const _Person({required this.name, required this.role, required this.meetings, required this.lastMet, required this.score});
}

class _StatChip extends StatelessWidget {
  final String label;
  final bool isDark;
  const _StatChip({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? SColors.darkCard : SColors.lightCard,
        borderRadius: BorderRadius.circular(SSizes.radiusFull),
        border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
    );
  }
}

class _PersonTile extends StatelessWidget {
  final _Person person;
  final bool isDark;
  const _PersonTile({required this.person, required this.isDark});

  Color get _scoreColor {
    if (person.score >= 70) return SColors.success;
    if (person.score >= 50) return SColors.warning;
    return SColors.error;
  }

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
            CircleAvatar(
              radius: 20,
              backgroundColor: SColors.primary.withValues(alpha: 0.1),
              child: Text(person.name[0], style: const TextStyle(fontWeight: FontWeight.w700, color: SColors.primary)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(person.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                  Text(person.role, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                  const SizedBox(height: 3),
                  Text('${person.meetings} meetings · Last met ${person.lastMet}', style: TextStyle(fontSize: 10, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _scoreColor.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Center(child: Text('${person.score}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _scoreColor))),
                ),
                const SizedBox(height: 2),
                Text('score', style: TextStyle(fontSize: 8, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
