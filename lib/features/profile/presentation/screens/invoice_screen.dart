import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:astro_astrologer/features/wallet/domain/usecases/get_invoices_summary_usecase.dart';
import 'package:astro_astrologer/features/wallet/presentation/controllers/invoice_controller.dart';
import 'package:astro_astrologer/features/wallet/data/models/invoice_model.dart';

import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with TickerProviderStateMixin {
  late InvoiceController _invoiceController;

  // Track which tiles are expanded
  final RxList<bool> _expandedStates = <bool>[].obs;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<InvoiceController>()) {
      Get.put(
        InvoiceController(
          GetInvoicesSummaryUseCase(
            WalletRepositoryImpl(apiClient: Get.find<ApiClient>()),
          ),
        ),
      );
    }
    _invoiceController = Get.find<InvoiceController>();

    // Automatically set expanded states when data changes
    ever(_invoiceController.summary, (InvoiceSummaryModel? summary) {
      if (summary != null) {
        _expandedStates.value = List.generate(
          summary.invoices.length,
          (i) => i == 0, // Expand first by default
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: CustomAppBar(title: 'Invoice'.tr),
      body: Obx(() {
        if (_invoiceController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_invoiceController.error.value.isNotEmpty) {
          return Center(child: Text(_invoiceController.error.value));
        }

        final summary = _invoiceController.summary.value;
        if (summary == null) {
          return Center(child: Text('No invoices found.'.tr));
        }

        return Column(
          children: [
            _buildSummaryHeader(summary),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: summary.invoices.length,
                itemBuilder: (context, index) {
                  return _buildInvoiceCard(summary.invoices[index], index);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryHeader(InvoiceSummaryModel summary) {
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
                'Total Earnings'.tr,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${summary.totalEarnings.toStringAsFixed(2)}',
                style: const TextStyle(
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
                '${summary.totalInvoices} ${'Invoices'.tr}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  summary.status.isNotEmpty ? summary.status.tr : 'All Paid'.tr,
                  style: const TextStyle(
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

  Widget _buildInvoiceCard(InvoiceItemModel invoice, int index) {
    final isExpanded =
        _expandedStates.length > index ? _expandedStates[index] : false;
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
        border:
            isFirst
                ? Border.all(
                  color: AppColors.primaryColor.withOpacity(0.4),
                  width: 1.5,
                )
                : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: isExpanded,
            onExpansionChanged:
                (val) => setState(() => _expandedStates[index] = val),
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 6,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    isFirst
                        ? AppColors.primaryColor.withOpacity(0.08)
                        : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Iconsax.document_text,
                color: isFirst ? AppColors.primaryColor : Colors.grey.shade500,
                size: 20,
              ),
            ),
            title: AppText(
              invoice.monthName,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: AppText(
                '₹${invoice.grossEarnings.toStringAsFixed(2)}',
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
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    invoice.status.tr,
                    style: const TextStyle(
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
                    color: AppColors.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Earnings Detail Row (Gross, TDS, GST, Net Payable)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  label: 'Gross Earnings'.tr,
                                  value:
                                      '₹${invoice.grossEarnings.toStringAsFixed(2)}',
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
                                  label:
                                      invoice.tdsPercent > 0
                                          ? 'TDS (${invoice.tdsPercent.toStringAsFixed(0)}%)'
                                              .tr
                                          : 'TDS Deducted'.tr,
                                  value:
                                      '-₹${invoice.tdsAmount.toStringAsFixed(2)}',
                                  icon: Iconsax.receipt_text_copy,
                                  isRight: true,
                                  valueColor: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            height: 1,
                            color: AppColors.primaryColor.withOpacity(0.1),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  label: 'GST on Payout'.tr,
                                  value: '0% (Exempt)'.tr,
                                  icon: Iconsax.verify,
                                  valueColor: Colors.green.shade700,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: AppColors.primaryColor.withOpacity(0.15),
                              ),
                              Expanded(
                                child: _buildDetailItem(
                                  label: 'Net Payable'.tr,
                                  value:
                                      '₹${invoice.netPayable.toStringAsFixed(2)}',
                                  icon: Iconsax.wallet_check,
                                  isRight: true,
                                ),
                              ),
                            ],
                          ),
                          if (invoice.utrNumber != null &&
                              invoice.utrNumber!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Iconsax.bank,
                                    size: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'UTR: ${invoice.utrNumber}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  if (invoice.paymentMode != null) ...[
                                    const Spacer(),
                                    Text(
                                      'Via ${invoice.paymentMode}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Divider
                    Divider(
                      height: 1,
                      color: AppColors.primaryColor.withOpacity(0.2),
                    ),
                    // Download Button
                    if (invoice.downloadUrl != null)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _invoiceController.downloadInvoice(
                              invoice.monthName,
                              invoice.downloadUrl!,
                            );
                          },
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(11),
                            bottomRight: Radius.circular(11),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Obx(() {
                                  final isDownloading =
                                      _invoiceController.isDownloading[invoice
                                          .monthName] ==
                                      true;
                                  return isDownloading
                                      ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Icon(
                                        Iconsax.import_copy,
                                        color: AppColors.primaryColor,
                                        size: 18,
                                      );
                                }),
                                const SizedBox(width: 10),
                                Obx(() {
                                  final isDownloading =
                                      _invoiceController.isDownloading[invoice
                                          .monthName] ==
                                      true;
                                  return Text(
                                    isDownloading
                                        ? 'Downloading...'.tr
                                        : 'Download Invoice'.tr,
                                    style: const TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                }),
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
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: isRight ? 16 : 0, right: isRight ? 0 : 16),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.primaryColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
