import '../models/blog_model.dart';
import '../repositories/blog_repository_interface.dart';

class GetBlogDetailsUseCase {
  final BlogRepositoryInterface repository;

  GetBlogDetailsUseCase(this.repository);

  Future<BlogModel?> execute(int id) async {
    return await repository.getBlogDetails(id);
  }
}
