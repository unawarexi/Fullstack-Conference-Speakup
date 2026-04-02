import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_confrence_app/app/domain/repositories/billing_repository.dart';
import 'package:video_confrence_app/app/domain/models/subscription_model.dart';

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  return BillingRepository();
});

/// Current user subscription.
final subscriptionProvider =
    FutureProvider.autoDispose<SubscriptionModel?>((ref) {
  return ref.read(billingRepositoryProvider).getSubscription();
});
