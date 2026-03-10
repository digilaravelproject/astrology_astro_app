import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Call', 'Chat', 'Astromall'];

  final List<Map<String, dynamic>> _reviews = [
    {
      'orderId': '315206343',
      'user': 'Rahul',
      'type': 'Chat',
      'date': '19 Feb 2026',
      'rating': 5,
      'content': '',
      'isPinned': false,
      'isFlagged': false,
    },
    {
      'orderId': '315166883',
      'user': 'Renu',
      'type': 'Chat',
      'date': '19 Feb 2026',
      'rating': 5,
      'content': '',
      'isPinned': false,
      'isFlagged': false,
    },
    {
      'orderId': '315163211',
      'user': 'Sakhi',
      'type': 'Chat',
      'date': '19 Feb 2026',
      'rating': 5,
      'content': '',
      'isPinned': false,
      'isFlagged': false,
    },
    {
      'orderId': '85991738',
      'user': 'Pooja',
      'type': 'Call',
      'date': '19 Feb 2026',
      'rating': 5,
      'content': '',
      'isPinned': false,
      'isFlagged': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'My Reviews',
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.push_pin, size: 14, color: Colors.grey),
              label: const AppText('Pinned', fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey,
                elevation: 0,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFlaggedSection(),
          _buildCategoryFilters(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                return _buildReviewCard(_reviews[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlaggedSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const AppText('Flagged reviews ', fontSize: 16, fontWeight: FontWeight.bold),
                  AppText('(excluding PO)', fontSize: 13, color: Colors.grey.shade500),
                ],
              ),
              const AppText('8/10', fontSize: 14, fontWeight: FontWeight.bold),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.8,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor.withOpacity(0.6)),
            ),
          ),
          const SizedBox(height: 12),
          AppText(
            'System gives you maximum 10 flags for your reviews every month. Used balance will get reset every 1st day of the month.',
            fontSize: 11,
            color: Colors.grey.shade500,
            height: 1.4,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
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
                  if (category == 'All') ...[
                    const Icon(Icons.star, size: 14, color: AppColors.goldAccent),
                    const SizedBox(width: 4),
                  ],
                  if (category == 'Call') ...[
                    const Icon(Icons.call, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                  ],
                  if (category == 'Chat') ...[
                    const Icon(Icons.chat_bubble_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                  ],
                  if (category == 'Astromall') ...[
                    const Icon(Icons.shop, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                  ],
                  AppText(
                    category,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primaryColor : Colors.black87,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          AppText(
            'Order ID: ${review['orderId']}',
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                child: AppText(review['user'][0], color: AppColors.primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(review['user'], fontSize: 15, fontWeight: FontWeight.bold),
                    Row(
                      children: [
                        AppText(review['type'], fontSize: 12, color: AppColors.infoColor),
                        AppText(' · ${review['date']}', fontSize: 12, color: Colors.grey.shade500),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return const Icon(Icons.star_rounded, color: AppColors.goldAccent, size: 18);
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.reply, size: 18, color: AppColors.successColor),
                label: const AppText('Reply to this review', fontSize: 13, color: AppColors.successColor, fontWeight: FontWeight.w600),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.flag_outlined, color: Colors.grey, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.push_pin_outlined, color: Colors.grey, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

