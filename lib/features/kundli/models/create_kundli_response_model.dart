class CreateKundliResponseModel {
  final String status;
  final String message;
  final KundliData data;

  CreateKundliResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CreateKundliResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateKundliResponseModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: KundliData.fromJson(json['data'] ?? {}),
    );
  }
}

class KundliData {
  final int id;
  final String name;
  final String gender;
  final String birthDate;
  final String birthTime;
  final String latitude;
  final String longitude;
  final String datetime;
  final String createdAt;
  final String updatedAt;

  KundliData({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.birthTime,
    required this.latitude,
    required this.longitude,
    required this.datetime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KundliData.fromJson(Map<String, dynamic> json) {
    return KundliData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      birthDate: json['birth_date'] ?? '',
      birthTime: json['birth_time'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      datetime: json['datetime'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
