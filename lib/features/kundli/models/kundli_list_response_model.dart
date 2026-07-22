class KundliListResponseModel {
  final int currentPage;
  final List<KundliItem> data;
  final int total;
  final int perPage;
  final String? firstPageUrl;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String? prevPageUrl;

  KundliListResponseModel({
    required this.currentPage,
    required this.data,
    required this.total,
    required this.perPage,
    this.firstPageUrl,
    this.lastPageUrl,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory KundliListResponseModel.fromJson(Map<String, dynamic> json) {
    print('[KUNDLI_APP] [DEBUG] Model: Parsing response JSON');
    print('[KUNDLI_APP] [DEBUG] Model: current_page = ${json['current_page']}');
    print('[KUNDLI_APP] [DEBUG] Model: data type = ${json['data'].runtimeType}');
    print('[KUNDLI_APP] [DEBUG] Model: data length = ${(json['data'] as List?)?.length}');
    
    return KundliListResponseModel(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List?)
              ?.map((item) => KundliItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 15,
      firstPageUrl: json['first_page_url'],
      lastPageUrl: json['last_page_url'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }
}

class KundliItem {
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

  KundliItem({
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

  factory KundliItem.fromJson(Map<String, dynamic> json) {
    print('[KUNDLI_APP] [DEBUG] KundliItem: Parsing item - name: ${json['name']}, gender: ${json['gender']}');
    return KundliItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      birthDate: json['birth_date'] ?? '',
      birthTime: json['birth_time'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      datetime: json['datetime'] ?? '',
      place: json['birth_place'] ?? json['place'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // Helper method to format date for display
  String get formattedDate {
    try {
      final date = DateTime.parse(birthDate);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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

  // Helper to get place display text
  String get displayPlace => place.isNotEmpty ? place : 'Unknown';
}
