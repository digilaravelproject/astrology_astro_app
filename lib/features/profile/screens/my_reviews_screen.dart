import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../controllers/review_controller.dart';
import '../model/review_model.dart';
import '../../../core/constants/app_urls.dart';
import '../../../core/utils/custom_snackbar.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final ReviewController controller = Get.find<ReviewController>();
  int _selectedRating = 0; // 0 for All

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'My Reviews',
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchReviews(),
        child: Column(
          children: [
            _buildRatingFilters(),
            Expanded(
              child: Obx(() {
                final filteredReviews = _selectedRating == 0 
                    ? controller.reviews 
                    : controller.reviews.where((r) => r.rating.toInt() == _selectedRating).toList();

                if (filteredReviews.isEmpty) {
                  return ListView(
                    children: [
                      SizedBox(height: Get.height * 0.2),
                      Center(child: AppText(_selectedRating == 0 ? 'No reviews found' : 'No $_selectedRating star reviews found', color: Colors.grey)),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredReviews.length,
                  itemBuilder: (context, index) {
                    return _buildReviewCard(filteredReviews[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRatingFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6, // All, 1, 2, 3, 4, 5 stars
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final isSelected = _selectedRating == index;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedRating = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: isSelected ? AppColors.primaryColor : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded, 
                    size: 18, 
                    color: isSelected ? AppColors.goldAccent : Colors.grey.shade400
                  ),
                  const SizedBox(width: 6),
                  AppText(
                    isAll ? 'All' : '$index Star',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primaryColor : Colors.black87,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    String formattedDate = DateFormat('dd MMM yyyy').format(review.createdAt);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID and Date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  'ID: #${review.id}',
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                AppText(
                  formattedDate,
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info
                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColor.withOpacity(0.1),
                            AppColors.primaryColor.withOpacity(0.2),
                          ],
                        ),
                        image: review.user?.profilePhoto != null 
                            ? DecorationImage(
                                image: CachedNetworkImageProvider('${AppUrls.baseImageUrl}${review.user!.profilePhoto}'),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: review.user?.profilePhoto == null 
                          ? Center(
                              child: AppText(
                                review.user?.name[0].toUpperCase() ?? 'U', 
                                color: AppColors.primaryColor, 
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            review.user?.name ?? 'Anonymous', 
                            fontSize: 15, 
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E1A47),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star_rounded, 
                                color: index < review.rating ? AppColors.goldAccent : Colors.grey.shade200, 
                                size: 16
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Review Content
                if (review.review.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  AppText(
                    review.review,
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.7),
                    height: 1.5,
                  ),
                ],

                // Astrologer's Reply
                if (review.reply != null && review.reply!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        left: BorderSide(color: AppColors.primaryColor.withOpacity(0.4), width: 3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Iconsax.message_text_copy, size: 14, color: AppColors.primaryColor.withOpacity(0.7)),
                            const SizedBox(width: 8),
                            const AppText(
                              'Your Response', 
                              fontSize: 12, 
                              fontWeight: FontWeight.w800, 
                              color: AppColors.primaryColor,
                              letterSpacing: 0.3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          review.reply!, 
                          fontSize: 13, 
                          color: const Color(0xFF4A4A4A),
                          height: 1.4,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                
                // Footer: Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _showReplyDialog(review),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              review.reply == null ? Icons.reply : Icons.edit_note_rounded, 
                              size: 18, 
                              color: AppColors.successColor
                            ),
                            const SizedBox(width: 6),
                            AppText(
                              review.reply == null ? 'Reply to review' : 'Edit Response', 
                              fontSize: 13, 
                              color: AppColors.successColor, 
                              fontWeight: FontWeight.w700,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(ReviewModel review) {
    final TextEditingController replyController = TextEditingController(text: review.reply ?? '');
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    review.reply == null ? 'Reply to Review' : 'Edit Reply',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColor,
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Review by ${review.user?.name ?? "User"}', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                    const SizedBox(height: 4),
                    AppText(review.review, fontSize: 13, color: Colors.grey.shade600, maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const AppText('Your Response', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              const SizedBox(height: 8),
              TextField(
                controller: replyController,
                maxLines: 5,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Type your message here...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isReplying.value 
                    ? null 
                    : () => controller.submitReply(review.id, replyController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: controller.isReplying.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : AppText(review.reply == null ? 'Send Reply' : 'Update Reply', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              )),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
