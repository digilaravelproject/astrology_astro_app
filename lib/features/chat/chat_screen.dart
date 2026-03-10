import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_app_bar.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> request;

  const ChatScreen({
    super.key,
    required this.request,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Dummy initial messages
    _messages.add({
      'text': 'Namaste! How can I help you today?',
      'isMe': true, // Astrologer starts the conversation usuallly or responds
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
      'status': 'seen', // sent, delivered, seen
    });
     _messages.add({
      'text': 'I need guidance regarding my career.',
      'isMe': false,
      'time': DateTime.now().subtract(const Duration(minutes: 4)),
      'status': 'seen', 
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({
        'text': _messageController.text,
        'isMe': true,
        'time': DateTime.now(),
        'status': 'sent',
      });
    });
    _messageController.clear();
    
    // Simulate reply & status updates
    Future.delayed(const Duration(seconds: 1), () {
       if (mounted && _messages.isNotEmpty && _messages.last['isMe'] == true) {
        setState(() {
          _messages.last['status'] = 'delivered';
        });
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
           if (_messages.isNotEmpty && _messages.last['isMe'] == true) {
             _messages.last['status'] = 'seen';
           }
          _messages.add({
            'text': 'Please share your birth details.',
            'isMe': false,
            'time': DateTime.now(),
            'status': 'seen',
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        title: widget.request['user'], // Using user name from request
        centerTitle: false,

      ),
      body: Column(
        children: [
          // Timer / Status Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.lightPink.withOpacity(0.3),
            child: Center(
              child: AppText(
                "Chat in progress • 05:30 mins",
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.deepPink,
              ),
            ),
          ),
          
          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true, // Show latest messages at bottom
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // Reverse index for display
                final message = _messages[_messages.length - 1 - index];
                final isMe = message['isMe'] as bool;
                final status = message['status'] as String? ?? 'sent';
                
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(maxWidth: Get.width * 0.75),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.deepPink : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (message['image'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(message['image']),
                              height: 150,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        else if (message['text'].toString().startsWith('📄'))
                           Container(
                             padding: const EdgeInsets.all(8),
                             decoration: BoxDecoration(
                               color: Colors.white.withOpacity(0.2),
                               borderRadius: BorderRadius.circular(8),
                             ),
                             child: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 const Icon(Iconsax.document, color: Colors.white, size: 24),
                                 const SizedBox(width: 8),
                                 Flexible(
                                   child: AppText(
                                     message['text'].toString().replaceFirst('📄 ', ''),
                                     fontSize: 14,
                                     color: isMe ? Colors.white : Colors.black87,
                                     maxLines: 1,
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                 ),
                               ],
                             ),
                           )
                        else
                        AppText(
                          message['text'],
                          fontSize: 14,
                          color: isMe ? Colors.white : Colors.black87,
                          height: 1.4,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              "${message['time'].hour}:${message['time'].minute}",
                              fontSize: 10,
                              color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey,
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              Icon(
                                status == 'sent'
                                    ? Icons.check
                                    : Icons.done_all,
                                size: 16,
                                color: status == 'seen' 
                                    ? Colors.blue.shade100 // Blue tint for seen on dark background
                                    : Colors.white.withOpacity(0.7),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
                    onPressed: _showAttachmentBottomSheet,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.deepPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.send_1_copy, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
         // Simulate sending an image
        _messages.add({
          'text': '📷 Image sent',
          'image': image.path, // Store path to display if needed
          'isMe': true,
          'time': DateTime.now(),
          'status': 'sent',
        });
      });
      // Simulate delievery/seen
       _simulateMessageStatusUpdates();
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        // Simulate sending a file
        _messages.add({
          'text': '📄 ${result.files.single.name}',
          'isMe': true,
          'time': DateTime.now(),
          'status': 'sent',
        });
      });
       _simulateMessageStatusUpdates();
    }
  }

 void _simulateMessageStatusUpdates() {
     Future.delayed(const Duration(seconds: 1), () {
       if (mounted && _messages.isNotEmpty && _messages.last['isMe'] == true) {
        setState(() {
          _messages.last['status'] = 'delivered';
        });
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _messages.isNotEmpty && _messages.last['isMe'] == true) {
        setState(() {
             _messages.last['status'] = 'seen';
        });
      }
    });
 }

  void _showAttachmentBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Iconsax.camera,
                  color: Colors.blue,
                  label: "Camera",
                  onTap: () {
                    Get.back();
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildAttachmentOption(
                  icon: Iconsax.gallery,
                  color: Colors.purple,
                  label: "Gallery",
                  onTap: () {
                    Get.back();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _buildAttachmentOption(
                  icon: Iconsax.document,
                  color: Colors.orange,
                  label: "Document",
                  onTap: () {
                    Get.back();
                    _pickDocument();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          AppText(
            label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }
}
