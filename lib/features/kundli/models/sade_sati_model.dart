class SadeSatiModel {
  final bool? success;
  final SadeSatiData? data;

  SadeSatiModel({this.success, this.data});

  factory SadeSatiModel.fromJson(Map<String, dynamic> json) {
    return SadeSatiModel(
      success: json['success'],
      data: json['data'] != null ? SadeSatiData.fromJson(json['data']) : null,
    );
  }
}

class SadeSatiData {
  final String? description;
  final List<String>? effects;
  final SadeSatiGuidance? guidance;
  final String? intensity;
  final bool? isInSadeSati;
  final SadeSatiSign? moonSign;
  final String? phase;
  final String? phaseName;
  final List<dynamic>? remedies;
  final String? sadeSatiStatus;
  final String? startDate;
  final String? endDate;
  final TransitSaturn? transitSaturn;

  SadeSatiData({
    this.description,
    this.effects,
    this.guidance,
    this.intensity,
    this.isInSadeSati,
    this.moonSign,
    this.phase,
    this.phaseName,
    this.remedies,
    this.sadeSatiStatus,
    this.startDate,
    this.endDate,
    this.transitSaturn,
  });

  factory SadeSatiData.fromJson(Map<String, dynamic> json) {
    return SadeSatiData(
      description: json['description'],
      effects: json['effects'] != null ? List<String>.from(json['effects']) : null,
      guidance: json['guidance'] != null ? SadeSatiGuidance.fromJson(json['guidance']) : null,
      intensity: json['intensity'],
      isInSadeSati: json['is_in_sade_sati'],
      moonSign: json['moon_sign'] != null ? SadeSatiSign.fromJson(json['moon_sign']) : null,
      phase: json['phase'],
      phaseName: json['phase_name'],
      remedies: json['remedies'] != null ? List<dynamic>.from(json['remedies']) : null,
      sadeSatiStatus: json['sade_sati_status'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      transitSaturn: json['transit_saturn'] != null ? TransitSaturn.fromJson(json['transit_saturn']) : null,
    );
  }
}

class SadeSatiGuidance {
  final List<String>? avoid;
  final List<String>? doList;
  final String? mantra;
  final String? summary;

  SadeSatiGuidance({this.avoid, this.doList, this.mantra, this.summary});

  factory SadeSatiGuidance.fromJson(Map<String, dynamic> json) {
    return SadeSatiGuidance(
      avoid: json['avoid'] != null ? List<String>.from(json['avoid']) : null,
      doList: json['do'] != null ? List<String>.from(json['do']) : null,
      mantra: json['mantra'],
      summary: json['summary'],
    );
  }
}

class SadeSatiSign {
  final int? id;
  final String? name;

  SadeSatiSign({this.id, this.name});

  factory SadeSatiSign.fromJson(Map<String, dynamic> json) {
    return SadeSatiSign(
      id: json['id'],
      name: json['name'],
    );
  }
}

class TransitSaturn {
  final SadeSatiSign? sign;

  TransitSaturn({this.sign});

  factory TransitSaturn.fromJson(Map<String, dynamic> json) {
    return TransitSaturn(
      sign: json['sign'] != null ? SadeSatiSign.fromJson(json['sign']) : null,
    );
  }
}
