class PanchangModel {
  final bool success;
  final PanchangData data;
  final BillingInfo billing;
  final MetaInfo meta;

  PanchangModel({
    required this.success,
    required this.data,
    required this.billing,
    required this.meta,
  });

  factory PanchangModel.fromJson(Map<String, dynamic> json) {
    final rootData = json.containsKey('data') ? json['data'] : json;
    return PanchangModel(
      success: json['success'] ?? true,
      data: PanchangData.fromJson(rootData as Map<String, dynamic>),
      billing: BillingInfo.fromJson(json['billing'] ?? {}),
      meta: MetaInfo.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      'billing': billing.toJson(),
      'meta': meta.toJson(),
    };
  }
}

class PanchangData {
  final String date;
  final String datetime;
  final String location;
  final String timezone;
  final Coordinates coordinates;
  final Tithi tithi;
  final Nakshatra nakshatra;
  final Yoga yoga;
  final Karana karana;
  final Vara vara;
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;
  final TimeRange rahukaal;
  final TimeRange yamagandam;
  final TimeRange gulika;
  final TimeRange abhijitMuhurta;
  final List<AuspiciousTiming> auspiciousTimings;
  final List<InauspiciousPeriod> inauspiciousPeriods;
  final GuidanceInfo guidance;
  final Masa? masa;
  final Ritu? ritu;
  final DishaShool? dishaShool;

  PanchangData({
    required this.date,
    required this.datetime,
    required this.location,
    required this.timezone,
    required this.coordinates,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.vara,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.rahukaal,
    required this.yamagandam,
    required this.gulika,
    required this.abhijitMuhurta,
    required this.auspiciousTimings,
    required this.inauspiciousPeriods,
    required this.guidance,
    this.masa,
    this.ritu,
    this.dishaShool,
  });

  factory PanchangData.fromJson(Map<String, dynamic> json) {
    String parsedLocation = json['location'] ?? '';
    if (parsedLocation.isEmpty && json['coordinates'] != null) {
      final lat = json['coordinates']['latitude'];
      final lon = json['coordinates']['longitude'];
      parsedLocation = 'Lat: $lat, Lon: $lon';
    } else if (parsedLocation.isEmpty && json['timezone'] != null) {
      parsedLocation = 'Timezone: ${json['timezone']}';
    }

    return PanchangData(
      date: json['date'] ?? json['datetime'] ?? '',
      datetime: json['datetime'] ?? '',
      location: parsedLocation,
      timezone: json['timezone'] ?? '',
      coordinates: Coordinates.fromJson(json['coordinates'] ?? {}),
      tithi: Tithi.fromJson(json['tithi'] is Map ? {...Map<String, dynamic>.from(json['tithi']), if (json['paksha'] != null) 'paksha': json['paksha']} : {'name': json['tithi']?.toString(), if (json['paksha'] != null) 'paksha': json['paksha']}),
      nakshatra: Nakshatra.fromJson(json['nakshatra'] is Map ? Map<String, dynamic>.from(json['nakshatra']) : {'name': json['nakshatra']?.toString()}),
      yoga: Yoga.fromJson(json['yog'] is Map ? Map<String, dynamic>.from(json['yog']) : (json['yoga'] is Map ? Map<String, dynamic>.from(json['yoga']) : {'name': json['yog']?.toString() ?? json['yoga']?.toString()})),
      karana: Karana.fromJson(json['karan'] is Map ? Map<String, dynamic>.from(json['karan']) : (json['karana'] is Map ? Map<String, dynamic>.from(json['karana']) : {'name': json['karan']?.toString() ?? json['karana']?.toString()})),
      vara: Vara.fromJson(json['vara'] is Map ? Map<String, dynamic>.from(json['vara']) : {'name': json['day']?.toString() ?? ''}),
      sunrise: json['sunrise'] ?? json['vedic_sunrise'] ?? '',
      sunset: json['sunset'] ?? json['vedic_sunset'] ?? '',
      moonrise: json['moonrise'] ?? '',
      moonset: json['moonset'] ?? '',
      rahukaal: TimeRange.fromJson(json['rahukaal'] is Map ? Map<String, dynamic>.from(json['rahukaal']) : {}),
      yamagandam: TimeRange.fromJson(json['yamghant_kaal'] is Map ? Map<String, dynamic>.from(json['yamghant_kaal']) : (json['yamagandam'] is Map ? Map<String, dynamic>.from(json['yamagandam']) : {})),
      gulika: TimeRange.fromJson(json['guliKaal'] is Map ? Map<String, dynamic>.from(json['guliKaal']) : (json['gulika'] is Map ? Map<String, dynamic>.from(json['gulika']) : {})),
      abhijitMuhurta: TimeRange.fromJson(json['abhijit_muhurta'] is Map ? Map<String, dynamic>.from(json['abhijit_muhurta']) : {}),
      auspiciousTimings: (json['auspicious_timings'] as List<dynamic>?)
              ?.map((e) => AuspiciousTiming.fromJson(e))
              .toList() ??
          [],
      inauspiciousPeriods: (json['inauspicious_periods'] as List<dynamic>?)
              ?.map((e) => InauspiciousPeriod.fromJson(e))
              .toList() ??
          [],
      guidance: GuidanceInfo.fromJson(json['guidance'] is Map ? Map<String, dynamic>.from(json['guidance']) : {}),
      masa: json['masa'] is Map
          ? Masa.fromJson(Map<String, dynamic>.from(json['masa']))
          : (json['hindu_maah'] is Map
              ? Masa.fromJson({'name': json['hindu_maah']['purnimanta']?.toString() ?? ''})
              : null),
      ritu: json['ritu'] is Map
          ? Ritu.fromJson(Map<String, dynamic>.from(json['ritu']))
          : (json['ritu'] != null
              ? Ritu.fromJson({'name': json['ritu']?.toString() ?? ''})
              : null),
      dishaShool: json['disha_shool'] is Map
          ? DishaShool.fromJson(Map<String, dynamic>.from(json['disha_shool']))
          : (json['disha_shool'] != null
              ? DishaShool.fromJson({'direction': json['disha_shool']?.toString() ?? ''})
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'datetime': datetime,
      'location': location,
      'timezone': timezone,
      'coordinates': coordinates.toJson(),
      'tithi': tithi.toJson(),
      'nakshatra': nakshatra.toJson(),
      'yoga': yoga.toJson(),
      'karana': karana.toJson(),
      'vara': vara.toJson(),
      'sunrise': sunrise,
      'sunset': sunset,
      'moonrise': moonrise,
      'moonset': moonset,
      'rahukaal': rahukaal.toJson(),
      'yamagandam': yamagandam.toJson(),
      'gulika': gulika.toJson(),
      'abhijit_muhurta': abhijitMuhurta.toJson(),
      'auspicious_timings': auspiciousTimings.map((e) => e.toJson()).toList(),
      'inauspicious_periods': inauspiciousPeriods.map((e) => e.toJson()).toList(),
      'guidance': guidance.toJson(),
      'masa': masa?.toJson(),
      'ritu': ritu?.toJson(),
      'disha_shool': dishaShool?.toJson(),
    };
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

class Paksha {
  final int id;
  final String name;

  Paksha({required this.id, required this.name});

  factory Paksha.fromJson(dynamic json) {
    if (json is String) {
      return Paksha(id: 0, name: json);
    }
    if (json is Map) {
      return Paksha(
        id: json['id'] ?? 0,
        name: json['name'] ?? json['paksha_name'] ?? '',
      );
    }
    return Paksha(id: 0, name: '');
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class CommonInterpretation {
  final String meaning;
  final String energy;
  final List<String> bestFor;
  final List<String> avoid;
  final String tip;

  CommonInterpretation({
    required this.meaning,
    required this.energy,
    required this.bestFor,
    required this.avoid,
    required this.tip,
  });

  factory CommonInterpretation.fromJson(Map<String, dynamic> json) {
    return CommonInterpretation(
      meaning: json['meaning'] ?? '',
      energy: json['energy'] ?? '',
      bestFor: List<String>.from(json['bestFor'] ?? json['best_for'] ?? []),
      avoid: List<String>.from(json['avoid'] ?? []),
      tip: json['tip'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'meaning': meaning,
        'energy': energy,
        'bestFor': bestFor,
        'avoid': avoid,
        'tip': tip,
      };
}

class Tithi {
  final int id;
  final String name;
  final String endTime;
  final Paksha paksha;
  final String deity; // Maps to deity or lord
  final double completionPercentage;
  final bool isKrishna;
  final CommonInterpretation interpretation;

  Tithi({
    required this.id,
    required this.name,
    required this.endTime,
    required this.paksha,
    required this.deity,
    required this.completionPercentage,
    required this.isKrishna,
    required this.interpretation,
  });

  factory Tithi.fromJson(Map<String, dynamic> json) {
    final details = json['details'] is Map ? json['details'] as Map<String, dynamic> : json;
    String formattedEndTime = '';
    if (json['end_time'] != null) {
      if (json['end_time'] is Map) {
        final h = json['end_time']['hour'] ?? 0;
        final m = json['end_time']['minute'] ?? 0;
        formattedEndTime = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
      } else {
        formattedEndTime = json['end_time'].toString();
      }
    }

    return Tithi(
      id: details['tithi_number'] ?? json['id'] ?? 0,
      name: details['tithi_name'] ?? json['name'] ?? '',
      endTime: formattedEndTime,
      paksha: Paksha.fromJson(json['paksha'] ?? {}),
      deity: details['deity'] ?? json['deity'] ?? json['lord'] ?? '',
      completionPercentage: (json['completionPercentage'] ?? json['completion_percentage'] ?? 0.0).toDouble(),
      isKrishna: json['isKrishna'] ?? json['is_krishna'] ?? false,
      interpretation: CommonInterpretation.fromJson(details['summary'] != null ? {'meaning': details['summary']} : (json['interpretation'] ?? {})),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'end_time': endTime,
      'paksha': paksha.toJson(),
      'deity': deity,
      'completionPercentage': completionPercentage,
      'isKrishna': isKrishna,
      'interpretation': interpretation.toJson(),
    };
  }
}

class Nakshatra {
  final int id;
  final String name;
  final String endTime;
  final String lord;
  final String deity;
  final String gana;
  final int pada;
  final double completionPercentage;
  final double startDegree;
  final double endDegree;
  final CommonInterpretation interpretation;

  Nakshatra({
    required this.id,
    required this.name,
    required this.endTime,
    required this.lord,
    required this.deity,
    required this.gana,
    required this.pada,
    required this.completionPercentage,
    required this.startDegree,
    required this.endDegree,
    required this.interpretation,
  });

  factory Nakshatra.fromJson(Map<String, dynamic> json) {
    final details = json['details'] is Map ? json['details'] as Map<String, dynamic> : json;
    String formattedEndTime = '';
    if (json['end_time'] != null) {
      if (json['end_time'] is Map) {
        final h = json['end_time']['hour'] ?? 0;
        final m = json['end_time']['minute'] ?? 0;
        formattedEndTime = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
      } else {
        formattedEndTime = json['end_time'].toString();
      }
    }

    return Nakshatra(
      id: details['nak_number'] ?? json['id'] ?? 0,
      name: details['nak_name'] ?? json['name'] ?? '',
      endTime: formattedEndTime,
      lord: details['ruler'] ?? json['lord'] ?? '',
      deity: details['deity'] ?? json['deity'] ?? json['lord'] ?? '',
      gana: details['gana'] ?? json['gana'] ?? '',
      pada: details['pada'] ?? json['pada'] ?? 0,
      completionPercentage: (json['completionPercentage'] ?? json['completion_percentage'] ?? 0.0).toDouble(),
      startDegree: (json['startDegree'] ?? json['start_degree'] ?? 0.0).toDouble(),
      endDegree: (json['endDegree'] ?? json['end_degree'] ?? 0.0).toDouble(),
      interpretation: CommonInterpretation.fromJson(details['summary'] != null ? {'meaning': details['summary']} : (json['interpretation'] ?? {})),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'end_time': endTime,
      'lord': lord,
      'deity': deity,
      'gana': gana,
      'pada': pada,
      'completionPercentage': completionPercentage,
      'startDegree': startDegree,
      'endDegree': endDegree,
      'interpretation': interpretation.toJson(),
    };
  }
}

class YogaInterpretation {
  final String meaning;
  final String effect;
  final String guidance;

  YogaInterpretation({
    required this.meaning,
    required this.effect,
    required this.guidance,
  });

  factory YogaInterpretation.fromJson(Map<String, dynamic> json) {
    return YogaInterpretation(
      meaning: json['meaning'] ?? '',
      effect: json['effect'] ?? '',
      guidance: json['guidance'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'meaning': meaning,
        'effect': effect,
        'guidance': guidance,
      };
}

class Yoga {
  final int id;
  final String name;
  final String endTime;
  final String quality;
  final double completionPercentage;
  final YogaInterpretation interpretation;

  Yoga({
    required this.id,
    required this.name,
    required this.endTime,
    required this.quality,
    required this.completionPercentage,
    required this.interpretation,
  });

  factory Yoga.fromJson(Map<String, dynamic> json) {
    final details = json['details'] is Map ? json['details'] as Map<String, dynamic> : json;
    String formattedEndTime = '';
    if (json['end_time'] != null) {
      if (json['end_time'] is Map) {
        final h = json['end_time']['hour'] ?? 0;
        final m = json['end_time']['minute'] ?? 0;
        formattedEndTime = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
      } else {
        formattedEndTime = json['end_time'].toString();
      }
    }

    return Yoga(
      id: details['yog_number'] ?? json['id'] ?? 0,
      name: details['yog_name'] ?? json['name'] ?? '',
      endTime: formattedEndTime,
      quality: details['special'] ?? json['quality'] ?? '',
      completionPercentage: (json['completionPercentage'] ?? json['completion_percentage'] ?? 0.0).toDouble(),
      interpretation: YogaInterpretation.fromJson(details['meaning'] != null ? {'meaning': details['meaning'], 'guidance': details['special'] ?? ''} : (json['interpretation'] ?? {})),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'end_time': endTime,
      'quality': quality,
      'completionPercentage': completionPercentage,
      'interpretation': interpretation.toJson(),
    };
  }
}

class KaranaInterpretation {
  final String meaning;
  final String nature;
  final List<String> bestFor;
  final List<String> avoid;
  final String tip;

  KaranaInterpretation({
    required this.meaning,
    required this.nature,
    required this.bestFor,
    required this.avoid,
    required this.tip,
  });

  factory KaranaInterpretation.fromJson(Map<String, dynamic> json) {
    return KaranaInterpretation(
      meaning: json['meaning'] ?? '',
      nature: json['nature'] ?? '',
      bestFor: List<String>.from(json['bestFor'] ?? json['best_for'] ?? []),
      avoid: List<String>.from(json['avoid'] ?? []),
      tip: json['tip'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'meaning': meaning,
        'energy': nature,
        'bestFor': bestFor,
        'avoid': avoid,
        'tip': tip,
      };
}

class Karana {
  final int id;
  final String name;
  final String endTime;
  final String type;
  final double completionPercentage;
  final KaranaInterpretation interpretation;

  Karana({
    required this.id,
    required this.name,
    required this.endTime,
    required this.type,
    required this.completionPercentage,
    required this.interpretation,
  });

  factory Karana.fromJson(Map<String, dynamic> json) {
    final details = json['details'] is Map ? json['details'] as Map<String, dynamic> : json;
    String formattedEndTime = '';
    if (json['end_time'] != null) {
      if (json['end_time'] is Map) {
        final h = json['end_time']['hour'] ?? 0;
        final m = json['end_time']['minute'] ?? 0;
        formattedEndTime = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
      } else {
        formattedEndTime = json['end_time'].toString();
      }
    }

    return Karana(
      id: details['karan_number'] ?? json['id'] ?? 0,
      name: details['karan_name'] ?? json['name'] ?? '',
      endTime: formattedEndTime,
      type: details['deity'] ?? json['type'] ?? '',
      completionPercentage: (json['completionPercentage'] ?? json['completion_percentage'] ?? 0.0).toDouble(),
      interpretation: KaranaInterpretation.fromJson(details['special'] != null ? {'meaning': details['special']} : (json['interpretation'] ?? {})),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'end_time': endTime,
      'type': type,
      'completionPercentage': completionPercentage,
      'interpretation': interpretation.toJson(),
    };
  }
}

class VaraInterpretation {
  final String meaning;
  final String energy;
  final List<String> bestFor;
  final List<String> avoid;
  final String luckyColor;
  final String gemstone;
  final String tip;

  VaraInterpretation({
    required this.meaning,
    required this.energy,
    required this.bestFor,
    required this.avoid,
    required this.luckyColor,
    required this.gemstone,
    required this.tip,
  });

  factory VaraInterpretation.fromJson(Map<String, dynamic> json) {
    return VaraInterpretation(
      meaning: json['meaning'] ?? '',
      energy: json['energy'] ?? '',
      bestFor: List<String>.from(json['bestFor'] ?? json['best_for'] ?? []),
      avoid: List<String>.from(json['avoid'] ?? []),
      luckyColor: json['luckyColor'] ?? json['lucky_color'] ?? '',
      gemstone: json['gemstone'] ?? '',
      tip: json['tip'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'meaning': meaning,
        'energy': energy,
        'bestFor': bestFor,
        'avoid': avoid,
        'luckyColor': luckyColor,
        'gemstone': gemstone,
        'tip': tip,
      };
}

class Vara {
  final int id;
  final String name;
  final String englishName;
  final String lord;
  final VaraInterpretation interpretation;

  Vara({
    required this.id,
    required this.name,
    required this.englishName,
    required this.lord,
    required this.interpretation,
  });

  factory Vara.fromJson(Map<String, dynamic> json) {
    return Vara(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? json['english_name'] ?? '',
      lord: json['lord'] ?? '',
      interpretation: VaraInterpretation.fromJson(json['interpretation'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'englishName': englishName,
      'lord': lord,
      'interpretation': interpretation.toJson(),
    };
  }
}

class GuidanceInfo {
  final String summary;
  final String overallAuspiciousness;
  final List<String> bestActivities;
  final List<String> activitiesToAvoid;
  final List<String> tips;

  GuidanceInfo({
    required this.summary,
    required this.overallAuspiciousness,
    required this.bestActivities,
    required this.activitiesToAvoid,
    required this.tips,
  });

  factory GuidanceInfo.fromJson(Map<String, dynamic> json) {
    return GuidanceInfo(
      summary: json['summary'] ?? '',
      overallAuspiciousness: json['overallAuspiciousness'] ?? json['overall_auspiciousness'] ?? '',
      bestActivities: List<String>.from(json['bestActivities'] ?? json['best_activities'] ?? []),
      activitiesToAvoid: List<String>.from(json['activitiesToAvoid'] ?? json['activities_to_avoid'] ?? []),
      tips: List<String>.from(json['tips'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'overallAuspiciousness': overallAuspiciousness,
        'bestActivities': bestActivities,
        'activitiesToAvoid': activitiesToAvoid,
        'tips': tips,
      };
}

class TimeRange {
  final String start;
  final String end;

  TimeRange({
    required this.start,
    required this.end,
  });

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }
}

class AuspiciousTiming {
  final String name;
  final String start;
  final String end;

  AuspiciousTiming({
    required this.name,
    required this.start,
    required this.end,
  });

  factory AuspiciousTiming.fromJson(Map<String, dynamic> json) {
    return AuspiciousTiming(
      name: json['name'] ?? '',
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'start': start,
      'end': end,
    };
  }
}

class InauspiciousPeriod {
  final String name;
  final String start;
  final String end;

  InauspiciousPeriod({
    required this.name,
    required this.start,
    required this.end,
  });

  factory InauspiciousPeriod.fromJson(Map<String, dynamic> json) {
    return InauspiciousPeriod(
      name: json['name'] ?? '',
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'start': start,
      'end': end,
    };
  }
}

class BillingInfo {
  final double charged;
  final String currency;
  final double balanceBefore;
  final double balanceAfter;
  final String endpoint;
  final String category;

  BillingInfo({
    required this.charged,
    required this.currency,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.endpoint,
    required this.category,
  });

  factory BillingInfo.fromJson(Map<String, dynamic> json) {
    return BillingInfo(
      charged: (json['charged'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      balanceBefore: (json['balanceBefore'] ?? 0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0).toDouble(),
      endpoint: json['endpoint'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'charged': charged,
      'currency': currency,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'endpoint': endpoint,
      'category': category,
    };
  }
}

class MetaInfo {
  final String engine;
  final String version;

  MetaInfo({
    required this.engine,
    required this.version,
  });

  factory MetaInfo.fromJson(Map<String, dynamic> json) {
    return MetaInfo(
      engine: json['engine'] ?? '',
      version: json['version'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'engine': engine,
      'version': version,
    };
  }
}

class MasaInterpretation {
  final String significance;
  final List<String> festivals;

  MasaInterpretation({required this.significance, required this.festivals});

  factory MasaInterpretation.fromJson(Map<String, dynamic> json) {
    return MasaInterpretation(
      significance: json['significance'] ?? '',
      festivals: List<String>.from(json['festivals'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'significance': significance,
        'festivals': festivals,
      };
}

class Masa {
  final int id;
  final String name;
  final String nameHindi;
  final String englishEquivalent;
  final String sunSign;
  final String sunSignHindi;
  final String deityAssociation;
  final MasaInterpretation interpretation;

  Masa({
    required this.id,
    required this.name,
    required this.nameHindi,
    required this.englishEquivalent,
    required this.sunSign,
    required this.sunSignHindi,
    required this.deityAssociation,
    required this.interpretation,
  });

  factory Masa.fromJson(Map<String, dynamic> json) {
    return Masa(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameHindi: json['nameHindi'] ?? json['name_hindi'] ?? '',
      englishEquivalent: json['englishEquivalent'] ?? json['english_equivalent'] ?? '',
      sunSign: json['sunSign'] ?? json['sun_sign'] ?? '',
      sunSignHindi: json['sunSignHindi'] ?? json['sun_sign_hindi'] ?? '',
      deityAssociation: json['deityAssociation'] ?? json['deity_association'] ?? '',
      interpretation: MasaInterpretation.fromJson(json['interpretation'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameHindi': nameHindi,
        'englishEquivalent': englishEquivalent,
        'sunSign': sunSign,
        'sunSignHindi': sunSignHindi,
        'deityAssociation': deityAssociation,
        'interpretation': interpretation.toJson(),
      };
}

class Ritu {
  final int id;
  final String name;
  final String nameHindi;
  final String englishName;
  final List<String> months;
  final String description;
  final List<String> characteristics;

  Ritu({
    required this.id,
    required this.name,
    required this.nameHindi,
    required this.englishName,
    required this.months,
    required this.description,
    required this.characteristics,
  });

  factory Ritu.fromJson(Map<String, dynamic> json) {
    return Ritu(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameHindi: json['nameHindi'] ?? json['name_hindi'] ?? '',
      englishName: json['englishName'] ?? json['english_name'] ?? '',
      months: List<String>.from(json['months'] ?? []),
      description: json['description'] ?? '',
      characteristics: List<String>.from(json['characteristics'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameHindi': nameHindi,
        'englishName': englishName,
        'months': months,
        'description': description,
        'characteristics': characteristics,
      };
}

class DishaShool {
  final String direction;
  final String directionHindi;
  final List<String> safeDirections;
  final List<String> remedies;
  final String description;

  DishaShool({
    required this.direction,
    required this.directionHindi,
    required this.safeDirections,
    required this.remedies,
    required this.description,
  });

  factory DishaShool.fromJson(Map<String, dynamic> json) {
    return DishaShool(
      direction: json['direction'] ?? '',
      directionHindi: json['directionHindi'] ?? json['direction_hindi'] ?? '',
      safeDirections: List<String>.from(json['safeDirections'] ?? json['safe_directions'] ?? []),
      remedies: List<String>.from(json['remedies'] ?? []),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'direction': direction,
        'directionHindi': directionHindi,
        'safeDirections': safeDirections,
        'remedies': remedies,
        'description': description,
      };
}

