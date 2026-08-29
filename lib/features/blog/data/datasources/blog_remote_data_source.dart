import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage/shared_prefs.dart';
import '../../../../core/utils/logger.dart';

abstract class BlogRemoteDataSourceInterface {
  Future<ResponseModel> getBlogList();
  Future<ResponseModel> getBlogDetails(int id);
}

class BlogRemoteDataSource implements BlogRemoteDataSourceInterface {
  final ApiClient apiClient;

  BlogRemoteDataSource({required this.apiClient});

  @override
  Future<ResponseModel> getBlogList() async {
    try {
      final lang = SharedPrefs.getString(AppConstants.language) ?? 'en';
      final response = await apiClient.get('${AppUrls.blogs}?language=$lang');
      Logger.d('BlogRemoteDataSource.getBlogList success');
      return response;
    } catch (e) {
      Logger.e('BlogRemoteDataSource.getBlogList error: $e');
      return ResponseModel(
        isSuccess: false,
        message: 'Something went wrong: $e',
      );
    }
  }

  @override
  Future<ResponseModel> getBlogDetails(int id) async {
    try {
      final lang = SharedPrefs.getString(AppConstants.language) ?? 'en';
      final response = await apiClient.get(
        '${AppUrls.blogDetails(id)}?language=$lang',
      );
      Logger.d('BlogRemoteDataSource.getBlogDetails success');
      return response;
    } catch (e) {
      Logger.e('BlogRemoteDataSource.getBlogDetails error: $e');
      return ResponseModel(
        isSuccess: false,
        message: 'Something went wrong: $e',
      );
    }
  }
}
