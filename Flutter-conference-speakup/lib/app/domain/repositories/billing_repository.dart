import 'package:video_confrence_app/core/network/api_client.dart';
import 'package:video_confrence_app/core/apis/endpoints.dart';
import 'package:video_confrence_app/app/domain/models/subscription_model.dart';

class BillingRepository {
  final _api = ApiClient.instance;

  Future<SubscriptionModel?> getSubscription() async {
    final res = await _api.get(ApiEndpoints.subscription);
    final data = res.data['data'];
    if (data == null) return null;
    return SubscriptionModel.fromJson(data);
  }

  /// Returns Stripe Checkout session URL.
  Future<String> createCheckout(String plan) async {
    final res = await _api.post(ApiEndpoints.billingCheckout, data: {
      'plan': plan,
    });
    return res.data['data']['url'] as String;
  }

  /// Returns Stripe Customer Portal URL.
  Future<String> createPortal() async {
    final res = await _api.post(ApiEndpoints.billingPortal);
    return res.data['data']['url'] as String;
  }

  Future<void> cancelSubscription() =>
      _api.post(ApiEndpoints.billingCancel);
}
