import 'package:get/get.dart';
import 'package:astro_astrologer/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/end_chat_session_usecase.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/load_chat_history_usecase.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/mark_messages_read_usecase.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/send_attachment_usecase.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/send_text_message_usecase.dart';
import 'package:astro_astrologer/features/chat/domain/usecases/accept_chat_session_usecase.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/chat_session_controller.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/chat_message_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
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
    Get.lazyPut(
      () => AcceptChatSessionUseCase(Get.find<IChatRepository>()),
      fenix: true,
    );

    // 4. Controllers
    Get.lazyPut(
      () => ChatSessionController(
        endChatSessionUseCase: Get.find<EndChatSessionUseCase>(),
        acceptChatSessionUseCase: Get.find<AcceptChatSessionUseCase>(),
      ),
    );

    Get.lazyPut(
      () => ChatMessageController(
        loadChatHistoryUseCase: Get.find<LoadChatHistoryUseCase>(),
        sendTextMessageUseCase: Get.find<SendTextMessageUseCase>(),
        sendAttachmentUseCase: Get.find<SendAttachmentUseCase>(),
        markMessagesReadUseCase: Get.find<MarkMessagesReadUseCase>(),
      ),
    );

    Get.lazyPut(
      () => ChatController(
        session: Get.find<ChatSessionController>(),
        messaging: Get.find<ChatMessageController>(),
      ),
    );
  }
}
