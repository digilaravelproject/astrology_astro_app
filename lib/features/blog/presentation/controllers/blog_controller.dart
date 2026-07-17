import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/blog_model.dart';
import '../../domain/usecases/get_blogs_usecase.dart';
import '../../domain/usecases/get_blog_details_usecase.dart';

class BlogController extends GetxController {
  final GetBlogsUseCase _getBlogsUseCase;
  final GetBlogDetailsUseCase _getBlogDetailsUseCase;

  BlogController({
    required GetBlogsUseCase getBlogsUseCase,
    required GetBlogDetailsUseCase getBlogDetailsUseCase,
  })  : _getBlogsUseCase = getBlogsUseCase,
        _getBlogDetailsUseCase = getBlogDetailsUseCase;

  final isLoading = false.obs;
  final allBlogs = <BlogModel>[].obs;
  final filteredBlogs = <BlogModel>[].obs;
  final categories = <String>["All"].obs;
  final selectedCategory = "All".obs;
  final searchQuery = "".obs;
  final selectedBlog = Rxn<BlogModel>();
  final isDetailLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    try {
      isLoading.value = true;
      final result = await _getBlogsUseCase.execute();
      allBlogs.assignAll(result);
      
      // Extract unique categories from blogs
      final uniqueCategories = result
          .map((blog) => blog.type ?? "General")
          .where((type) => type.isNotEmpty)
          .toSet()
          .toList();
      
      categories.assignAll(["All", ...uniqueCategories]);
      _applyFilters();
    } catch (e) {
      debugPrint('Error fetching blogs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    filteredBlogs.assignAll(allBlogs.where((blog) {
      final matchesCategory = selectedCategory.value == "All" || 
                              (blog.type ?? "General") == selectedCategory.value;
      final matchesSearch = blog.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
                            blog.subtitle.toLowerCase().contains(searchQuery.value.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList());
  }

  // Fetch single blog details
  Future<void> fetchBlogDetails(int id) async {
    try {
      isDetailLoading.value = true;
      final result = await _getBlogDetailsUseCase.execute(id);
      if (result != null) {
        selectedBlog.value = result;
      }
    } catch (e) {
      debugPrint('Error fetching blog details: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  // Refresh helper
  Future<void> refreshBlogs() async {
    await fetchBlogs();
  }
}
