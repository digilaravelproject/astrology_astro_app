class YoginiDashaModel {
  final bool success;
  final YoginiDashaData? data;

  YoginiDashaModel({required this.success, this.data});

  factory YoginiDashaModel.fromJson(Map<String, dynamic> json) {
    return YoginiDashaModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? YoginiDashaData.fromJson(json['data']) : null,
    );
  }
}

class YoginiDashaData {
  final List<YoginiDashaItem>? mahadashas;

  YoginiDashaData({this.mahadashas});

  factory YoginiDashaData.fromJson(Map<String, dynamic> json) {
    return YoginiDashaData(
      mahadashas: json['mahadashas'] != null
          ? (json['mahadashas'] as List).map((i) => YoginiDashaItem.fromJson(i)).toList()
          : null,
    );
  }
}

class YoginiDashaItem {
  final String? yogini;
  final String? startDate;
  final String? endDate;

  YoginiDashaItem({
    this.yogini,
    this.startDate,
    this.endDate,
  });

  factory YoginiDashaItem.fromJson(Map<String, dynamic> json) {
    return YoginiDashaItem(
      yogini: json['yogini'],
      startDate: json['startDate'],
      endDate: json['endDate'],
    );
  }
}
