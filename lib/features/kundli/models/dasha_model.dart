class DashaModel {
  final bool success;
  final DashaData? data;

  DashaModel({required this.success, this.data});

  factory DashaModel.fromJson(Map<String, dynamic> json) {
    return DashaModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? DashaData.fromJson(json['data']) : null,
    );
  }
}

class DashaData {
  final List<DashaItem>? mahaDasha;

  DashaData({this.mahaDasha});

  factory DashaData.fromJson(Map<String, dynamic> json) {
    return DashaData(
      mahaDasha: json['maha_dasha'] != null
          ? (json['maha_dasha'] as List).map((i) => DashaItem.fromJson(i)).toList()
          : null,
    );
  }
}

class DashaItem {
  final String? planet;
  final String? startDate;
  final String? endDate;
  final String? vedicName;
  final int? planetId;

  DashaItem({
    this.planet,
    this.startDate,
    this.endDate,
    this.vedicName,
    this.planetId,
  });

  factory DashaItem.fromJson(Map<String, dynamic> json) {
    return DashaItem(
      planet: json['planet'] ?? json['planet_name'],
      startDate: json['start'] ?? json['start_date'],
      endDate: json['end'] ?? json['end_date'],
      vedicName: json['vedic_name'],
      planetId: json['planet_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'planet': planet,
    'start_date': startDate,
    'end_date': endDate,
    'vedic_name': vedicName,
    'planet_id': planetId,
  };
}

// Alias for backwards compatibility if needed
typedef MahaDashaItem = DashaItem;
