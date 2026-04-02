enum SubscriptionPlan { free, pro, enterprise }

enum SubscriptionStatus { active, cancelled, pastDue, trialing }

class SubscriptionModel {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final String? stripeCustomerId;
  final String? stripeSubId;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? canceledAt;
  final DateTime createdAt;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    this.plan = SubscriptionPlan.free,
    this.status = SubscriptionStatus.active,
    this.stripeCustomerId,
    this.stripeSubId,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.canceledAt,
    required this.createdAt,
  });

  bool get isActive => status == SubscriptionStatus.active;
  bool get isPro => plan == SubscriptionPlan.pro;
  bool get isEnterprise => plan == SubscriptionPlan.enterprise;
  bool get isPaid => isPro || isEnterprise;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] as String? ?? 'ACTIVE')
        .toLowerCase()
        .replaceAllMapped(
            RegExp(r'_([a-z])'), (m) => m.group(1)!.toUpperCase());
    return SubscriptionModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      plan: SubscriptionPlan.values.byName(
          (json['plan'] as String? ?? 'FREE').toLowerCase()),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => SubscriptionStatus.active,
      ),
      stripeCustomerId: json['stripeCustomerId'] as String?,
      stripeSubId: json['stripeSubId'] as String?,
      currentPeriodStart: json['currentPeriodStart'] != null
          ? DateTime.parse(json['currentPeriodStart'] as String)
          : null,
      currentPeriodEnd: json['currentPeriodEnd'] != null
          ? DateTime.parse(json['currentPeriodEnd'] as String)
          : null,
      canceledAt: json['canceledAt'] != null
          ? DateTime.parse(json['canceledAt'] as String)
          : null,
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'plan': plan.name.toUpperCase(),
        'status': status.name.toUpperCase(),
        'currentPeriodStart': currentPeriodStart?.toIso8601String(),
        'currentPeriodEnd': currentPeriodEnd?.toIso8601String(),
        'canceledAt': canceledAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };
}
