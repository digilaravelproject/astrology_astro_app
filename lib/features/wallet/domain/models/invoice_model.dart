class InvoiceSummaryModel {
  final double totalEarnings;
  final double totalWithdrawn;
  final int totalInvoices;
  final String status;
  final InvoiceItemModel? currentMonth;
  final List<InvoiceItemModel> invoices;

  InvoiceSummaryModel({
    required this.totalEarnings,
    required this.totalWithdrawn,
    required this.totalInvoices,
    required this.status,
    this.currentMonth,
    required this.invoices,
  });

  factory InvoiceSummaryModel.fromJson(Map<String, dynamic> json) {
    return InvoiceSummaryModel(
      totalEarnings: _parseDouble(json['total_earnings']),
      totalWithdrawn: _parseDouble(json['total_withdrawn']),
      totalInvoices: json['total_invoices'] ?? 0,
      status: json['status']?.toString() ?? '',
      currentMonth: json['current_month'] != null
          ? InvoiceItemModel.fromJson(json['current_month'])
          : null,
      invoices: json['invoices'] != null
          ? (json['invoices'] as List)
              .map((e) => InvoiceItemModel.fromJson(e))
              .toList()
          : [],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class InvoiceItemModel {
  final String monthName;
  final double grossEarnings;
  final double netPayable;
  final double totalWithdrawn;
  final String status;
  final String? downloadUrl;

  InvoiceItemModel({
    required this.monthName,
    required this.grossEarnings,
    required this.netPayable,
    required this.totalWithdrawn,
    required this.status,
    this.downloadUrl,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      monthName: json['month_name']?.toString() ?? '',
      grossEarnings: InvoiceSummaryModel._parseDouble(json['gross_earnings']),
      netPayable: InvoiceSummaryModel._parseDouble(json['net_payable']),
      totalWithdrawn: InvoiceSummaryModel._parseDouble(json['total_withdrawn']),
      status: json['status']?.toString() ?? '',
      downloadUrl: json['download_url']?.toString(),
    );
  }
}
