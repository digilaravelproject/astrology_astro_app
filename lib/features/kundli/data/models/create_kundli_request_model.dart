class CreateKundliRequestModel {
  final String name;
  final String gender;
  final String birthDate;
  final String birthTime;
  final String latitude;
  final String longitude;
  final String datetime;
  final String? place;

  CreateKundliRequestModel({
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.birthTime,
    required this.latitude,
    required this.longitude,
    required this.datetime,
    this.place,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'gender': gender,
      'birth_date': birthDate,
      'birth_time': birthTime,
      'latitude': latitude,
      'longitude': longitude,
      'datetime': datetime,
      'birth_place': place,
    };
    return map;
  }
}
