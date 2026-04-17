import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../core/constants/app_urls.dart';
import 'presentation/controllers/remedy_controller.dart';
import 'presentation/bindings/remedy_binding.dart';
import 'domain/models/remedy_model.dart';
import 'presentation/screens/remedy_detail_screen.dart';

class SuggestedRemediesScreen extends StatefulWidget {
  const SuggestedRemediesScreen({super.key});

  @override
  State<SuggestedRemediesScreen> createState() => _SuggestedRemediesScreenState();
}

class _SuggestedRemediesScreenState extends State<SuggestedRemediesScreen> {
  late RemedyController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<RemedyController>()) {
      RemedyBinding().dependencies();
    }
    _controller = Get.find<RemedyController>();
    _searchController.addListener(() {
      _controller.updateSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const CustomAppBar(
        title: 'Astrology Remedies',
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value && _controller.remedies.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_controller.filteredRemedies.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: _controller.refreshRemedies,
                color: AppColors.primaryColor,
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _controller.filteredRemedies.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return RemedyCard(remedy: _controller.filteredRemedies[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search remedies...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: const Icon(Iconsax.search_normal_1_copy, size: 20, color: AppColors.primaryColor),
          filled: true,
          fillColor: const Color(0xFFF8F8F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document_text_1_copy, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          AppText('No remedies found', fontSize: 16, color: Colors.grey.shade500),
        ],
      ),
    );
  }
}

class RemedyCard extends StatelessWidget {
  final RemedyModel remedy;

  const RemedyCard({
    super.key,
    required this.remedy,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => RemedyDetailScreen(remedyId: remedy.id)),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7CB342).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const AppText(
                            'Astrology Remedy',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7CB342),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppText(
                          remedy.title,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E1A47),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          remedy.description,
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Hero(
                    tag: 'remedy_image_${remedy.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        remedy.image ?? 'https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?q=80&w=1000',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade100,
                          child: Icon(Iconsax.image_copy, color: Colors.grey.shade400, size: 40),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
