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
  final List<MahaDashaItem>? mahaDasha;

  DashaData({this.mahaDasha});

  factory DashaData.fromJson(Map<String, dynamic> json) {
    return DashaData(
      mahaDasha: json['maha_dasha'] != null
          ? (json['maha_dasha'] as List).map((i) => MahaDashaItem.fromJson(i)).toList()
          : null,
    );
  }
}

class MahaDashaItem {
  final String? planet;
  final String? startDate;
  final String? endDate;
  final String? vedicName;

  MahaDashaItem({
    this.planet,
    this.startDate,
    this.endDate,
    this.vedicName,
  });

  factory MahaDashaItem.fromJson(Map<String, dynamic> json) {
    return MahaDashaItem(
      planet: json['planet'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      vedicName: json['vedic_name'],
    );
  }
}
