class TransitModel {
  final bool success;
  final TransitData? data;

  TransitModel({required this.success, this.data});

  factory TransitModel.fromJson(Map<String, dynamic> json) {
    return TransitModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? TransitData.fromJson(json['data']) : null,
    );
  }
}

class TransitData {
  final String? calculatedFor;
  final List<TransitPlanetData>? planets;

  TransitData({this.calculatedFor, this.planets});

  factory TransitData.fromJson(Map<String, dynamic> json) {
    return TransitData(
      calculatedFor: json['calculatedFor'],
      planets:
          json['planets'] != null
              ? (json['planets'] as List)
                  .map((i) => TransitPlanetData.fromJson(i))
                  .toList()
              : null,
    );
  }
}

class TransitPlanetData {
  final int? houseFromLagna;
  final int? houseFromMoon;
  final int? signNumber;
  final String? name;
  final bool? isRetrograde;

  TransitPlanetData({
    this.houseFromLagna,
    this.houseFromMoon,
    this.signNumber,
    this.name,
    this.isRetrograde,
  });

  factory TransitPlanetData.fromJson(Map<String, dynamic> json) {
    return TransitPlanetData(
      houseFromLagna: json['houseFromLagna'],
      houseFromMoon: json['houseFromMoon'],
      signNumber: json['signNumber'],
      name: json['name'],
      isRetrograde: json['isRetrograde'],
    );
  }
}
