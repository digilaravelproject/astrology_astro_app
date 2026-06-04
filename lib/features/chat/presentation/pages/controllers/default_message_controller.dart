import 'package:get/get.dart';
import 'package:astro_astrologer/features/chat/data/models/default_message_model.dart';
import 'package:astro_astrologer/features/chat/domain/repositories/i_chat_repository.dart';

class DefaultMessageController extends GetxController {
  final IChatRepository _chatRepository;

  DefaultMessageController(this._chatRepository);

  final RxList<DefaultMessageModel> messages = <DefaultMessageModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      isLoading.value = true;
      final result = await _chatRepository.getAllDefaultMessages();
      messages.value = result.map((e) => DefaultMessageModel.fromJson(e)).toList();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addMessage(String title, String content, bool isDefault) async {
    try {
      isLoading.value = true;
      final result = await _chatRepository.createDefaultMessage(
        title: title,
        content: content,
        isDefault: isDefault,
      );
      if (isDefault) {
        for (var msg in messages) {
          msg.isDefault = false;
        }
      }
      messages.add(DefaultMessageModel.fromJson(result));
      messages.refresh();
      Get.snackbar('Success', 'Message added successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateMessage(int id, String title, String content, bool isDefault) async {
    try {
      isLoading.value = true;
      final result = await _chatRepository.updateDefaultMessage(
        id: id,
        title: title,
        content: content,
        isDefault: isDefault,
      );
      if (isDefault) {
        for (var msg in messages) {
          msg.isDefault = false;
        }
      }
      final index = messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        messages[index] = DefaultMessageModel.fromJson(result);
        messages.refresh();
      }
      Get.snackbar('Success', 'Message updated successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setActiveDefault(int id) async {
    try {
      isLoading.value = true;
      final success = await _chatRepository.setDefaultMessageActive(id);
      if (success) {
        for (var msg in messages) {
          msg.isDefault = (msg.id == id);
        }
        messages.refresh();
        Get.snackbar('Success', 'Active default message updated');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleDefaultStatus(DefaultMessageModel msg) async {
    if (msg.isDefault == true) {
      // Toggle off: use update API to set is_default to false
      await updateMessage(msg.id!, msg.title ?? "", msg.content ?? "", false);
    } else {
      // Toggle on: use set-default API
      await setActiveDefault(msg.id!);
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      isLoading.value = true;
      final success = await _chatRepository.deleteDefaultMessage(id);
      if (success) {
        messages.removeWhere((m) => m.id == id);
        Get.snackbar('Success', 'Message deleted successfully');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
