class PlanetPositionsModel {
  final bool success;
  final PlanetPositionsData? data;

  PlanetPositionsModel({required this.success, this.data});

  factory PlanetPositionsModel.fromJson(Map<String, dynamic> json) {
    return PlanetPositionsModel(
      success: json['success'] ?? false,
      data:
          json['data'] != null
              ? PlanetPositionsData.fromJson(json['data'])
              : null,
    );
  }
}

class PlanetPositionsData {
  final List<PlanetPosition>? planets;

  PlanetPositionsData({this.planets});

  factory PlanetPositionsData.fromJson(Map<String, dynamic> json) {
    return PlanetPositionsData(
      planets:
          json['planets'] != null
              ? (json['planets'] as List)
                  .map((i) => PlanetPosition.fromJson(i))
                  .toList()
              : null,
    );
  }
}

class PlanetPosition {
  final String? name;
  final String? sign;
  final double? normDegree;
  final Nakshatra? nakshatra;
  final int? house;
  final int? signNumber;
  final double? fullDegree;

  PlanetPosition({
    this.name,
    this.sign,
    this.normDegree,
    this.nakshatra,
    this.house,
    this.signNumber,
    this.fullDegree,
  });

  factory PlanetPosition.fromJson(Map<String, dynamic> json) {
    return PlanetPosition(
      name: json['name'],
      sign: json['sign'],
      normDegree:
          json['normDegree'] != null
              ? (json['normDegree'] as num).toDouble()
              : null,
      nakshatra:
          json['nakshatra'] != null
              ? Nakshatra.fromJson(json['nakshatra'])
              : null,
      house: json['house'],
      signNumber: json['signNumber'],
      fullDegree:
          json['fullDegree'] != null
              ? (json['fullDegree'] as num).toDouble()
              : null,
    );
  }
}

class Nakshatra {
  final String? name;

  Nakshatra({this.name});

  factory Nakshatra.fromJson(Map<String, dynamic> json) {
    return Nakshatra(name: json['name']);
  }
}
