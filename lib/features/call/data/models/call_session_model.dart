import 'package:get/get.dart';
class CallSessionListResponse {
  final int currentPage;
  final List<CallSessionModel> data;

  CallSessionListResponse({required this.currentPage, required this.data});

  factory CallSessionListResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> targetJson =
        (json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : json;

    return CallSessionListResponse(
      currentPage:
          int.tryParse(targetJson['current_page']?.toString() ?? '') ?? 1,
      data:
          (targetJson['data'] as List<dynamic>?)
              ?.map((e) => CallSessionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CallSessionModel {
  final int id;
  final int consumerId;
  final int providerId;
  final String status;
  final int ratePerMinute;
  final int durationSeconds;
  final num totalCost;
  final String? createdAt;
  final String? startedAt;
  final String? endedAt;
  final String? answer;
  final int? chatAssistanceSessionId;
  final CallSessionUserModel? provider;
  final CallSessionUserModel? consumer;

  CallSessionModel({
    required this.id,
    required this.consumerId,
    required this.providerId,
    required this.status,
    required this.ratePerMinute,
    required this.durationSeconds,
    required this.totalCost,
    this.createdAt,
    this.startedAt,
    this.endedAt,
    this.answer,
    this.chatAssistanceSessionId,
    this.provider,
    this.consumer,
  });

  factory CallSessionModel.fromJson(Map<String, dynamic> json) {
    return CallSessionModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      consumerId: int.tryParse(json['consumer_id']?.toString() ?? '') ?? 0,
      providerId: int.tryParse(json['provider_id']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? '',
      ratePerMinute:
          num.tryParse(json['rate_per_minute']?.toString() ?? '')?.toInt() ?? 0,
      durationSeconds:
          int.tryParse(json['duration_seconds']?.toString() ?? '') ?? 0,
      totalCost: num.tryParse(json['total_cost']?.toString() ?? '') ?? 0.0,
      createdAt: json['created_at']?.toString(),
      startedAt: json['started_at']?.toString(),
      endedAt: json['ended_at']?.toString(),
      answer: json['answer']?.toString(),
      chatAssistanceSessionId: int.tryParse(
        json['chat_assistance_session_id']?.toString() ?? '',
      ),
      provider:
          json['provider'] != null
              ? CallSessionUserModel.fromJson(json['provider'])
              : null,
      consumer:
          json['consumer'] != null
              ? CallSessionUserModel.fromJson(json['consumer'])
              : null,
    );
  }
}

class CallSessionUserModel {
  final int id;
  final String name;
  final String? profilePhoto;
  final int callRatePerMinute;
  final String? gender;
  final String? dateOfBirth;
  final String? timeOfBirth;
  final String? placeOfBirth;
  final double? latitude;
  final double? longitude;
  final int? chatAssistanceSessionId;

  CallSessionUserModel({
    required this.id,
    required this.name,
    this.profilePhoto,
    required this.callRatePerMinute,
    this.gender,
    this.dateOfBirth,
    this.timeOfBirth,
    this.placeOfBirth,
    this.latitude,
    this.longitude,
    this.chatAssistanceSessionId,
  });

  factory CallSessionUserModel.fromJson(Map<String, dynamic> json) {
    int callRate = 0;
    if (json['astrologer'] != null &&
        json['astrologer']['call_rate_per_minute'] != null) {
      callRate =
          int.tryParse(json['astrologer']['call_rate_per_minute'].toString()) ??
          0;
    }
    return CallSessionUserModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      profilePhoto:
          json['astrologer']?['profile_photo']?.toString() ??
          json['profile_photo']?.toString(),
      callRatePerMinute: callRate,
      gender: json['gender']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      timeOfBirth: json['time_of_birth']?.toString(),
      placeOfBirth: json['place_of_birth']?.toString(),
      latitude: double.tryParse(
        json['latitude']?.toString() ?? json['lat']?.toString() ?? '',
      ),
      longitude: double.tryParse(
        json['longitude']?.toString() ??
            json['lng']?.toString() ??
            json['long']?.toString() ??
            '',
      ),
      chatAssistanceSessionId: int.tryParse(
        json['chat_assistance_session_id']?.toString() ?? '',
      ),
    );
  }
}
