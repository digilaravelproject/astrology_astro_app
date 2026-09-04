import 'package:astro_astrologer/features/blog/data/models/blog_model.dart';
import 'package:astro_astrologer/features/blog/domain/repositories/blog_repository_interface.dart';

class GetBlogsUseCase {
  final BlogRepositoryInterface repository;

  GetBlogsUseCase(this.repository);

  Future<List<BlogModel>> execute() async {
    return await repository.getBlogList();
  }
}
