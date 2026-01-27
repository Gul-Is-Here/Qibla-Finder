class SubscriptionProduct {
  final String id;
  final String title;
  final String description;
  final String price;
  final String currencyCode;
  final int priceInMicros;
  final Duration duration;
  final bool isPakistanPrice;

  SubscriptionProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currencyCode,
    required this.priceInMicros,
    required this.duration,
    this.isPakistanPrice = false,
  });

  bool get isMonthly => duration == const Duration(days: 30);
  bool get isYearly => duration == const Duration(days: 365);

  String get durationText => isMonthly ? 'Monthly' : 'Yearly';

  String get savings {
    if (isYearly) {
      return isPakistanPrice ? 'Save Rs. 300' : 'Save \$6';
    }
    return '';
  }
}

// Subscription Product IDs (to be created in Google Play Console)
class SubscriptionIds {
  // Pakistan Subscriptions
  static const String pakistanMonthly = 'pk_premium_monthly';
  static const String pakistanYearly = 'pk_premium_yearly';

  // International Subscriptions
  static const String internationalMonthly = 'intl_premium_monthly';
  static const String internationalYearly = 'intl_premium_yearly';

  static List<String> get allIds => [
    pakistanMonthly,
    pakistanYearly,
    internationalMonthly,
    internationalYearly,
  ];

  static List<String> getPakistanIds() => [pakistanMonthly, pakistanYearly];
  static List<String> getInternationalIds() => [internationalMonthly, internationalYearly];
}

class SubscriptionStatus {
  final bool isPremium;
  final String? productId;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;
  final bool isAutoRenewing;

  SubscriptionStatus({
    this.isPremium = false,
    this.productId,
    this.purchaseDate,
    this.expiryDate,
    this.isAutoRenewing = false,
  });

  bool get isActive {
    if (!isPremium) return false;
    if (expiryDate == null) return false;
    return DateTime.now().isBefore(expiryDate!);
  }

  String get statusText {
    if (!isPremium) return 'Free Plan';
    if (isActive) {
      final days = expiryDate!.difference(DateTime.now()).inDays;
      return 'Premium ($days days remaining)';
    }
    return 'Expired';
  }

  Map<String, dynamic> toMap() {
    return {
      'isPremium': isPremium,
      'productId': productId,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'isAutoRenewing': isAutoRenewing,
    };
  }

  factory SubscriptionStatus.fromMap(Map<String, dynamic> map) {
    return SubscriptionStatus(
      isPremium: map['isPremium'] ?? false,
      productId: map['productId'],
      purchaseDate: map['purchaseDate'] != null ? DateTime.parse(map['purchaseDate']) : null,
      expiryDate: map['expiryDate'] != null ? DateTime.parse(map['expiryDate']) : null,
      isAutoRenewing: map['isAutoRenewing'] ?? false,
    );
  }
}
