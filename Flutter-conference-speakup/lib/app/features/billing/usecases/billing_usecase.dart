import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/billing_repository.dart';
import 'package:flutter_conference_speakup/app/domain/models/subscription_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Billing business logic — upgrade, downgrade, cancel, and portal access.
class BillingUseCase {
  final BillingRepository _repo;
  BillingUseCase(this._repo);

  Future<SubscriptionModel?> getCurrentSubscription() => _repo.getSubscription();

  /// Start upgrade flow — opens Stripe Checkout in browser.
  Future<bool> upgradePlan(String plan) async {
    final url = await _repo.createCheckout(plan);
    return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// Open Stripe Customer Portal for invoice/payment management.
  Future<bool> openBillingPortal() async {
    final url = await _repo.createPortal();
    return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  /// Cancel the active subscription.
  Future<void> cancelSubscription() => _repo.cancelSubscription();
}

final billingUseCaseProvider = Provider<BillingUseCase>((ref) {
  return BillingUseCase(BillingRepository());
});
