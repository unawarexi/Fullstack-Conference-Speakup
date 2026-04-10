import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/store/billing_provider.dart';

class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
      appBar: AppBar(
        title: Text('Billing', style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: isDark ? SColors.textDark : SColors.textLight,
        )),
      ),
      body: subscriptionAsync.when(
        data: (sub) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionHeader(title: 'Subscription'),
            const SizedBox(height: 8),
            DenseTile(
              icon: Icons.diamond_rounded,
              iconColor: SColors.primary,
              title: sub != null ? '${sub.plan.name[0].toUpperCase()}${sub.plan.name.substring(1)} Plan' : 'Free Plan',
              subtitle: sub?.isPaid == true ? 'Active subscription' : 'Basic features included',
              trailing: sub?.isPaid == true
                  ? StatusBadge(label: 'Active', color: SColors.success)
                  : StatusBadge(label: 'Free', color: SColors.darkMuted),
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Payment History'),
            ...List.generate(3, (i) => DenseTile(
              icon: Icons.receipt_long_rounded,
              title: 'Invoice #${i + 1}',
              subtitle: 'Paid · 2024-0${i + 1}-15',
              trailing: StatusBadge(label: 'Paid', color: SColors.success),
              hasDivider: i < 2,
            )),
            const SizedBox(height: 24),
            SectionHeader(title: 'Actions'),
            DenseTile(
              icon: Icons.upgrade_rounded,
              title: 'Upgrade Plan',
              onTap: () {},
              showChevron: true,
            ),
            DenseTile(
              icon: Icons.cancel_rounded,
              title: 'Cancel Subscription',
              onTap: () {},
              showChevron: true,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load billing info', style: TextStyle(color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary))),
      ),
    );
  }
}
