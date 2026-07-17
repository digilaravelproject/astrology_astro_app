class NavamshaModel {
  final bool success;
  final NavamshaData? data;

  NavamshaModel({required this.success, this.data});

  factory NavamshaModel.fromJson(Map<String, dynamic> json) {
    return NavamshaModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? NavamshaData.fromJson(json['data']) : null,
    );
  }
}

class NavamshaData {
  final List<HouseData>? houses;
  final List<PlanetData>? planets;

  NavamshaData({this.houses, this.planets});

  factory NavamshaData.fromJson(Map<String, dynamic> json) {
    return NavamshaData(
      houses: json['houses'] != null 
          ? (json['houses'] as List).map((i) => HouseData.fromJson(i)).toList() 
          : null,
      planets: json['planets'] != null 
          ? (json['planets'] as List).map((i) => PlanetData.fromJson(i)).toList() 
          : null,
    );
  }
}

class HouseData {
  final int? house;
  final String? sign;

  HouseData({this.house, this.sign});

  factory HouseData.fromJson(Map<String, dynamic> json) {
    return HouseData(
      house: json['house'],
      sign: json['sign'],
    );
  }
}

class PlanetData {
  final int? house;
  final int? signNumber;
  final String? name;
  final bool? isRetrograde;

  PlanetData({this.house, this.signNumber, this.name, this.isRetrograde});

  factory PlanetData.fromJson(Map<String, dynamic> json) {
    return PlanetData(
      house: json['house'],
      signNumber: json['signNumber'],
      name: json['name'],
      isRetrograde: json['isRetrograde'],
    );
  }
}
