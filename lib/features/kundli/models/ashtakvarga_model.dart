class AshtakvargaModel {
  final bool success;
  final AshtakvargaData? data;

  AshtakvargaModel({required this.success, this.data});

  factory AshtakvargaModel.fromJson(Map<String, dynamic> json) {
    return AshtakvargaModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? AshtakvargaData.fromJson(json['data']) : null,
    );
  }
}

class AshtakvargaData {
  final Map<String, BhinnashtakavargaPlanet>? bhinnashtakavarga;

  AshtakvargaData({this.bhinnashtakavarga});

  factory AshtakvargaData.fromJson(Map<String, dynamic> json) {
    Map<String, BhinnashtakavargaPlanet> bhinna = {};
    if (json['bhinnashtakavarga'] != null) {
      json['bhinnashtakavarga'].forEach((key, value) {
        bhinna[key] = BhinnashtakavargaPlanet.fromJson(value);
      });
    }
    return AshtakvargaData(
      bhinnashtakavarga: bhinna.isNotEmpty ? bhinna : null,
    );
  }
}

class BhinnashtakavargaPlanet {
  final String? planet;
  final List<StrongSign>? strongSigns;

  BhinnashtakavargaPlanet({this.planet, this.strongSigns});

  factory BhinnashtakavargaPlanet.fromJson(Map<String, dynamic> json) {
    return BhinnashtakavargaPlanet(
      planet: json['planet'],
      strongSigns: json['strongSigns'] != null
          ? (json['strongSigns'] as List).map((i) => StrongSign.fromJson(i)).toList()
          : null,
    );
  }
}

class StrongSign {
  final int? points;
  final String? sign;

  StrongSign({this.points, this.sign});

  factory StrongSign.fromJson(Map<String, dynamic> json) {
    return StrongSign(
      points: json['points'],
      sign: json['sign'],
    );
  }
}
