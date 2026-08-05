class KundliResponseModel {
  final bool success;
  final KundliData data;
  final BillingInfo billing;
  final MetaInfo meta;

  KundliResponseModel({
    required this.success,
    required this.data,
    required this.billing,
    required this.meta,
  });

  factory KundliResponseModel.fromJson(Map<String, dynamic> json) {
    return KundliResponseModel(
      success: json['success'] ?? false,
      data: KundliData.fromJson(json['data'] ?? {}),
      billing: BillingInfo.fromJson(json['billing'] ?? {}),
      meta: MetaInfo.fromJson(json['meta'] ?? {}),
    );
  }
}

class KundliData {
  final BirthDetails birthDetails;
  final Ascendant ascendant;
  final List<Planet> planets;
  final List<House> houses;
  final Dashas dashas;
  final List<Yoga> yogas;

  KundliData({
    required this.birthDetails,
    required this.ascendant,
    required this.planets,
    required this.houses,
    required this.dashas,
    required this.yogas,
  });

  factory KundliData.fromJson(Map<String, dynamic> json) {
    return KundliData(
      birthDetails: BirthDetails.fromJson(json['birth_details'] ?? {}),
      ascendant: Ascendant.fromJson(json['ascendant'] ?? {}),
      planets: (json['planets'] as List<dynamic>?)
              ?.map((e) => Planet.fromJson(e))
              .toList() ??
          [],
      houses: (json['houses'] as List<dynamic>?)
              ?.map((e) => House.fromJson(e))
              .toList() ??
          [],
      dashas: Dashas.fromJson(json['dashas'] ?? {}),
      yogas: (json['yogas'] as List<dynamic>?)
              ?.map((e) => Yoga.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class BirthDetails {
  final String date;
  final String time;
  final String place;
  final double latitude;
  final double longitude;
  final String timezone;
  final double timezoneOffset;

  BirthDetails({
    required this.date,
    required this.time,
    required this.place,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.timezoneOffset,
  });

  factory BirthDetails.fromJson(Map<String, dynamic> json) {
    return BirthDetails(
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      place: json['place'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      timezone: json['timezone'] ?? '',
      timezoneOffset: (json['timezone_offset'] ?? 0).toDouble(),
    );
  }
}

class Ascendant {
  final String sign;
  final double degree;
  final String nakshatra;
  final int pada;

  Ascendant({
    required this.sign,
    required this.degree,
    required this.nakshatra,
    required this.pada,
  });

  factory Ascendant.fromJson(Map<String, dynamic> json) {
    return Ascendant(
      sign: json['sign'] ?? '',
      degree: (json['degree'] ?? 0).toDouble(),
      nakshatra: json['nakshatra'] ?? '',
      pada: json['pada'] ?? 0,
    );
  }
}

class Planet {
  final String name;
  final String sign;
  final double degree;
  final int house;
  final String nakshatra;
  final bool isRetrograde;

  Planet({
    required this.name,
    required this.sign,
    required this.degree,
    required this.house,
    required this.nakshatra,
    required this.isRetrograde,
  });

  factory Planet.fromJson(Map<String, dynamic> json) {
    return Planet(
      name: json['name'] ?? '',
      sign: json['sign'] ?? '',
      degree: (json['degree'] ?? 0).toDouble(),
      house: json['house'] ?? 0,
      nakshatra: json['nakshatra'] ?? '',
      isRetrograde: json['isRetrograde'] ?? false,
    );
  }

  String get shortName {
    switch (name.toLowerCase()) {
      case 'sun':
        return 'Su';
      case 'moon':
        return 'Mo';
      case 'mars':
        return 'Ma';
      case 'mercury':
        return 'Me';
      case 'jupiter':
        return 'Ju';
      case 'venus':
        return 'Ve';
      case 'saturn':
        return 'Sa';
      case 'rahu':
        return 'Ra';
      case 'ketu':
        return 'Ke';
      default:
        return name.substring(0, 2);
    }
  }

  String get degreeFormatted {
    final deg = degree.floor();
    final min = ((degree - deg) * 60).floor();
    final sec = (((degree - deg) * 60 - min) * 60).floor();
    return "$deg° $min' $sec\"";
  }
}

class House {
  final int house;
  final String sign;
  final double degree;

  House({
    required this.house,
    required this.sign,
    required this.degree,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      house: json['house'] ?? 0,
      sign: json['sign'] ?? '',
      degree: (json['degree'] ?? 0).toDouble(),
    );
  }
}

class Dashas {
  final CurrentDasha current;
  final List<UpcomingDasha> upcoming;

  Dashas({
    required this.current,
    required this.upcoming,
  });

  factory Dashas.fromJson(Map<String, dynamic> json) {
    return Dashas(
      current: CurrentDasha.fromJson(json['current'] ?? {}),
      upcoming: (json['upcoming'] as List<dynamic>?)
              ?.map((e) => UpcomingDasha.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CurrentDasha {
  final String mahadasha;
  final String antardasha;
  final String pratyantardasha;
  final String startDate;
  final String endDate;

  CurrentDasha({
    required this.mahadasha,
    required this.antardasha,
    required this.pratyantardasha,
    required this.startDate,
    required this.endDate,
  });

  factory CurrentDasha.fromJson(Map<String, dynamic> json) {
    return CurrentDasha(
      mahadasha: json['mahadasha'] ?? '',
      antardasha: json['antardasha'] ?? '',
      pratyantardasha: json['pratyantardasha'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
    );
  }
}

class UpcomingDasha {
  final String mahadasha;
  final String antardasha;
  final String startDate;
  final String endDate;

  UpcomingDasha({
    required this.mahadasha,
    required this.antardasha,
    required this.startDate,
    required this.endDate,
  });

  factory UpcomingDasha.fromJson(Map<String, dynamic> json) {
    return UpcomingDasha(
      mahadasha: json['mahadasha'] ?? '',
      antardasha: json['antardasha'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
    );
  }
}

class Yoga {
  final String name;
  final bool present;
  final String strength;
  final String description;

  Yoga({
    required this.name,
    required this.present,
    required this.strength,
    required this.description,
  });

  factory Yoga.fromJson(Map<String, dynamic> json) {
    return Yoga(
      name: json['name'] ?? '',
      present: json['present'] ?? false,
      strength: json['strength'] ?? '',
      description: json['description'] ?? '',
    );
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
}
