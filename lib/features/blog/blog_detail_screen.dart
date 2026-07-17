import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

import 'domain/models/blog_model.dart';
import '../../core/constants/app_urls.dart';

import 'presentation/controllers/blog_controller.dart';

class BlogDetailScreen extends StatefulWidget {
  final BlogModel blog;

  const BlogDetailScreen({super.key, required this.blog});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  late BlogController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<BlogController>();
    // Set initial data from list and fetch fresh details
    _controller.selectedBlog.value = widget.blog;
    _controller.fetchBlogDetails(widget.blog.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Obx(() {
        final blog = _controller.selectedBlog.value ?? widget.blog;
        final isLoading = _controller.isDetailLoading.value;

        return CustomScrollView(
          slivers: [
            // Parallax Header
            SliverAppBar(
              pinned: true,
              expandedHeight: 350,
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      '${AppUrls.baseImageUrl}${blog.blogImage}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.network(
                        'https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?q=80&w=1000',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: AppText(
                              blog.type ?? 'General',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppText(
                            blog.title,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.3,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Iconsax.clock_copy, size: 14, color: Colors.white70),
                              const SizedBox(width: 6),
                              AppText(
                                '8 min read',
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(width: 16),
                              const Icon(Iconsax.calendar_1_copy, size: 14, color: Colors.white70),
                              const SizedBox(width: 6),
                              AppText(
                                "${blog.createdAt.day} ${_getMonth(blog.createdAt.month)} ${blog.createdAt.year}",
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Content
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                transform: Matrix4.translationValues(0, -20, 0),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      
                      // Main Content
                      AppText(
                        blog.subtitle,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.9),
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                      const SizedBox(height: 24),
                      AppText(
                        blog.content,
                        fontSize: 16,
                        color: Colors.grey.shade800,
                        height: 1.8,
                      ),
                      const SizedBox(height: 40),
                      
                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTag("Astrology"),
                          _buildTag("Horoscope"),
                          _buildTag(blog.type ?? "General"),
                          _buildTag("Vedic"),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: AppText(
        "#$label",
        fontSize: 12,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }
}
