class WalletSummaryModel {
  final double totalBalance;
  final double todayEarning;
  final double weeklyEarning;
  final double monthlyEarning;
  final double threeMonthEarning;
  final int rank;

  WalletSummaryModel({
    required this.totalBalance,
    required this.todayEarning,
    required this.weeklyEarning,
    required this.monthlyEarning,
    required this.threeMonthEarning,
    required this.rank,
  });

  factory WalletSummaryModel.fromJson(Map<String, dynamic> json) {
    return WalletSummaryModel(
      totalBalance: (json['total_balance'] ?? 0).toDouble(),
      todayEarning: (json['today_earning'] ?? 0).toDouble(),
      weeklyEarning: (json['weekly_earning'] ?? 0).toDouble(),
      monthlyEarning: (json['monthly_earning'] ?? 0).toDouble(),
      threeMonthEarning: (json['three_month_earning'] ?? 0).toDouble(),
      rank: json['rank'] ?? 0,
    );
  }
}
