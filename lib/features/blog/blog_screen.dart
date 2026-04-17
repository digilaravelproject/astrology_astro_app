import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'blog_detail_screen.dart';
import 'domain/models/blog_model.dart';
import 'presentation/controllers/blog_controller.dart';
import 'presentation/bindings/blog_binding.dart';
import '../../core/constants/app_urls.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  late BlogController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<BlogController>()) {
      BlogBinding().dependencies();
    }
    _controller = Get.find<BlogController>();
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
      backgroundColor: const Color(0xFFFDF9F5),
      appBar: const CustomAppBar(
        title: 'Astrology Blogs',
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.allBlogs.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.refreshBlogs,
          color: AppColors.primaryColor,
          child: Column(
            children: [
              _buildSearchBar(),
              _buildCategoryFilter(),
              Expanded(
                child: _controller.filteredBlogs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _controller.filteredBlogs.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return _buildPremiumBlogCard(_controller.filteredBlogs[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search blogs...',
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

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      color: Colors.white,
      child: Obx(() => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: _controller.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = _controller.categories[index];
          final isSelected = category == _controller.selectedCategory.value;
          return GestureDetector(
            onTap: () => _controller.updateCategory(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(100),
                border: isSelected ? null : Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: AppText(
                  category,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          );
        },
      )),
    );
  }

  Widget _buildPremiumBlogCard(BlogModel blog) {
    return GestureDetector(
      onTap: () => Get.to(() => BlogDetailScreen(blog: blog)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    '${AppUrls.baseImageUrl}${blog.blogImage}',
                    height: 110,
                    width: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.network(
                      'https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?q=80&w=1000',
                      height: 110,
                      width: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      blog.type ?? 'General',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Right: Content Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        "${blog.createdAt.day} ${_getMonth(blog.createdAt.month)} ${blog.createdAt.year}",
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                      Row(
                        children: [
                          const Icon(Iconsax.clock_copy, size: 12, color: AppColors.primaryColor),
                          const SizedBox(width: 4),
                          AppText(
                            '8m',
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    blog.title,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E1A47),
                    height: 1.2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    blog.subtitle,
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.4,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        child: AppText(
                          blog.author.isNotEmpty ? blog.author[0].toUpperCase() : 'A',
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      AppText(
                        blog.author,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      const Spacer(),
                      const Icon(Iconsax.arrow_right_3_copy, size: 14, color: AppColors.primaryColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document_text_1_copy, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          AppText('No blogs found', fontSize: 16, color: Colors.grey.shade500),
        ],
      ),
    );
  }
}
