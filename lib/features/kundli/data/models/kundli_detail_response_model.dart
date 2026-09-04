class KundliDetailResponseModel {
  final KundliDetailData data;

  KundliDetailResponseModel({required this.data});

  factory KundliDetailResponseModel.fromJson(Map<String, dynamic> json) {
    // The response.body already contains just the data object (ApiClient extracts json['data'])
    // So we parse it directly as KundliDetailData
    return KundliDetailResponseModel(data: KundliDetailData.fromJson(json));
  }
}

class KundliDetailData {
  final int id;
  final String name;
  final String gender;
  final String birthDate;
  final String birthTime;
  final String latitude;
  final String longitude;
  final String datetime;
  final String place;
  final String createdAt;
  final String updatedAt;

  KundliDetailData({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.birthTime,
    required this.latitude,
    required this.longitude,
    required this.datetime,
    this.place = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory KundliDetailData.fromJson(Map<String, dynamic> json) {
    return KundliDetailData(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      birthDate: json['birth_date'] as String? ?? '',
      birthTime: json['birth_time'] as String? ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      datetime: json['datetime'] as String? ?? '',
      place: json['birth_place'] as String? ?? json['place'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  String get formattedDate {
    try {
      if (datetime.isNotEmpty &&
          RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(datetime)) {
        final datePart = datetime.split(' ')[0].split('T')[0];
        final parts = datePart.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          final months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          return '$day-${months[month - 1]}-$year';
        }
      }
      final date = DateTime.parse(birthDate).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day}-${months[date.month - 1]}-${date.year}';
    } catch (e) {
      return birthDate;
    }
  }

  // Helper method to format time for display
  String get formattedTime {
    try {
      final parts = birthTime.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;
        return '$hour:$minute $period';
      }
    } catch (e) {
      return birthTime;
    }
    return birthTime;
  }

  String get displayPlace => place.isNotEmpty ? place : 'Unknown';
}
