import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// AI Meeting Memory — semantic search across all meetings.
class AIMemoryScreen extends ConsumerStatefulWidget {
  const AIMemoryScreen({super.key});

  @override
  ConsumerState<AIMemoryScreen> createState() => _AIMemoryScreenState();
}

class _AIMemoryScreenState extends ConsumerState<AIMemoryScreen> {
  final _controller = TextEditingController();
  String? _activeQuery;

  void _doSearch() {
    final q = _controller.text.trim();
    if (q.isNotEmpty) setState(() => _activeQuery = q);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Memory'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _doSearch(),
              decoration: InputDecoration(
                hintText: 'Search across all meetings semantically...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded, size: 18),
                  onPressed: _doSearch,
                ),
                filled: true,
                fillColor: isDark ? SColors.darkCard : SColors.lightElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          Expanded(
            child: _activeQuery != null
                ? _SearchResults(query: _activeQuery!, isDark: isDark)
                : _MemoryOverview(
                    isDark: isDark,
                    onSuggestionTap: (text) {
                      _controller.text = text;
                      setState(() => _activeQuery = text);
                    },
                  ),
          ),
        ],
      ),
    ),
    );
  }
}

class _MemoryOverview extends StatelessWidget {
  final bool isDark;
  final ValueChanged<String> onSuggestionTap;
  const _MemoryOverview({required this.isDark, required this.onSuggestionTap});

  static const _suggestions = [
    'What did we decide about the pricing model?',
    'Who promised to deliver the API docs?',
    'When was Redis caching last discussed?',
    'Show all action items for Sarah',
    'What were the key risks from investor meetings?',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: SSizes.md),
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF818CF8)]),
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.memory_rounded, color: Colors.white, size: 28),
              SizedBox(height: 8),
              Text('Your Meeting Memory',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              SizedBox(height: 4),
              Text('Search semantically across all your meetings',
                  style: TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Try asking',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? SColors.textDark : SColors.textLight)),
        const SizedBox(height: 8),
        ..._suggestions.map((s) =>
            _SuggestionChip(s, isDark: isDark, onTap: () => onSuggestionTap(s))),
      ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(
          begin: 0.04, end: 0),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;
  final bool isDark;
  const _SearchResults({required this.query, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(aiMemoryQueryProvider(query));

    return resultsAsync.when(
      loading: () => const AILoadingState(message: 'Searching memory…'),
      error: (err, _) => AIErrorState(
        message: err.toString(),
        onRetry: () => ref.invalidate(aiMemoryQueryProvider(query)),
      ),
      data: (results) {
        if (results.isEmpty) {
          return const AIEmptyState(
            icon: Icons.search_off_rounded,
            message: 'No results found',
            subMessage: 'Try a different search query',
          );
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: SSizes.md),
          children: [
            Text('Results',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? SColors.textDark : SColors.textLight)),
            const SizedBox(height: 10),
            ...results.map((r) => _ResultCard(
                  r['title'] as String? ?? 'Untitled',
                  r['snippet'] as String? ?? r['content'] as String? ?? '',
                  (r['relevance'] as num?)?.toDouble() ?? 0,
                  isDark: isDark,
                )),
          ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(
              begin: 0.04, end: 0),
        );
      },
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final bool isDark;
  final VoidCallback? onTap;
  const _SuggestionChip(this.text, {required this.isDark, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? SColors.darkCard : SColors.lightCard,
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 16, color: SColors.primary.withValues(alpha: 0.6)),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String snippet;
  final double relevance;
  final bool isDark;
  const _ResultCard(this.title, this.snippet, this.relevance, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: SColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                  child: Text('${(relevance * 100).round()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: SColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(snippet, style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
          ],
        ),
      ),
    );
  }
}
