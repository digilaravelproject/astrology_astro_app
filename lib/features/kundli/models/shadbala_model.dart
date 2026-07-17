class ShadbalaModel {
  final bool success;
  final ShadbalaData? data;

  ShadbalaModel({required this.success, this.data});

  factory ShadbalaModel.fromJson(Map<String, dynamic> json) {
    return ShadbalaModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? ShadbalaData.fromJson(json['data']) : null,
    );
  }
}

class ShadbalaData {
  final String? note;
  final List<ShadbalaItem>? shadbala;
  final ShadbalaSummary? summary;

  ShadbalaData({this.note, this.shadbala, this.summary});

  factory ShadbalaData.fromJson(Map<String, dynamic> json) {
    return ShadbalaData(
      note: json['note'],
      shadbala: json['shadbala'] != null
          ? (json['shadbala'] as List).map((i) => ShadbalaItem.fromJson(i)).toList()
          : null,
      summary: json['summary'] != null ? ShadbalaSummary.fromJson(json['summary']) : null,
    );
  }
}

class ShadbalaItem {
  final String? planet;
  final double? totalStrength;
  final double? requiredMinimum;
  final double? strengthRatio;
  final int? normalizedScore;
  final bool? isStrong;
  final String? qualifier;
  final String? governs;
  final String? interpretation;
  final ShadbalaBreakdown? breakdown;

  ShadbalaItem({
    this.planet,
    this.totalStrength,
    this.requiredMinimum,
    this.strengthRatio,
    this.normalizedScore,
    this.isStrong,
    this.qualifier,
    this.governs,
    this.interpretation,
    this.breakdown,
  });

  factory ShadbalaItem.fromJson(Map<String, dynamic> json) {
    return ShadbalaItem(
      planet: json['planet'],
      totalStrength: json['total_strength'] != null ? (json['total_strength'] as num).toDouble() : null,
      requiredMinimum: json['required_minimum'] != null ? (json['required_minimum'] as num).toDouble() : null,
      strengthRatio: json['strength_ratio'] != null ? (json['strength_ratio'] as num).toDouble() : null,
      normalizedScore: json['normalized_score'],
      isStrong: json['is_strong'],
      qualifier: json['qualifier'],
      governs: json['governs'],
      interpretation: json['interpretation'],
      breakdown: json['breakdown'] != null ? ShadbalaBreakdown.fromJson(json['breakdown']) : null,
    );
  }
}

class ShadbalaBreakdown {
  final double? chestaBala;
  final double? digBala;
  final double? drikBala;
  final double? kalaBala;
  final double? naisargikaBala;
  final SthanaBala? sthanaBala;

  ShadbalaBreakdown({
    this.chestaBala,
    this.digBala,
    this.drikBala,
    this.kalaBala,
    this.naisargikaBala,
    this.sthanaBala,
  });

  factory ShadbalaBreakdown.fromJson(Map<String, dynamic> json) {
    return ShadbalaBreakdown(
      chestaBala: json['chesta_bala'] != null ? (json['chesta_bala'] as num).toDouble() : null,
      digBala: json['dig_bala'] != null ? (json['dig_bala'] as num).toDouble() : null,
      drikBala: json['drik_bala'] != null ? (json['drik_bala'] as num).toDouble() : null,
      kalaBala: json['kala_bala'] != null ? (json['kala_bala'] as num).toDouble() : null,
      naisargikaBala: json['naisargika_bala'] != null ? (json['naisargika_bala'] as num).toDouble() : null,
      sthanaBala: json['sthana_bala'] != null ? SthanaBala.fromJson(json['sthana_bala']) : null,
    );
  }
}

class SthanaBala {
  final double? drekkanaBala;
  final double? kendraBala;
  final double? saptavargajaBala;
  final double? uchchaBala;
  final double? total;

  SthanaBala({
    this.drekkanaBala,
    this.kendraBala,
    this.saptavargajaBala,
    this.uchchaBala,
    this.total,
  });

  factory SthanaBala.fromJson(Map<String, dynamic> json) {
    return SthanaBala(
      drekkanaBala: json['drekkana_bala'] != null ? (json['drekkana_bala'] as num).toDouble() : null,
      kendraBala: json['kendra_bala'] != null ? (json['kendra_bala'] as num).toDouble() : null,
      saptavargajaBala: json['saptavargaja_bala'] != null ? (json['saptavargaja_bala'] as num).toDouble() : null,
      uchchaBala: json['uchcha_bala'] != null ? (json['uchcha_bala'] as num).toDouble() : null,
      total: json['total'] != null ? (json['total'] as num).toDouble() : null,
    );
  }
}

class ShadbalaSummary {
  final int? planetsAboveRequired;
  final int? planetsBelowRequired;
  final String? strongestPlanet;
  final double? strongestScore;
  final int? totalPlanetsAnalyzed;
  final String? weakestPlanet;
  final double? weakestScore;

  ShadbalaSummary({
    this.planetsAboveRequired,
    this.planetsBelowRequired,
    this.strongestPlanet,
    this.strongestScore,
    this.totalPlanetsAnalyzed,
    this.weakestPlanet,
    this.weakestScore,
  });

  factory ShadbalaSummary.fromJson(Map<String, dynamic> json) {
    return ShadbalaSummary(
      planetsAboveRequired: json['planets_above_required'],
      planetsBelowRequired: json['planets_below_required'],
      strongestPlanet: json['strongest_planet'],
      strongestScore: json['strongest_score'] != null ? (json['strongest_score'] as num).toDouble() : null,
      totalPlanetsAnalyzed: json['total_planets_analyzed'],
      weakestPlanet: json['weakest_planet'],
      weakestScore: json['weakest_score'] != null ? (json['weakest_score'] as num).toDouble() : null,
    );
  }
}
