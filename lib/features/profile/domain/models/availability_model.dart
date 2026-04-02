class AvailabilityModel {
  final String day;
  final bool enabled;
  final List<TimeSlot> slots;

  AvailabilityModel({
    required this.day,
    required this.enabled,
    required this.slots,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      day: json['day'] ?? '',
      enabled: json['enabled'] ?? false,
      slots: (json['slots'] as List?)
              ?.map((slot) => TimeSlot.fromJson(slot))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'enabled': enabled,
      'slots': slots.map((slot) => slot.toJson()).toList(),
    };
  }
}

class TimeSlot {
  final String start;
  final String end;

  TimeSlot({
    required this.start,
    required this.end,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      start: json['start'] ?? '09:00',
      end: json['end'] ?? '17:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }
}
