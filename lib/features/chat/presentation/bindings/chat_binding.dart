import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import '../../data/datasources/chat_local_data_source.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/i_chat_repository.dart';
import '../../domain/usecases/end_chat_session_usecase.dart';
import '../../domain/usecases/load_chat_history_usecase.dart';
import '../../domain/usecases/mark_messages_read_usecase.dart';
import '../../domain/usecases/send_attachment_usecase.dart';
import '../../domain/usecases/send_text_message_usecase.dart';
import '../controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    // Data sources and Repositories are now provided globally in InitialBindings

    // 3. Use Cases
    Get.lazyPut(
      () => LoadChatHistoryUseCase(Get.find<IChatRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => SendTextMessageUseCase(Get.find<IChatRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => SendAttachmentUseCase(Get.find<IChatRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => MarkMessagesReadUseCase(Get.find<IChatRepository>()),
      fenix: true,
    );
    Get.lazyPut(
      () => EndChatSessionUseCase(Get.find<IChatRepository>()),
      fenix: true,
    );

    // 4. Controller
    Get.lazyPut(
      () => ChatController(
        loadChatHistoryUseCase: Get.find<LoadChatHistoryUseCase>(),
        sendTextMessageUseCase: Get.find<SendTextMessageUseCase>(),
        sendAttachmentUseCase: Get.find<SendAttachmentUseCase>(),
        markMessagesReadUseCase: Get.find<MarkMessagesReadUseCase>(),
        endChatSessionUseCase: Get.find<EndChatSessionUseCase>(),
      ),
    );
  }
}
