class KPFullReportModel {
  final bool? success;
  final KPData? data;

  KPFullReportModel({this.success, this.data});

  factory KPFullReportModel.fromJson(Map<String, dynamic> json) {
    return KPFullReportModel(
      success: json['success'],
      data: json['data'] != null ? KPData.fromJson(json['data']) : null,
    );
  }
}

class KPData {
  final List<KPCusp>? cusps;
  final List<KPPlanet>? planets;
  final KPRulingPlanets? rulingPlanets;

  KPData({this.cusps, this.planets, this.rulingPlanets});

  factory KPData.fromJson(Map<String, dynamic> json) {
    return KPData(
      cusps: json['cusps'] != null
          ? (json['cusps'] as List).map((i) => KPCusp.fromJson(i)).toList()
          : null,
      planets: json['planets'] != null
          ? (json['planets'] as List).map((i) => KPPlanet.fromJson(i)).toList()
          : null,
      rulingPlanets: json['rulingPlanets'] != null
          ? KPRulingPlanets.fromJson(json['rulingPlanets'])
          : null,
    );
  }
}

class KPCusp {
  final int? house;
  final double? cuspLongitude;
  final String? sign;
  final int? signIndex;
  final String? signLord;
  final String? nakshatra;
  final String? nakshatraLord;
  final String? subLord;
  final String? subSubLord;

  KPCusp({
    this.house,
    this.cuspLongitude,
    this.sign,
    this.signIndex,
    this.signLord,
    this.nakshatra,
    this.nakshatraLord,
    this.subLord,
    this.subSubLord,
  });

  factory KPCusp.fromJson(Map<String, dynamic> json) {
    return KPCusp(
      house: json['house'],
      cuspLongitude: json['cuspLongitude'] != null ? (json['cuspLongitude'] as num).toDouble() : null,
      sign: json['sign'],
      signIndex: json['signIndex'],
      signLord: json['signLord'],
      nakshatra: json['nakshatra'],
      nakshatraLord: json['nakshatraLord'],
      subLord: json['subLord'],
      subSubLord: json['subSubLord'],
    );
  }
}

class KPPlanet {
  final String? planet;
  final double? degree;
  final double? longitude;
  final bool? isRetrograde;
  final String? sign;
  final int? signIndex;
  final String? signLord;
  final String? nakshatra;
  final String? nakshatraLord;
  final String? subLord;
  final String? subSubLord;

  KPPlanet({
    this.planet,
    this.degree,
    this.longitude,
    this.isRetrograde,
    this.sign,
    this.signIndex,
    this.signLord,
    this.nakshatra,
    this.nakshatraLord,
    this.subLord,
    this.subSubLord,
  });

  factory KPPlanet.fromJson(Map<String, dynamic> json) {
    return KPPlanet(
      planet: json['planet'],
      degree: json['degree'] != null ? (json['degree'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      isRetrograde: json['isRetrograde'],
      sign: json['sign'],
      signIndex: json['signIndex'],
      signLord: json['signLord'],
      nakshatra: json['nakshatra'],
      nakshatraLord: json['nakshatraLord'],
      subLord: json['subLord'],
      subSubLord: json['subSubLord'],
    );
  }
}

class KPRulingPlanets {
  final String? ascendantNakshatraLord;
  final String? ascendantSignLord;
  final String? ascendantSubLord;
  final String? dayLord;
  final String? moonNakshatraLord;
  final String? moonSignLord;
  final String? moonSubLord;

  KPRulingPlanets({
    this.ascendantNakshatraLord,
    this.ascendantSignLord,
    this.ascendantSubLord,
    this.dayLord,
    this.moonNakshatraLord,
    this.moonSignLord,
    this.moonSubLord,
  });

  factory KPRulingPlanets.fromJson(Map<String, dynamic> json) {
    return KPRulingPlanets(
      ascendantNakshatraLord: json['ascendantNakshatraLord'],
      ascendantSignLord: json['ascendantSignLord'],
      ascendantSubLord: json['ascendantSubLord'],
      dayLord: json['dayLord'],
      moonNakshatraLord: json['moonNakshatraLord'],
      moonSignLord: json['moonSignLord'],
      moonSubLord: json['moonSubLord'],
    );
  }
}
