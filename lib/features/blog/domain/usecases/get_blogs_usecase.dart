import '../models/blog_model.dart';
import '../repositories/blog_repository_interface.dart';

class GetBlogsUseCase {
  final BlogRepositoryInterface repository;

  GetBlogsUseCase(this.repository);

  Future<List<BlogModel>> execute() async {
    return await repository.getBlogList();
  }
}
