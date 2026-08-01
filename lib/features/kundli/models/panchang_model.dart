class PanchangModel {
  final bool success;
  final PanchangData? data;

  PanchangModel({required this.success, this.data});

  factory PanchangModel.fromJson(Map<String, dynamic> json) {
    return PanchangModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? PanchangData.fromJson(json['data']) : null,
    );
  }
}

class PanchangData {
  final PanchangItem? tithi;
  final PanchangItem? karana;
  final PanchangItem? yoga;
  final PanchangItem? nakshatra;
  final PanchangItem? masa;
  final PanchangItem? ritu;
  final PanchangItem? vaara;
  final String? timezone;
  final String? sunrise;
  final String? sunset;

  PanchangData({
    this.tithi,
    this.karana,
    this.yoga,
    this.nakshatra,
    this.masa,
    this.ritu,
    this.vaara,
    this.timezone,
    this.sunrise,
    this.sunset,
  });

  factory PanchangData.fromJson(Map<String, dynamic> json) {
    return PanchangData(
      tithi: json['tithi'] != null ? PanchangItem.fromJson(json['tithi']) : null,
      karana: json['karana'] != null ? PanchangItem.fromJson(json['karana']) : null,
      yoga: json['yoga'] != null ? PanchangItem.fromJson(json['yoga']) : null,
      nakshatra: json['nakshatra'] != null ? PanchangItem.fromJson(json['nakshatra']) : null,
      masa: json['masa'] != null ? PanchangItem.fromJson(json['masa']) : null,
      ritu: json['ritu'] != null ? PanchangItem.fromJson(json['ritu']) : null,
      vaara: json['vara'] != null ? PanchangItem.fromJson(json['vara'])
           : json['vaara'] != null ? PanchangItem.fromJson(json['vaara']) : null,
      timezone: json['timezone']?.toString(),
      sunrise: json['sunrise']?.toString(),
      sunset: json['sunset']?.toString(),
    );
  }
}

class PanchangItem {
  final String? name;
  final int? id;

  PanchangItem({this.name, this.id});

  factory PanchangItem.fromJson(Map<String, dynamic> json) {
    return PanchangItem(
      name: json['name'],
      id: json['id'],
    );
  }
}
