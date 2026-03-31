class SleepHoursModel {
  final String sleepStartTime;
  final String sleepEndTime;
  final int sleepDurationMinutes;

  SleepHoursModel({
    required this.sleepStartTime,
    required this.sleepEndTime,
    required this.sleepDurationMinutes,
  });

  factory SleepHoursModel.fromJson(Map<String, dynamic> json) {
    return SleepHoursModel(
      sleepStartTime: json['sleep_start_time'] ?? '',
      sleepEndTime: json['sleep_end_time'] ?? '',
      sleepDurationMinutes: json['sleep_duration_minutes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sleep_start_time': sleepStartTime,
      'sleep_end_time': sleepEndTime,
      'sleep_duration_minutes': sleepDurationMinutes,
    };
  }
}