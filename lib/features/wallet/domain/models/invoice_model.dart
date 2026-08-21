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
  final double tdsAmount;
  final double tdsPercent;
  final double netPayable;
  final double totalWithdrawn;
  final String status;
  final String? payoutNumber;
  final String? paymentMode;
  final String? utrNumber;
  final String? downloadUrl;

  InvoiceItemModel({
    required this.monthName,
    required this.grossEarnings,
    this.tdsAmount = 0.0,
    this.tdsPercent = 0.0,
    required this.netPayable,
    required this.totalWithdrawn,
    required this.status,
    this.payoutNumber,
    this.paymentMode,
    this.utrNumber,
    this.downloadUrl,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    double gross = InvoiceSummaryModel._parseDouble(json['gross_earnings'] ?? json['gross_amount']);
    double tds = InvoiceSummaryModel._parseDouble(json['tds_amount']);
    double tdsPct = InvoiceSummaryModel._parseDouble(json['tds_percent']);
    
    // Calculate tds_percent dynamically if missing but tds_amount is provided
    if (tdsPct == 0.0 && gross > 0 && tds > 0) {
      tdsPct = (tds / gross) * 100.0;
    }
    
    double net = InvoiceSummaryModel._parseDouble(json['net_payable'] ?? json['net_paid_amount']);
    if (net == 0.0 && gross > 0) {
      net = gross - tds;
    }

    return InvoiceItemModel(
      monthName: json['month_name']?.toString() ?? json['payout_number']?.toString() ?? json['payment_date']?.toString() ?? '',
      grossEarnings: gross,
      tdsAmount: tds,
      tdsPercent: tdsPct,
      netPayable: net,
      totalWithdrawn: InvoiceSummaryModel._parseDouble(json['total_withdrawn'] ?? json['net_paid_amount']),
      status: json['status']?.toString() ?? 'completed',
      payoutNumber: json['payout_number']?.toString(),
      paymentMode: json['payment_mode']?.toString(),
      utrNumber: json['utr_number']?.toString(),
      downloadUrl: json['download_url']?.toString() ?? json['invoice_url']?.toString() ?? json['receipt_proof_url']?.toString(),
    );
  }
}
