class OfferHistoryModel {
  final int offerId;
  final String offerName;
  final num discountPercentage;
  final String status;
  final String activatedAt;
  final String? deactivatedAt;

  OfferHistoryModel({
    required this.offerId,
    required this.offerName,
    required this.discountPercentage,
    required this.status,
    required this.activatedAt,
    this.deactivatedAt,
  });

  factory OfferHistoryModel.fromJson(Map<String, dynamic> json) {
    return OfferHistoryModel(
      offerId: json['offer_id'] ?? json['id'] ?? 0,
      offerName: json['offer_name'] ?? '',
      discountPercentage: json['discount_percentage'] ?? 0,
      status: json['status'] ?? '',
      activatedAt: json['start_time'] ?? json['activated_at'] ?? '',
      deactivatedAt: json['end_time'] ?? json['deactivated_at'],
    );
  }
}
