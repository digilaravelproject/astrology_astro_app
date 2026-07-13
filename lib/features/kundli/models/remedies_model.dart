class RemediesModel {
  final bool success;
  final RemediesData? data;

  RemediesModel({required this.success, this.data});

  factory RemediesModel.fromJson(Map<String, dynamic> json) {
    return RemediesModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? RemediesData.fromJson(json['data']) : null,
    );
  }
}

class RemediesData {
  final List<CrystalRemedy>? crystals;
  final String? system;

  RemediesData({this.crystals, this.system});

  factory RemediesData.fromJson(Map<String, dynamic> json) {
    return RemediesData(
      crystals: json['crystals'] != null
          ? (json['crystals'] as List).map((i) => CrystalRemedy.fromJson(i)).toList()
          : null,
      system: json['system'],
    );
  }
}

class CrystalRemedy {
  final String? planet;
  final String? planetStrength;
  final Charity? charity;
  final Fasting? fasting;
  final Gemstone? gemstone;
  final Mantra? mantra;

  CrystalRemedy({
    this.planet,
    this.planetStrength,
    this.charity,
    this.fasting,
    this.gemstone,
    this.mantra,
  });

  factory CrystalRemedy.fromJson(Map<String, dynamic> json) {
    return CrystalRemedy(
      planet: json['planet'],
      planetStrength: json['planetStrength'],
      charity: json['charity'] != null ? Charity.fromJson(json['charity']) : null,
      fasting: json['fasting'] != null ? Fasting.fromJson(json['fasting']) : null,
      gemstone: json['gemstone'] != null ? Gemstone.fromJson(json['gemstone']) : null,
      mantra: json['mantra'] != null ? Mantra.fromJson(json['mantra']) : null,
    );
  }
}

class Charity {
  final String? bestDay;
  final String? donateTo;
  final List<String>? items;
  final String? planet;

  Charity({this.bestDay, this.donateTo, this.items, this.planet});

  factory Charity.fromJson(Map<String, dynamic> json) {
    return Charity(
      bestDay: json['bestDay'],
      donateTo: json['donateTo'],
      items: json['items'] != null ? List<String>.from(json['items']) : null,
      planet: json['planet'],
    );
  }
}

class Fasting {
  final String? breakFastWith;
  final String? day;
  final String? deity;
  final String? duration;
  final String? fastingType;
  final String? planet;

  Fasting({
    this.breakFastWith,
    this.day,
    this.deity,
    this.duration,
    this.fastingType,
    this.planet,
  });

  factory Fasting.fromJson(Map<String, dynamic> json) {
    return Fasting(
      breakFastWith: json['breakFastWith'],
      day: json['day'],
      deity: json['deity'],
      duration: json['duration'],
      fastingType: json['fastingType'],
      planet: json['planet'],
    );
  }
}

class Gemstone {
  final String? alternativeGemstone;
  final String? caution;
  final String? dayToWear;
  final String? finger;
  final String? gemstone;
  final String? mantraForEnergizing;
  final String? metal;
  final String? planet;
  final String? planetStrength;
  final String? weight;

  Gemstone({
    this.alternativeGemstone,
    this.caution,
    this.dayToWear,
    this.finger,
    this.gemstone,
    this.mantraForEnergizing,
    this.metal,
    this.planet,
    this.planetStrength,
    this.weight,
  });

  factory Gemstone.fromJson(Map<String, dynamic> json) {
    return Gemstone(
      alternativeGemstone: json['alternativeGemstone'],
      caution: json['caution'],
      dayToWear: json['dayToWear'],
      finger: json['finger'],
      gemstone: json['gemstone'],
      mantraForEnergizing: json['mantraForEnergizing'],
      metal: json['metal'],
      planet: json['planet'],
      planetStrength: json['planetStrength'],
      weight: json['weight'],
    );
  }
}

class Mantra {
  final String? beejMantra;
  final String? bestTime;
  final String? deity;
  final String? direction;
  final int? japaCount;
  final String? mantra;
  final String? planet;

  Mantra({
    this.beejMantra,
    this.bestTime,
    this.deity,
    this.direction,
    this.japaCount,
    this.mantra,
    this.planet,
  });

  factory Mantra.fromJson(Map<String, dynamic> json) {
    return Mantra(
      beejMantra: json['beejMantra'],
      bestTime: json['bestTime'],
      deity: json['deity'],
      direction: json['direction'],
      japaCount: json['japaCount'],
      mantra: json['mantra'],
      planet: json['planet'],
    );
  }
}
