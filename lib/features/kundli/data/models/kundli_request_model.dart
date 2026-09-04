class KundliRequestModel {
  final String birthDate;
  final String birthTime;
  final double latitude;
  final double longitude;
  final String datetime;

  KundliRequestModel({
    required this.birthDate,
    required this.birthTime,
    required this.latitude,
    required this.longitude,
    required this.datetime,
  });

  Map<String, dynamic> toJson() {
    return {
      'birth_date': birthDate,
      'birth_time': birthTime,
      'latitude': latitude,
      'longitude': longitude,
      'datetime': datetime,
    };
  }
}
