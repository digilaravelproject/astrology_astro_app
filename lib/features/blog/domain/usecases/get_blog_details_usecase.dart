import 'package:astro_astrologer/features/blog/data/models/blog_model.dart';
import 'package:astro_astrologer/features/blog/domain/repositories/blog_repository_interface.dart';

class GetBlogDetailsUseCase {
  final BlogRepositoryInterface repository;

  GetBlogDetailsUseCase(this.repository);

  Future<BlogModel?> execute(int id) async {
    return await repository.getBlogDetails(id);
  }
}
