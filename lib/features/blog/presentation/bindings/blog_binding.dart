import 'package:get/get.dart';
import '../../data/datasources/blog_remote_data_source.dart';
import '../../data/repositories/blog_repository.dart';
import '../../domain/usecases/get_blogs_usecase.dart';
import '../../domain/usecases/get_blog_details_usecase.dart';
import '../controllers/blog_controller.dart';

class BlogBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<BlogRemoteDataSourceInterface>(() => BlogRemoteDataSource(apiClient: Get.find()));

    // Repository
    Get.lazyPut<BlogRepository>(() => BlogRepository(remoteDataSource: Get.find<BlogRemoteDataSourceInterface>()));

    // UseCases
    Get.lazyPut(() => GetBlogsUseCase(Get.find<BlogRepository>()));
    Get.lazyPut(() => GetBlogDetailsUseCase(Get.find<BlogRepository>()));

    // Controller
    Get.lazyPut(() => BlogController(
          getBlogsUseCase: Get.find(),
          getBlogDetailsUseCase: Get.find(),
        ));
  }
}
