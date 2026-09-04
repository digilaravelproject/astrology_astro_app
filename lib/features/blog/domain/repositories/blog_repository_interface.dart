import 'package:astro_astrologer/features/blog/data/models/blog_model.dart';

abstract class BlogRepositoryInterface {
  Future<List<BlogModel>> getBlogList();
  Future<BlogModel?> getBlogDetails(int id);
}
