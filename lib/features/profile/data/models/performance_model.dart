class PerformanceModel {
  final String? badgeType;
  final ProfileHealth? profileHealth;
  final AvailabilityData? availability;
  final LoyalUserConversion? loyalUserConversion;
  final TodayProgress? todayProgress;

  PerformanceModel({
    this.badgeType,
    this.profileHealth,
    this.availability,
    this.loyalUserConversion,
    this.todayProgress,
  });

  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    return PerformanceModel(
      badgeType: json['badge_type'],
      profileHealth:
          json['profile_health'] != null
              ? ProfileHealth.fromJson(json['profile_health'])
              : null,
      availability:
          json['availability'] != null
              ? AvailabilityData.fromJson(json['availability'])
              : null,
      loyalUserConversion:
          json['loyal_user_conversion'] != null
              ? LoyalUserConversion.fromJson(json['loyal_user_conversion'])
              : null,
      todayProgress:
          json['today_progress'] != null
              ? TodayProgress.fromJson(json['today_progress'])
              : null,
    );
  }
}

class TodayProgress {
  final double? targetHours;
  final int? completedMinutes;
  final double? remainingHours;

  TodayProgress({this.targetHours, this.completedMinutes, this.remainingHours});

  factory TodayProgress.fromJson(Map<String, dynamic> json) {
    return TodayProgress(
      targetHours:
          (json['target_hours'] != null)
              ? (json['target_hours'] as num).toDouble()
              : null,
      completedMinutes: json['completed_minutes'],
      remainingHours:
          (json['remaining_hours'] != null)
              ? (json['remaining_hours'] as num).toDouble()
              : null,
    );
  }
}

class ProfileHealth {
  final String? date;
  final int? totalSessions;
  final int? missedSessions;
  final double? revenueLoss;
  final int? missedCalls;
  final int? missedChats;
  final int? loyalUsers;

  ProfileHealth({
    this.date,
    this.totalSessions,
    this.missedSessions,
    this.revenueLoss,
    this.missedCalls,
    this.missedChats,
    this.loyalUsers,
  });

  factory ProfileHealth.fromJson(Map<String, dynamic> json) {
    return ProfileHealth(
      date: json['date'],
      totalSessions: json['total_sessions'],
      missedSessions: json['missed_sessions'],
      revenueLoss:
          (json['revenue_loss'] != null)
              ? (json['revenue_loss'] as num).toDouble()
              : null,
      missedCalls: json['missed_calls'],
      missedChats: json['missed_chats'],
      loyalUsers: json['loyal_users'],
    );
  }
}

class AvailabilityData {
  final DurationMins? availableMins;
  final DurationMins? busyMins;

  AvailabilityData({this.availableMins, this.busyMins});

  factory AvailabilityData.fromJson(Map<String, dynamic> json) {
    return AvailabilityData(
      availableMins:
          json['available_mins'] != null
              ? DurationMins.fromJson(json['available_mins'])
              : null,
      busyMins:
          json['busy_mins'] != null
              ? DurationMins.fromJson(json['busy_mins'])
              : null,
    );
  }
}

class DurationMins {
  final int? today;
  final int? sevenDays;
  final int? thirtyDays;

  DurationMins({this.today, this.sevenDays, this.thirtyDays});

  factory DurationMins.fromJson(Map<String, dynamic> json) {
    return DurationMins(
      today: json['today'],
      sevenDays: json['seven_days'],
      thirtyDays: json['thirty_days'],
    );
  }
}

class LoyalUserConversion {
  final double? conversionPercentage;
  final int? totalUsers;
  final int? loyalUsers;
  final int? loyalUserLevel;

  LoyalUserConversion({
    this.conversionPercentage,
    this.totalUsers,
    this.loyalUsers,
    this.loyalUserLevel,
  });

  factory LoyalUserConversion.fromJson(Map<String, dynamic> json) {
    return LoyalUserConversion(
      conversionPercentage:
          (json['conversion_percentage'] != null)
              ? (json['conversion_percentage'] as num).toDouble()
              : null,
      totalUsers: json['total_users'],
      loyalUsers: json['loyal_users'],
      loyalUserLevel: json['loyal_user_level'],
    );
  }
}
