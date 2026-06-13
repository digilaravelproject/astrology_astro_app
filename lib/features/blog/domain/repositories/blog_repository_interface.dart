import '../models/blog_model.dart';

abstract class BlogRepositoryInterface {
  Future<List<BlogModel>> getBlogList();
  Future<BlogModel?> getBlogDetails(int id);
}
