class PricingDetail {
  final num baseRatePerMinute;
  final num discountedRatePerMinute;
  final num astrologerSharePercentage;
  final num adminSharePercentage;
  final num estimatedAstrologerEarningPerMinute;
  final num estimatedAdminEarningPerMinute;

  PricingDetail({
    required this.baseRatePerMinute,
    required this.discountedRatePerMinute,
    required this.astrologerSharePercentage,
    required this.adminSharePercentage,
    required this.estimatedAstrologerEarningPerMinute,
    required this.estimatedAdminEarningPerMinute,
  });

  factory PricingDetail.fromJson(Map<String, dynamic> json) {
    return PricingDetail(
      baseRatePerMinute: json['original_price_per_minute'] ?? 0,
      discountedRatePerMinute: json['discounted_price_per_minute'] ?? 0,
      astrologerSharePercentage: json['astrologer_share_percentage'] ?? 0,
      adminSharePercentage: json['admin_share_percentage'] ?? 0,
      estimatedAstrologerEarningPerMinute:
          json['astrologer_payout_per_minute'] ?? 0,
      estimatedAdminEarningPerMinute: json['admin_revenue_per_minute'] ?? 0,
    );
  }
}

class CalculatedPricing {
  final PricingDetail? chat;
  final PricingDetail? call;

  CalculatedPricing({this.chat, this.call});

  factory CalculatedPricing.fromJson(Map<String, dynamic> json) {
    return CalculatedPricing(
      chat: json['chat'] != null ? PricingDetail.fromJson(json['chat']) : null,
      call: json['call'] != null ? PricingDetail.fromJson(json['call']) : null,
    );
  }
}

class OfferModel {
  final int id;
  final String name;
  final num discountPercentage;
  final String? expiresAt;
  bool isCurrentlyActiveForMe;
  final CalculatedPricing? calculatedPricing;

  OfferModel({
    required this.id,
    required this.name,
    required this.discountPercentage,
    this.expiresAt,
    this.isCurrentlyActiveForMe = false,
    this.calculatedPricing,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      discountPercentage: json['discount_percentage'] ?? 0,
      expiresAt: json['expires_at'],
      isCurrentlyActiveForMe: json['is_currently_active'] ?? false,
      calculatedPricing: CalculatedPricing.fromJson(
        json,
      ), // chat and call are at root
    );
  }
}
