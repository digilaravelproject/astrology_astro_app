import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import 'package:astro_astrologer/features/kundli/kundli_screen.dart';
import 'package:astro_astrologer/features/call/call_details_screen.dart';
import 'package:astro_astrologer/features/home/widgets/add_note_bottom_sheet.dart';
import 'package:astro_astrologer/features/home/widgets/animated_favorite_button.dart';
import '../../../core/widgets/loyal_badge.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(
        title: 'Call History',
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildHistoryCard(
                  context,
                  type: "New (indian)",
                  status: "Completed",
                  id: "#1770633564107018",
                  price: "2.5",
                  date: "09 Feb 2026 (04:09-04:10 PM)",
                  details: {
                    "Name": "Gurudev (AT-8MWK66Q)",
                    "Gender": "Male",
                    "DOB": "05-November-2003,12:00 PM",
                    "Duration": "2 minutes",
                    "Rate": "₹ 2.5/min",
                    "POB": "Shahada, Maharashtra, India",
                  },
                  showRefund: true,
                ),
                const SizedBox(height: 12),
                _buildHistoryCard(
                  context,
                  type: "Repeat (indian)",
                  status: "Completed",
                  id: "#1770627442093338",
                  price: "105.0",
                  date: "09 Feb 2026 (02:27-02:35 PM)",
                  isLoyal: true,
                  details: {
                    "Name": "Pallavi (AT-MKK63GE)",
                    "Gender": "Female",
                    "DOB": "10-December-1982,04:15 PM",
                    "Duration": "8 minutes",
                    "Rate": "₹ 15.0/min",
                    "Rating": "⭐⭐⭐⭐⭐",
                    "POB": "Nashik, Maharashtra, India",
                  },
                  showSuggestRemedy: true,
                ),
              ],
            ),
          ),
          _buildFooterNote(),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context, {
    required String type,
    required String status,
    required String id,
    required String price,
    required String date,
    required Map<String, String> details,
    bool isLoyal = false,
    bool showRefund = false,
    bool showSuggestRemedy = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => CallDetailsScreen(
                    title: 'Call Details',
                    name: details["Name"]?.replaceAll(RegExp(r' \(.*\)'), '') ?? "N/A",
                    dateOfBirth: details["DOB"] ?? "N/A",
                    placeOfBirth: details["POB"] ?? "N/A",
                    gender: details["Gender"] ?? "N/A",
                    schedule: date,
                    duration: details["Duration"] ?? "N/A",
                    rating: details["Rating"] ?? "N/A",
                  ));
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Pills row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue.shade50.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppText(
                          type,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade400,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              status,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                            if (status == 'Completed') ...[
                              const SizedBox(width: 4),
                              Icon(Icons.check_circle, color: Colors.green.shade600, size: 14),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Astrotalk, ID and Icons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade300, Colors.deepOrange.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText("Astrotalk", fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            const SizedBox(height: 2),
                            AppText(
                              "ID: $id",
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const Padding(
                                  padding: EdgeInsets.only(top: 100),
                                  child: AddNoteBottomSheet(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Iconsax.document_copy, size: 16, color: Colors.grey.shade600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.more_vert, size: 16, color: Colors.grey.shade600),
                              ),
                              color: Colors.white,
                              onSelected: (value) {
                                if (value == 'block') {
                                  Get.snackbar(
                                    'Block User',
                                    'Block user action triggered for ${details["Name"]}',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.black87,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'block',
                                  child: AppText('Block User', fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const AnimatedFavoriteButton(),
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

                      // Details Table
                      ...details.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: AppText(
                                  entry.key,
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
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
                                        color: entry.key == "Rating" ? Colors.amber : Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
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

                      const SizedBox(height: 20),

                      // Buttons
                      Row(
                        children: [
                          if (showSuggestRemedy) ...[
                            Expanded(
                              child: CustomButton(
                                text: "Suggest Remedy",
                                onPressed: () {},
                                height: 42,
                                padding: EdgeInsets.zero,
                                buttonType: ButtonStyleType.outlined,
                                borderRadius: 8,
                                textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: CustomButton(
                              text: "Open Kundli",
                              onPressed: () => Get.to(() => const KundliScreen()),
                              height: 42,
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
                              height: 42,
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
                        const SizedBox(height: 12),
                        const AppText(
                          "Refund",
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 2),
                        const AppText(
                          "PO@Rs5",
                          fontSize: 13,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ],
                  ),
                ),
          ),
          if (isLoyal) LoyalBadge.positioned(),
        ],
      ),
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
