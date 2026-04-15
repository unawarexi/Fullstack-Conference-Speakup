import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
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
      body: ResponsiveBody(child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(subscriptionProvider),
        color: SColors.primary,
        child: subscriptionAsync.when(
          data: (sub) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
              SectionHeader(title: 'Actions'),
              DenseTile(
                icon: Icons.upgrade_rounded,
                title: 'Upgrade Plan',
                onTap: () => _handleUpgrade(context, ref),
                showChevron: true,
              ),
              DenseTile(
                icon: Icons.receipt_long_rounded,
                title: 'Manage Billing',
                onTap: () => _handlePortal(context, ref),
                showChevron: true,
              ),
              if (sub?.isPaid == true)
                DenseTile(
                  icon: Icons.cancel_rounded,
                  title: 'Cancel Subscription',
                  onTap: () => _handleCancel(context, ref),
                  showChevron: true,
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load billing info', style: TextStyle(color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(subscriptionProvider),
                child: const Text('Retry'),
              ),
            ],
          )),
        ),
      ),
    ),
    );
  }

  Future<void> _handleUpgrade(BuildContext context, WidgetRef ref) async {
    try {
      final url = await ref.read(billingRepositoryProvider).createCheckout('pro');
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start checkout'), backgroundColor: SColors.error),
        );
      }
    }
  }

  Future<void> _handlePortal(BuildContext context, WidgetRef ref) async {
    try {
      final url = await ref.read(billingRepositoryProvider).createPortal();
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open billing portal'), backgroundColor: SColors.error),
        );
      }
    }
  }

  Future<void> _handleCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text('Are you sure? You\'ll lose access to premium features at the end of your billing period.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel Subscription', style: TextStyle(color: SColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref.read(billingRepositoryProvider).cancelSubscription();
        ref.invalidate(subscriptionProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Subscription cancelled'), backgroundColor: SColors.success),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel'), backgroundColor: SColors.error),
          );
        }
      }
    }
  }
}
