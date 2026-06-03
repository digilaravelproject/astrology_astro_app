import '../../utils/logger.dart';

class ResponseModel {
  final bool isSuccess;
  final String message;
  final dynamic body;
  final int? statusCode;
  final List<ErrorDetail>? errors;
  final String? token;

  const ResponseModel({
    required this.isSuccess,
    required this.message,
    this.body,
    this.statusCode,
    this.errors,
    this.token,
  });

  /// Factory method to create ResponseModel from JSON
  factory ResponseModel.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    // 1. Identify if it's a success
    final res = (json['res'] ?? json['status'])?.toString().toLowerCase();
    final success = res == 'success' || (json['success'] == true);

    // 2. Parse Errors
    List<ErrorDetail>? errors;
    if (json['errors'] is List) {
      errors = (json['errors'] as List)
          .map((e) => ErrorDetail.fromJson(e))
          .toList();
    } else if (json['errors'] is Map) {
      errors = [];
      (json['errors'] as Map<String, dynamic>).forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          errors!.add(ErrorDetail(code: key, message: value[0].toString()));
        } else {
          errors!.add(ErrorDetail(code: key, message: value.toString()));
        }
      });
    }

    // 3. Extract Message (Prefer String contents)
    String message = (success ? 'Success' : 'Something went wrong');
    if (json['msg'] is String) {
      message = json['msg'];
    } else if (json['message'] is String) {
      message = json['message'];
    } else if (json['data'] is String) {
      message = json['data'];
    }

    // 4. Extract Body (Prefer Map/List contents)
    dynamic body;
    if (json['data'] is Map || json['data'] is List) {
      body = json['data'];
    } else if (json['message'] is Map || json['message'] is List) {
      body = json['message'];
    } else {
      body = json['data']; // Fallback (likely String or null)
    }
    
    Logger.d('ResponseModel.fromJson parsed message: $message, isSuccess: ${success && (statusCode == null || statusCode! < 300)}');

    return ResponseModel(
      isSuccess: success && (statusCode == null || statusCode! < 300),
      message: message,
      body: body,
      statusCode: statusCode,
      errors: errors,
      token: json['token']?.toString(),
    );
  }

  /// Convert this model back to JSON
  Map<String, dynamic> toJson() => {
    'isSuccess': isSuccess,
    'message': message,
    'data': body,
    'statusCode': statusCode,
    'errors': errors?.map((e) => e.toJson()).toList(),
  };

  /// Create a copy with updated fields
  ResponseModel copyWith({
    bool? isSuccess,
    String? message,
    dynamic body,
    int? statusCode,
    List<ErrorDetail>? errors,
  }) {
    return ResponseModel(
      isSuccess: isSuccess ?? this.isSuccess,
      message: message ?? this.message,
      body: body ?? this.body,
      statusCode: statusCode ?? this.statusCode,
      errors: errors ?? this.errors,
    );
  }

  /// For easier debugging
  @override
  String toString() {
    return 'ResponseModel(isSuccess: $isSuccess, '
        'message: $message, '
        'statusCode: $statusCode, '
        'errors: $errors, '
        'body: $body)';
  }
}

/// Represents error detail (if any)
class ErrorDetail {
  final String? code;
  final String? message;

  const ErrorDetail({this.code, this.message});

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      code: json['code']?.toString(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
  };

  @override
  String toString() => 'ErrorDetail(code: $code, message: $message)';
}
