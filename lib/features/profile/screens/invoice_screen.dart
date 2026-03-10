import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with TickerProviderStateMixin {
  final List<Map<String, String>> invoices = [
    {'month': 'January 2026', 'earnings': '₹45,403.76', 'status': 'Paid'},
    {'month': 'December 2025', 'earnings': '₹32,100.00', 'status': 'Paid'},
    {'month': 'November 2025', 'earnings': '₹28,500.50', 'status': 'Paid'},
    {'month': 'October 2025', 'earnings': '₹15,200.00', 'status': 'Paid'},
    {'month': 'September 2025', 'earnings': '₹41,000.25', 'status': 'Paid'},
    {'month': 'August 2025', 'earnings': '₹12,050.00', 'status': 'Paid'},
  ];

  // Track which tiles are expanded
  late List<bool> _expandedStates;

  @override
  void initState() {
    super.initState();
    _expandedStates = List.generate(
      invoices.length,
      (i) => invoices[i]['month'] == 'January 2026',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: const CustomAppBar(title: 'Invoice'),
      body: Column(
        children: [
          _buildSummaryHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                return _buildInvoiceCard(invoices[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      // Use AppColors.primaryColor instead of green gradient
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.receipt_item,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Earnings',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '₹1,74,254.51',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '6 Invoices',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'All Paid',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(Map<String, String> invoice, int index) {
    final isExpanded = _expandedStates[index];
    final isFirst = index == 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isExpanded ? 0.07 : 0.04),
            blurRadius: isExpanded ? 14 : 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: isFirst
            ? Border.all(color: AppColors.primaryColor.withOpacity(0.4), width: 1.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: isExpanded,
            onExpansionChanged: (val) =>
                setState(() => _expandedStates[index] = val),
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            childrenPadding:
                const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isFirst
                    ? AppColors.primaryColor.withOpacity(0.08)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Iconsax.document_text,
                color: isFirst
                    ? AppColors.primaryColor
                    : Colors.grey.shade500,
                size: 20,
              ),
            ),
            title: AppText(
              invoice['month']!,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: AppText(
                invoice['earnings']!,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Paid',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
                ),
              ],
            ),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Earnings Detail Row
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              label: 'Gross Earnings',
                              value: invoice['earnings']!,
                              icon: Iconsax.money_recive,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.primaryColor.withOpacity(0.15),
                          ),
                          Expanded(
                            child: _buildDetailItem(
                              label: 'Net Payable',
                              value: invoice['earnings']!,
                              icon: Iconsax.wallet_check,
                              isRight: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Divider
                    Divider(
                      height: 1,
                      color: AppColors.primaryColor.withOpacity(0.2),
                    ),
                    // Download Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(11),
                          bottomRight: Radius.circular(11),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              const Icon(
                                Iconsax.import_copy,
                                color: AppColors.primaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Download Invoice',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.primaryColor,
                                size: 13,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    required IconData icon,
    bool isRight = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
          left: isRight ? 16 : 0, right: isRight ? 0 : 16),
      child: Column(
        crossAxisAlignment:
            isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isRight) ...[
                Icon(icon, size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRight) ...[
                const SizedBox(width: 4),
                Icon(icon, size: 13, color: Colors.grey.shade500),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
