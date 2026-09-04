import 'package:get/get.dart';
class WeeklyRankingData {
  final List<WeeklyRankingModel> topAstrologers;
  final int? myRank;
  final double? myWeeklyEarnings;

  WeeklyRankingData({
    required this.topAstrologers,
    this.myRank,
    this.myWeeklyEarnings,
  });

  factory WeeklyRankingData.fromJson(Map<String, dynamic> json) {
    return WeeklyRankingData(
      topAstrologers:
          (json['top_astrologers'] as List?)
              ?.map((e) => WeeklyRankingModel.fromJson(e))
              .toList() ??
          [],
      myRank:
          json['my_rank'] != null
              ? int.tryParse(json['my_rank'].toString())
              : null,
      myWeeklyEarnings:
          json['my_weekly_earnings'] != null
              ? double.tryParse(json['my_weekly_earnings'].toString())
              : null,
    );
  }
}

class WeeklyRankingModel {
  final int rank;
  final int astrologerId;
  final int userId;
  final String name;
  final String? profilePhoto;
  final double weeklyEarnings;

  WeeklyRankingModel({
    required this.rank,
    required this.astrologerId,
    required this.userId,
    required this.name,
    this.profilePhoto,
    required this.weeklyEarnings,
  });

  factory WeeklyRankingModel.fromJson(Map<String, dynamic> json) {
    return WeeklyRankingModel(
      rank: int.parse(json['rank'].toString()),
      astrologerId: int.parse(json['astrologer_id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      name: json['name']?.toString() ?? 'Astrologer',
      profilePhoto: json['profile_photo']?.toString(),
      weeklyEarnings:
          double.tryParse(json['weekly_earnings'].toString()) ?? 0.0,
    );
  }
}
