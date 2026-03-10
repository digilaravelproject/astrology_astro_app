import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';
import 'blog_detail_screen.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _categories = ["All", "Planetary Influence", "Transits", "Wellness", "Vedic"];
  String _selectedCategory = "All";

  final List<Map<String, dynamic>> _allBlogs = [
    {
      "title": "The Power of Saturn in Vedic Astrology",
      "excerpt": "Learn how the 'Great Teacher' influences your life through discipline, hard work, and eventual rewards.",
      "image": "https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?q=80&w=1000",
      "author": "Acharya Rahul",
      "authorAvatar": "R",
      "date": "20 Feb 2026",
      "readTime": "8 min read",
      "category": "Planetary Influence",
      "content": "Saturn, known as Shani in Vedic astrology, is often misunderstood as a purely malefic planet. However, its true purpose is to bring structure and discipline to our lives. When Saturn is well-placed, it bestows immense patience, durability, and success through grit..."
    },
    {
      "title": "Mars Transit 2026: Energy and Action",
      "excerpt": "Prepare for a surge in energy as Mars moves through Aries. Find out what this means for your zodiac sign.",
      "image": "https://images.unsplash.com/photo-1614728894747-a83421e2b9c9?q=80&w=1000",
      "author": "Sneha Astro",
      "authorAvatar": "S",
      "date": "18 Feb 2026",
      "readTime": "5 min read",
      "category": "Transits",
      "content": "Mars, the planet of courage and vitality, enters its own sign Aries this month. This transition marks a period of high motivation and new beginnings. For fire signs, this is the time to execute long-pending plans..."
    },
    {
      "title": "Meditation Secrets for better Zodiac Health",
      "excerpt": "Discover specific meditation techniques tailored for each zodiac sign to balance your inner energy.",
      "image": "https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=1000",
      "author": "Swami Ji",
      "authorAvatar": "S",
      "date": "15 Feb 2026",
      "readTime": "12 min read",
      "category": "Wellness",
      "content": "Our cosmic energy is deeply tied to our mental peace. Earth signs find grounding through forest meditation, while Water signs excel with sound-based focus. In this blog, we explore how to align your mind with your stars..."
    },
  ];

  List<Map<String, dynamic>> _filteredBlogs = [];

  @override
  void initState() {
    super.initState();
    _filteredBlogs = _allBlogs;
  }

  void _filterBlogs() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBlogs = _allBlogs.where((blog) {
        bool matchesQuery = blog['title']!.toLowerCase().contains(query) ||
            blog['category']!.toLowerCase().contains(query);
        bool matchesCategory = _selectedCategory == "All" || blog['category'] == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF9F5),
      appBar: const CustomAppBar(
        title: 'Astrology Blogs',
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _filteredBlogs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredBlogs.length,
                    itemBuilder: (context, index) {
                      return _buildPremiumBlogCard(_filteredBlogs[index]);
                    },
                  ),
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
        onChanged: (_) => _filterBlogs(),
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
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
                _filterBlogs();
              });
            },
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
      ),
    );
  }

  Widget _buildPremiumBlogCard(Map<String, dynamic> blog) {
    return GestureDetector(
      onTap: () => Get.to(() => BlogDetailScreen(blog: blog)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    blog['image'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: AppText(
                      blog['category'],
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        blog['date'],
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                      Row(
                        children: [
                          const Icon(Iconsax.clock_copy, size: 14, color: AppColors.primaryColor),
                          const SizedBox(width: 4),
                          AppText(
                            blog['readTime'],
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    blog['title'],
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E1A47),
                    height: 1.3,
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    blog['excerpt'],
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        child: AppText(
                          blog['authorAvatar'],
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppText(
                        blog['author'],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      const Spacer(),
                      const Icon(Iconsax.arrow_right_3_copy, size: 18, color: AppColors.primaryColor),
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
