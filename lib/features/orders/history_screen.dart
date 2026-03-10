import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import 'package:astro_astrologer/features/kundli/kundli_screen.dart';
import '../../../core/widgets/loyal_badge.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF9F5), // Premium Ivory/Off-white
        appBar: const CustomAppBar(
          title: 'History',
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                isScrollable: true,
                dividerColor: Colors.transparent,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                tabs: const [
                  Tab(text: 'Puja'),
                  Tab(text: 'Call'),
                  Tab(text: 'Chat'),
                  Tab(text: 'Report'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPujaHistory(),
                  _buildCallHistory(),
                  _buildChatHistory(),
                  _buildReportHistory(),
                ],
              ),
            ),
            _buildFooterNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildPujaHistory() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildHistoryCard(
          type: "Puja Service",
          status: "Scheduled",
          id: "#PJ177063",
          price: "2100.0",
          date: "15 Feb 26, 11:00 AM",
          details: {
            "Service": "Satyanarayan Puja",
            "Customer": "Rahul Sharma",
            "Location": "Online",
            "Status": "Confirmed",
          },
        ),
      ],
    );
  }

  Widget _buildCallHistory() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildHistoryCard(
          type: "New (indian)",
          status: "Completed",
          id: "#1770633564107018",
          price: "2.5",
          date: "09 Feb 26, 04:09 PM",
          details: {
            "Name": "Gurudev (AT-8MWK66Q)",
            "Duration": "2 minutes",
            "Rate": "₹ 2.5/min",
          },
          showRefund: true,
        ),
        const SizedBox(height: 12),
        _buildHistoryCard(
          type: "Repeat (indian)",
          status: "Completed",
          id: "#1770627442093338",
          price: "105.0",
          date: "09 Feb 26, 02:27 PM",
          isLoyal: true,
          details: {
            "Name": "Pallavi (AT-MKK63GE)",
            "Duration": "8 minutes",
            "Rate": "₹ 15.0/min",
          },
        ),
      ],
    );
  }

  Widget _buildChatHistory() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildHistoryCard(
          type: "Repeat (indian)",
          status: "Completed",
          id: "#1770639436868",
          price: "322.0",
          date: "09 Feb 26, 05:47 PM",
          isLoyal: true,
          details: {
            "Name": "Utkarsha (AT-L78KMZN)",
            "Duration": "29 minutes",
            "Rate": "₹ 11.5/min",
            "offer": "Loyal User Offer (25.0%)",
          },
        ),
      ],
    );
  }

  Widget _buildReportHistory() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildHistoryCard(
          type: "Report (indian)",
          status: "Pending",
          id: "#RP177064",
          price: "499.0",
          date: "10 Feb 26, 12:45 PM",
          details: {
            "Report Type": "Career Report",
            "Customer": "Sanjay Singh",
            "Timeline": "24-48 Hours",
          },
        ),
      ],
    );
  }

  Widget _buildHistoryCard({
    required String type,
    required String status,
    required String id,
    required String price,
    required String date,
    required Map<String, String> details,
    bool isLoyal = false,
    bool showRefund = false,
  }) {
    return Stack(
      children: [
        Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppText(
                          type,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == "Pending" ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              status,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: status == "Pending" ? Colors.orange.shade700 : Colors.green.shade700,
                            ),
                            if (status != "Pending") ...[
                              const SizedBox(width: 4),
                              Icon(Icons.check_circle, color: Colors.green.shade600, size: 14),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Astrotalk and Actions Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange.shade300, Colors.deepOrange.shade400],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppText("Astrotalk", fontSize: 16, fontWeight: FontWeight.w800),
                                AppText(
                                  "ID: $id",
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                          ),
                          // Action Icons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                                child: Icon(Iconsax.document_copy, size: 16, color: Colors.grey.shade600),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                                child: Icon(Icons.more_vert, size: 16, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Price & Date container
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText("Session Date", fontSize: 12, color: Colors.grey.shade500),
                                  const SizedBox(height: 2),
                                  AppText(date, fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AppText("Total Amount", fontSize: 12, color: Colors.grey.shade500),
                                const SizedBox(height: 2),
                                AppText("₹ $price", fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF2E1A47)),
                              ],
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 16),

                      ...details.entries.map((entry) {
                        final isOffer = entry.key.toLowerCase() == "offer";
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 90,
                                child: AppText(
                                  entry.key == "offer" ? "Offer" : entry.key,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const AppText(":  ", fontWeight: FontWeight.bold),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: AppText(
                                        entry.value,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isOffer ? const Color(0xFFD4A66A) : Colors.grey.shade700,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (entry.key == "Name" || entry.key == "POB")
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Icon(Icons.copy_rounded, size: 14, color: AppColors.primaryColor.withOpacity(0.5)),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: "Open Kundli",
                              onPressed: () => Get.to(() => const KundliScreen()),
                              height: 38,
                              padding: EdgeInsets.zero,
                              buttonType: ButtonStyleType.outlined,
                              borderRadius: 8,
                              textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomButton(
                              text: "Chat Assistant",
                              onPressed: () {},
                              height: 38,
                              padding: EdgeInsets.zero,
                              backgroundColor: const Color(0xFF2CB772),
                              prefixIcon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 12),
                              borderRadius: 8,
                              textColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      if (showRefund) ...[
                        const SizedBox(height: 8),
                        const AppText("Refunded", fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (isLoyal) LoyalBadge.positioned(),
      ],
    );
  }

  Widget _buildFooterNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: Center(
        child: AppText(
          "Data shown for last 3 days only",
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.red.shade200,
        ),
      ),
    );
  }
}
