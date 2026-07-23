import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/core/widgets/custom_button.dart';
import 'package:astro_astrologer/features/kundli/kundli_screen.dart';
import 'package:astro_astrologer/features/call/call_details_screen.dart';
import 'package:astro_astrologer/features/home/widgets/add_note_bottom_sheet.dart';
import 'package:astro_astrologer/features/home/widgets/animated_favorite_button.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/assistance_chat_room_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:astro_astrologer/core/widgets/loyal_badge.dart';

import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/features/orders/presentation/controllers/history_controller.dart';
import 'package:astro_astrologer/features/orders/domain/usecases/get_astrologer_call_sessions_usecase.dart';
import 'package:astro_astrologer/features/orders/data/repositories/history_repository.dart';

class CallHistoryScreen extends StatelessWidget {
  final bool isFromTab;
  const CallHistoryScreen({super.key, this.isFromTab = false});

  @override
  Widget build(BuildContext context) {
    // Instantiate the HistoryController with its dependencies
    final HistoryController controller = Get.put(HistoryController(
      getAstrologerCallSessionsUseCase: GetAstrologerCallSessionsUseCase(
        HistoryRepositoryImpl(apiClient: Get.find<ApiClient>()),
      ),
    ));

    Widget content = Column(
      children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.callSessions.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.callSessions.isEmpty) {
                return const Center(child: AppText("No call history available.", fontSize: 16));
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchCallSessions(isRefresh: true),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                      controller.fetchCallSessions();
                    }
                    return true;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: controller.callSessions.length,
                    itemBuilder: (context, index) {
                      final session = controller.callSessions[index];
                      final durationMinutes = (session.durationSeconds / 60).ceil();
                      
                      // Format DOB
                      String dobStr = "N/A";
                      if (session.consumer?.dateOfBirth != null) {
                        try {
                          final dobDate = DateTime.tryParse(session.consumer!.dateOfBirth!)?.toLocal();
                          if (dobDate != null) {
                            final months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
                            final monthName = months[dobDate.month - 1];
                            final day = dobDate.day.toString().padLeft(2, '0');
                            final year = dobDate.year.toString();
                            
                            String timeStr = "";
                            if (session.consumer?.timeOfBirth != null && session.consumer!.timeOfBirth!.isNotEmpty) {
                              timeStr = ",${session.consumer!.timeOfBirth!}";
                            }
                            dobStr = "$day-$monthName-$year$timeStr";
                          }
                        } catch (_) {}
                      }

                      String? dobVal;
                      String? tobVal;
                      if (session.consumer?.dateOfBirth != null) {
                        try {
                          // date_of_birth comes as UTC (e.g. 2006-06-07T18:30:00.000000Z)
                          // toLocal() converts it to IST, giving the correct local date (2006-06-08)
                          final dobDate = DateTime.parse(session.consumer!.dateOfBirth!).toLocal();
                          dobVal = "${dobDate.year}-${dobDate.month.toString().padLeft(2, '0')}-${dobDate.day.toString().padLeft(2, '0')}";
                        } catch (_) {}
                      }
                      // time_of_birth is already in IST (e.g. "19:12"), use directly
                      if (session.consumer?.timeOfBirth != null && session.consumer!.timeOfBirth!.isNotEmpty) {
                        tobVal = session.consumer!.timeOfBirth!;
                        if (tobVal.length == 5) tobVal += ":00";
                      }

                      final Map<String, String> details = {
                        "Name": session.consumer?.name ?? "User (AT-${session.consumerId})",
                        "Gender": session.consumer?.gender?.capitalizeFirst ?? "N/A",
                        "DOB": dobStr,
                        "Duration": "$durationMinutes minutes",
                        "Rate": "₹ ${session.ratePerMinute}/min",
                        "POB": session.consumer?.placeOfBirth ?? "N/A",
                      };

                      return _buildHistoryCard(
                        context,
                        type: "New (indian)",
                        status: session.status.capitalizeFirst ?? "Completed",
                        id: "${session.id}",
                        price: session.totalCost.toString(),
                        date: session.createdAt ?? "N/A",
                        details: details,
                        showRefund: false,
                        imageUrl: session.consumer?.profilePhoto,
                        dobVal: dobVal,
                        tobVal: tobVal,
                        latitude: session.consumer?.latitude,
                        longitude: session.consumer?.longitude,
                        chatAssistanceSessionId: session.chatAssistanceSessionId ?? session.consumer?.chatAssistanceSessionId,
                      );
                    },
                  ),
                ),
              );
            }),
          ),
          _buildFooterNote(),
        ],
      );

    if (isFromTab) return content;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const CustomAppBar(
        title: 'Call History',
      ),
      body: content,
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
    String? imageUrl,
    String? dobVal,
    String? tobVal,
    double? latitude,
    double? longitude,
    int? chatAssistanceSessionId,
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
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl.startsWith('http')
                                      ? imageUrl
                                      : '${AppUrls.baseImageUrl}$imageUrl',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                                  errorWidget: (context, url, error) => Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.orange.shade300, Colors.deepOrange.shade400],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 20),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.orange.shade300, Colors.deepOrange.shade400],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 20),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(details["Name"]?.replaceAll(RegExp(r' \(.*\)'), '') ?? "User", fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
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
                              onPressed: () => Get.to(() => KundliScreen(
                                fullName: details["Name"]?.replaceAll(RegExp(r' \(.*\)'), '') ?? "",
                                gender: details["Gender"] ?? "",
                                dob: dobVal ?? "",
                                tob: tobVal ?? "",
                                place: details["POB"] ?? "",
                                latitude: latitude ?? 0.0,
                                longitude: longitude ?? 0.0,
                              )),
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
                              onPressed: () {
                                debugPrint("Call History: Chat Assistant clicked! chatAssistanceSessionId: $chatAssistanceSessionId");
                                if (chatAssistanceSessionId != null) {
                                  Get.to(() => AssistanceChatRoomScreen(
                                    sessionId: chatAssistanceSessionId,
                                    userName: details["Name"]?.replaceAll(RegExp(r' \(.*\)'), '') ?? "User",
                                    userImage: imageUrl,
                                  ));
                                } else {
                                  Get.snackbar("Error", "No Chat Assistance Session available");
                                }
                              },
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
