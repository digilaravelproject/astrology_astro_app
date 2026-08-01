class BirthChartModel {
  final bool success;
  final BirthChartData? data;

  BirthChartModel({required this.success, this.data});

  factory BirthChartModel.fromJson(Map<String, dynamic> json) {
    return BirthChartModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? BirthChartData.fromJson(json['data']) : null,
    );
  }
}

class BirthChartData {
  final List<BirthChartPlanet>? planets;

  BirthChartData({this.planets});

  factory BirthChartData.fromJson(Map<String, dynamic> json) {
    return BirthChartData(
      planets: json['planets'] != null
          ? (json['planets'] as List).map((i) => BirthChartPlanet.fromJson(i)).toList()
          : null,
    );
  }
}

class BirthChartPlanet {
  final String? name;
  final int? house;
  final int? signNumber;

  BirthChartPlanet({this.name, this.house, this.signNumber});

  factory BirthChartPlanet.fromJson(Map<String, dynamic> json) {
    return BirthChartPlanet(
      name: json['name'],
      house: json['house'],
      signNumber: json['signNumber'],
    );
  }
}
