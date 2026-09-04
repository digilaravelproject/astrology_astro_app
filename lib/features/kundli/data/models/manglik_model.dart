class ManglikModel {
  final bool isPresent;
  final String manglikStatus;
  final double percentageManglikPresent;
  final double percentageAfterCancellation;
  final String manglikReport;
  final List<String> basedOnHouse;
  final List<String> basedOnAspect;
  final List<String> cancelRules;

  ManglikModel({
    required this.isPresent,
    required this.manglikStatus,
    required this.percentageManglikPresent,
    required this.percentageAfterCancellation,
    required this.manglikReport,
    required this.basedOnHouse,
    required this.basedOnAspect,
    required this.cancelRules,
  });

  factory ManglikModel.fromJson(Map<String, dynamic> json) {
    final rules =
        json['manglik_present_rule'] is Map
            ? json['manglik_present_rule'] as Map
            : {};
    final houseRules =
        (rules['based_on_house'] is List)
            ? (rules['based_on_house'] as List)
                .map((e) => e.toString())
                .toList()
            : <String>[];
    final aspectRules =
        (rules['based_on_aspect'] is List)
            ? (rules['based_on_aspect'] as List)
                .map((e) => e.toString())
                .toList()
            : <String>[];
    final cancels =
        (json['manglik_cancel_rule'] is List)
            ? (json['manglik_cancel_rule'] as List)
                .map((e) => e.toString())
                .toList()
            : <String>[];

    return ManglikModel(
      isPresent: json['is_present'] == true,
      manglikStatus: json['manglik_status']?.toString() ?? 'NO',
      percentageManglikPresent:
          (json['percentage_manglik_present'] is num)
              ? (json['percentage_manglik_present'] as num).toDouble()
              : 0.0,
      percentageAfterCancellation:
          (json['percentage_manglik_after_cancellation'] is num)
              ? (json['percentage_manglik_after_cancellation'] as num)
                  .toDouble()
              : 0.0,
      manglikReport: json['manglik_report']?.toString() ?? '',
      basedOnHouse: houseRules,
      basedOnAspect: aspectRules,
      cancelRules: cancels,
    );
  }
}
