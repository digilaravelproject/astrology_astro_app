import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';

class TrainingVideosListScreen extends StatefulWidget {
  const TrainingVideosListScreen({super.key});

  @override
  State<TrainingVideosListScreen> createState() => _TrainingVideosListScreenState();
}

class _TrainingVideosListScreenState extends State<TrainingVideosListScreen> {
  String _selectedFilter = 'Call/Chat';

  final List<String> _filters = [
    'Call/Chat',
    'Emergency session',
    'Astromall',
    'Performance',
  ];

  @override
  Widget build(BuildContext context) {
    final titles = [
      "How to use Google\nTranslator in chat\nprocess?",
      "How to see your\nfollowers?",
      "How to check your\nearnings today?",
      "How to update your\nprofile bio?",
      "How to manage your\navailability?",
      "How to use the\nmatching feature?",
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F5), // Premium Ivory
      appBar: const CustomAppBar(title: 'Training Videos'),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: titles.length,
              itemBuilder: (context, index) {
                return _buildVideoCard(titles[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                  width: 1.2,
                ),
              ),
              child: Center(
                child: AppText(
                  filter,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primaryColor : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoCard(String title, int index) {
    return Container(
      decoration: BoxDecoration(
        color: index % 3 == 0 ? const Color(0xFFFFEB3B) : (index % 3 == 1 ? const Color(0xFFFFF176) : const Color(0xFFFFF9C4)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background "Phone Screen" mockup
          Positioned(
            bottom: -20,
            left: 15,
            right: 15,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                border: Border.all(color: Colors.black87, width: 2),
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Center(
                  child: Icon(Icons.smartphone_rounded, color: Colors.grey.shade300, size: 30),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.3,
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.refresh_rounded, size: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
