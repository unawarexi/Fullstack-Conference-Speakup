import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/app/domain/models/legal_model.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/app/components/widgets/app_bar.dart';

/// Reusable legal document viewer — renders sections, items, subsections.
class LegalDocumentView extends StatelessWidget {
  final AsyncValue<LegalDocument> document;
  final String title;
  final VoidCallback? onRetry;

  const LegalDocumentView({
    super.key,
    required this.document,
    required this.title,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: SAppBar(title: title, showBack: true),
      body: ResponsiveBody(child: document.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, _) => RefreshIndicator(
          onRefresh: () async { onRetry?.call(); },
          color: SColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: _ErrorView(
                  message: error.toString(),
                  onRetry: onRetry,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
        data: (doc) => RefreshIndicator(
          onRefresh: () async { onRetry?.call(); },
          color: SColors.primary,
          child: _DocumentBody(document: doc, isDark: isDark),
        ),
      ),
    ),
    );
  }
}

// ─────────────────────────────────────────────
//  Document body — scrollable sections
// ─────────────────────────────────────────────
class _DocumentBody extends StatelessWidget {
  final LegalDocument document;
  final bool isDark;

  const _DocumentBody({required this.document, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor =
        isDark ? SColors.textDarkTertiary : SColors.textLightTertiary;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: SSizes.pagePadding,
        vertical: SSizes.lg,
      ),
      children: [
        // ── Header ──
        Text(
          document.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: SSizes.sm),
        Row(
          children: [
            _MetaBadge(
              label: 'Effective ${document.effectiveDate}',
              isDark: isDark,
            ),
            const SizedBox(width: SSizes.sm),
            _MetaBadge(
              label: 'v${document.version}',
              isDark: isDark,
            ),
          ],
        ),
        const SizedBox(height: SSizes.xs),
        Text(
          'Last updated: ${document.lastUpdated}',
          style: TextStyle(fontSize: 12, color: mutedColor),
        ),
        const SizedBox(height: SSizes.sectionSpacing),

        // ── Sections ──
        for (final section in document.sections) ...[
          _SectionView(section: section, isDark: isDark),
          const SizedBox(height: SSizes.lg),
        ],

        // ── Footer ──
        const Divider(height: SSizes.xl),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: SSizes.xl),
            child: Text(
              '© ${DateTime.now().year} SpeakUp. All rights reserved.',
              style: TextStyle(fontSize: 11, color: mutedColor),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Section renderer
// ─────────────────────────────────────────────
class _SectionView extends StatelessWidget {
  final LegalSection section;
  final bool isDark;

  const _SectionView({required this.section, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyColor =
        isDark ? SColors.textDarkSecondary : SColors.textLightSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Heading ──
        Text(
          section.heading,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: SSizes.sm),

        // ── Body text ──
        Text(
          section.body,
          style: TextStyle(
            fontSize: 14,
            color: bodyColor,
            height: 1.65,
          ),
        ),

        // ── Subsections (e.g., 2.1, 2.2) ──
        if (section.subsections.isNotEmpty) ...[
          const SizedBox(height: SSizes.md),
          for (final sub in section.subsections) ...[
            Text(
              sub.heading,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: SSizes.xs),
            _BulletList(items: sub.items, isDark: isDark),
            const SizedBox(height: SSizes.sm),
          ],
        ],

        // ── Bullet items ──
        if (section.items.isNotEmpty) ...[
          const SizedBox(height: SSizes.sm),
          _BulletList(items: section.items, isDark: isDark),
        ],

        // ── Footer text ──
        if (section.footer != null) ...[
          const SizedBox(height: SSizes.sm),
          Container(
            padding: const EdgeInsets.all(SSizes.cardPadding),
            decoration: BoxDecoration(
              color: isDark
                  ? SColors.darkCard.withValues(alpha: 0.6)
                  : SColors.lightElevated,
              borderRadius: BorderRadius.circular(SSizes.radiusSm),
              border: Border.all(
                color: isDark
                    ? SColors.darkBorder.withValues(alpha: 0.4)
                    : SColors.lightBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              section.footer!,
              style: TextStyle(
                fontSize: 13,
                color: bodyColor,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Bullet list
// ─────────────────────────────────────────────
class _BulletList extends StatelessWidget {
  final List<String> items;
  final bool isDark;

  const _BulletList({required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? SColors.textDarkSecondary : SColors.textLightSecondary;
    final bulletColor =
        isDark ? SColors.primary.withValues(alpha: 0.7) : SColors.primary;

    return Column(
      children: items.map((item) {
        // Split on " — " to bold the label portion
        final parts = item.split(' — ');
        final hasLabel = parts.length == 2;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 7, right: 10),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: bulletColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: hasLabel
                    ? Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${parts[0]} — ',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? SColors.textDark
                                    : SColors.textLight,
                                height: 1.55,
                              ),
                            ),
                            TextSpan(
                              text: parts[1],
                              style: TextStyle(
                                fontSize: 13.5,
                                color: textColor,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        item,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: textColor,
                          height: 1.55,
                        ),
                      ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
//  Meta badge (effective date, version)
// ─────────────────────────────────────────────
class _MetaBadge extends StatelessWidget {
  final String label;
  final bool isDark;

  const _MetaBadge({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? SColors.primary.withValues(alpha: 0.12)
            : SColors.primarySurface,
        borderRadius: BorderRadius.circular(SSizes.radiusFull),
        border: Border.all(
          color: SColors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? SColors.primaryLight : SColors.primaryDark,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Error view with retry
// ─────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool isDark;

  const _ErrorView({required this.message, this.onRetry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: SSizes.iconXl,
              color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
            ),
            const SizedBox(height: SSizes.md),
            Text(
              'Failed to load document',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? SColors.textDark : SColors.textLight,
              ),
            ),
            const SizedBox(height: SSizes.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? SColors.textDarkTertiary
                    : SColors.textLightTertiary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: SSizes.lg),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(CupertinoIcons.refresh, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
