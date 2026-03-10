import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String mobile;
  final String otp;
  final String status;
  final String date;

  UserModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.otp,
    required this.status,
    required this.date,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      otp: json['otp'] ?? '',
      status: json['status'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'otp': otp,
      'status': status,
      'date': date,
    };
  }
  // Added this method to convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Added this static method to create from JSON string
  static UserModel? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    return UserModel.fromJson(jsonDecode(jsonString));
  }
}
