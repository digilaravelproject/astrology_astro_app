class WalletTransactionModel {
  final int id;
  final int walletId;
  final String transactionType;
  final double amount;
  final String status;
  final String description;
  final Map<String, dynamic>? meta;
  final String createdAt;

  WalletTransactionModel({
    required this.id,
    required this.walletId,
    required this.transactionType,
    required this.amount,
    required this.status,
    required this.description,
    this.meta,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] ?? 0,
      walletId: json['wallet_id'] ?? 0,
      transactionType: json['transaction_type'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      meta: json['meta'] as Map<String, dynamic>?,
      createdAt: json['created_at'] ?? '',
    );
  }
}
