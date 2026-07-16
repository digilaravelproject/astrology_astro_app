class DivisionalChartModel {
  final bool success;
  final DivisionalChartData? data;

  DivisionalChartModel({required this.success, this.data});

  factory DivisionalChartModel.fromJson(Map<String, dynamic> json) {
    return DivisionalChartModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? DivisionalChartData.fromJson(json['data']) : null,
    );
  }
}

class DivisionalChartData {
  final int? division;
  final List<DivisionalPosition>? positions;

  DivisionalChartData({this.division, this.positions});

  factory DivisionalChartData.fromJson(Map<String, dynamic> json) {
    return DivisionalChartData(
      division: json['division'],
      positions: json['positions'] != null 
          ? (json['positions'] as List).map((i) => DivisionalPosition.fromJson(i)).toList() 
          : null,
    );
  }
}

class DivisionalPosition {
  final int? house;
  final String? planet;
  final int? sign;
  final String? signName;

  DivisionalPosition({this.house, this.planet, this.sign, this.signName});

  factory DivisionalPosition.fromJson(Map<String, dynamic> json) {
    return DivisionalPosition(
      house: json['house'],
      planet: json['planet'],
      sign: json['sign'],
      signName: json['signName'],
    );
  }
  
  // The API returns sign as 0-indexed (0=Aries). Our KundliChartWidget uses 1-indexed signNumbers for South Indian chart.
  int get signNumber => (sign ?? 0) + 1;
}
