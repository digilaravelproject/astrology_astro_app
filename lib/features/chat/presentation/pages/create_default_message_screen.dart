import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/core/widgets/custom_button.dart';
import 'controllers/default_message_controller.dart';
import 'package:astro_astrologer/features/chat/data/models/default_message_model.dart';
import 'package:astro_astrologer/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';

class CreateDefaultMessageScreen extends StatefulWidget {
  const CreateDefaultMessageScreen({super.key});

  @override
  State<CreateDefaultMessageScreen> createState() =>
      _CreateDefaultMessageScreenState();
}

class _CreateDefaultMessageScreenState
    extends State<CreateDefaultMessageScreen> {
  final DefaultMessageController controller = Get.put(
    DefaultMessageController(Get.find<IChatRepository>()),
  );

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isDefaultChecked = false;

  void _showAddEditMessageSheet({DefaultMessageModel? messageToEdit}) {
    if (messageToEdit != null) {
      _titleController.text = messageToEdit.title ?? "";
      _messageController.text = messageToEdit.content ?? "";
      _isDefaultChecked = messageToEdit.isDefault ?? false;
    } else {
      _titleController.clear();
      _messageController.clear();
      _isDefaultChecked = false;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    messageToEdit != null
                        ? "Edit Default Message".tr
                        : "New Default Message".tr,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E1A47),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _titleController,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E1A47),
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter message title...".tr,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E1A47),
                      ),
                      decoration: InputDecoration(
                        hintText:
                            "Enter your predefined message here... You can use placeholders like {{user_name}}"
                                .tr,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: AppText("Set as Active Default".tr, fontSize: 14),
                    value: _isDefaultChecked,
                    onChanged: (bool? value) {
                      setModalState(() {
                        _isDefaultChecked = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => CustomButton(
                      text: "Save Message".tr,
                      isLoading: controller.isLoading.value,
                      onPressed: () async {
                        if (_titleController.text.trim().isEmpty ||
                            _messageController.text.trim().isEmpty) {
                          CustomSnackBar.disabledSnackbar(
                            'Error',
                            'Please fill all fields',
                          );
                          return;
                        }

                        bool success = false;
                        if (messageToEdit != null) {
                          success = await controller.updateMessage(
                            messageToEdit.id!,
                            _titleController.text.trim(),
                            _messageController.text.trim(),
                            _isDefaultChecked,
                          );
                        } else {
                          success = await controller.addMessage(
                            _titleController.text.trim(),
                            _messageController.text.trim(),
                            _isDefaultChecked,
                          );
                        }
                        if (success) {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Default Messages'.tr),
      body: Obx(() {
        if (controller.isLoading.value && controller.messages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async {
            await controller.fetchMessages();
          },
          child:
              controller.messages.isEmpty
                  ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: _buildEmptyState(),
                    ),
                  )
                  : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    itemCount: controller.messages.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final msg = controller.messages[index];
                      return _buildMessageCard(msg);
                    },
                  ),
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: CustomButton(
          text: "+ Add New Message".tr,
          onPressed: () => _showAddEditMessageSheet(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.message_copy, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 24),
          AppText(
            "No Default Messages".tr,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E1A47),
          ),
          const SizedBox(height: 8),
          AppText(
            "Add quick responses to save time during chat.".tr,
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(DefaultMessageModel msg) {
    final isDefault = msg.isDefault ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDefault ? AppColors.primaryColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDefault
                  ? AppColors.primaryColor.withOpacity(0.5)
                  : Colors.grey.shade200,
          width: isDefault ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        msg.title ?? "",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    if (isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppText(
                          "Active".tr,
                          fontSize: 10,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                AppText(
                  msg.content ?? "",
                  fontSize: 14,
                  color: Colors.black87.withOpacity(0.8),
                  height: 1.4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  controller.toggleDefaultStatus(msg);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Icon(
                    isDefault ? Icons.star : Icons.star_border,
                    color: isDefault ? Colors.orange : Colors.grey.shade400,
                    size: 24,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showAddEditMessageSheet(messageToEdit: msg),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                  child: Icon(
                    Icons.edit,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                ),
              ),
              if (!isDefault)
                GestureDetector(
                  onTap: () => _confirmDelete(msg.id!),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Icon(
                      Icons.delete_outline,
                      color: Color(0xFFE57373),
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Message'.tr),
        content: Text(
          'Are you sure you want to delete this default message?'.tr,
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              if (context.mounted) Navigator.of(context).pop();
              controller.deleteMessage(id);
            },
            child: Text('Delete'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
