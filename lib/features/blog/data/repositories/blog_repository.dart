import '../../domain/models/blog_model.dart';
import '../../domain/repositories/blog_repository_interface.dart';
import '../datasources/blog_remote_data_source.dart';

class BlogRepository implements BlogRepositoryInterface {
  final BlogRemoteDataSourceInterface remoteDataSource;

  BlogRepository({required this.remoteDataSource});

  @override
  Future<List<BlogModel>> getBlogList() async {
    final response = await remoteDataSource.getBlogList();
    if (response.isSuccess) {
      final List<dynamic> data = response.body['blogs'] ?? response.body['data'] ?? [];
      return data.map((e) => BlogModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  @override
  Future<BlogModel?> getBlogDetails(int id) async {
    final response = await remoteDataSource.getBlogDetails(id);
    if (response.isSuccess) {
      final data = response.body['blog'] ?? response.body['data'];
      if (data != null) {
        return BlogModel.fromJson(data);
      }
    }
    return null;
  }
}
