import 'package:flutter_test/flutter_test.dart';
import 'package:video_confrence_app/app/domain/models/subscription_model.dart';

void main() {
  final now = DateTime(2026, 4, 2);

  group('SubscriptionModel', () {
    final json = {
      'id': 'sub-1',
      'userId': 'user-1',
      'plan': 'PRO',
      'status': 'ACTIVE',
      'stripeCustomerId': 'cus_test',
      'stripeSubId': 'sub_test',
      'currentPeriodStart': now.toIso8601String(),
      'currentPeriodEnd': now.add(const Duration(days: 30)).toIso8601String(),
      'canceledAt': null,
      'createdAt': now.toIso8601String(),
    };

    test('fromJson parses all fields', () {
      final sub = SubscriptionModel.fromJson(json);
      expect(sub.id, 'sub-1');
      expect(sub.userId, 'user-1');
      expect(sub.plan, SubscriptionPlan.pro);
      expect(sub.status, SubscriptionStatus.active);
      expect(sub.stripeCustomerId, 'cus_test');
      expect(sub.isActive, true);
      expect(sub.isPro, true);
      expect(sub.isPaid, true);
    });

    test('isActive is true only for active status', () {
      final active = SubscriptionModel.fromJson(json);
      expect(active.isActive, true);
      final cancelled =
          SubscriptionModel.fromJson({...json, 'status': 'CANCELLED'});
      expect(cancelled.isActive, false);
    });

    test('isPaid is true for pro and enterprise', () {
      final pro = SubscriptionModel.fromJson(json);
      expect(pro.isPaid, true);
      final enterprise =
          SubscriptionModel.fromJson({...json, 'plan': 'ENTERPRISE'});
      expect(enterprise.isPaid, true);
      expect(enterprise.isEnterprise, true);
      final free = SubscriptionModel.fromJson({...json, 'plan': 'FREE'});
      expect(free.isPaid, false);
    });

    test('fromJson handles PAST_DUE status (SNAKE_CASE to camelCase)', () {
      final sub =
          SubscriptionModel.fromJson({...json, 'status': 'PAST_DUE'});
      expect(sub.status, SubscriptionStatus.pastDue);
    });

    test('fromJson handles TRIALING status', () {
      final sub =
          SubscriptionModel.fromJson({...json, 'status': 'TRIALING'});
      expect(sub.status, SubscriptionStatus.trialing);
    });

    test('toJson round-trip', () {
      final sub = SubscriptionModel.fromJson(json);
      final output = sub.toJson();
      expect(output['plan'], 'PRO');
      expect(output['status'], 'ACTIVE');
    });
  });
}
