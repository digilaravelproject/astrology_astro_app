import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:astro_astrologer/core/theme/app_colors.dart';
import 'package:astro_astrologer/core/widgets/app_text.dart';
import 'package:astro_astrologer/core/widgets/custom_app_bar.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/floating_chat_bubble.dart';
import 'package:astro_astrologer/core/services/network/websocket_service.dart';
import 'package:astro_astrologer/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astro_astrologer/features/chat/domain/entities/chat_message.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/features/kundli/kundli_screen.dart';
import 'package:astro_astrologer/features/kundli/create_kundli_screen.dart';
import 'package:astro_astrologer/features/kundli/kundli_list_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/bindings/chat_binding.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:astro_astrologer/features/chat/presentation/widgets/incoming_chat_dialog.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String userImage;
  final int sessionId;
  final String initialStatus;
  final String? startedAtString;
  final String? gender;
  final String? dob;
  final String? tob;
  final String? place;
  final double? latitude;
  final double? longitude;

  const ChatScreen({
    super.key,
    required this.userName,
    required this.userImage,
    required this.sessionId,
    required this.initialStatus,
    this.startedAtString,
    this.gender,
    this.dob,
    this.tob,
    this.place,
    this.latitude,
    this.longitude,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late final ChatController _controller;
  late AnimationController _pulseController;
  late AnimationController _dotController;
  late Animation<double> _pulse1;
  late Animation<double> _pulse2;
  late Animation<double> _pulse3;

  @override
  void initState() {
    super.initState();
    // Retrieve or instantiate controller safely
    if (!Get.isRegistered<ChatController>()) {
      ChatBinding().dependencies();
    }
    _controller = Get.find<ChatController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If the session is still in 'initiated' state, show IncomingChatDialog
      // instead of the ChatScreen so astrologer can Accept/Reject.
      if (widget.initialStatus == 'initiated') {
        Get.back(); // Close this ChatScreen
        Future.delayed(const Duration(milliseconds: 100), () {
          if (Get.isBottomSheetOpen == true) return;
          Get.bottomSheet(
            IncomingChatDialog(
              sessionData: {'id': widget.sessionId, 'status': 'initiated'},
              senderData: {
                'name': widget.userName,
                'profile_photo': widget.userImage,
                'gender': widget.gender ?? '',
                'date_of_birth': widget.dob ?? '',
                'time_of_birth': widget.tob ?? '',
                'place_of_birth': widget.place ?? '',
              },
            ),
            isDismissible: false,
            enableDrag: false,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          );
        });
        return;
      }

      _controller.initSession(
        sessionId: widget.sessionId,
        currentUserId: 0,
        initialStatus: widget.initialStatus,
        userName: widget.userName,
        startedAtString: widget.startedAtString,
      );
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _pulse1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _pulse2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );
    _pulse3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  Future<void> _openKundli(BuildContext context) async {
    String name = widget.userName;
    String gender = widget.gender ?? '';
    String dob = widget.dob ?? '';
    String tob = widget.tob ?? '';
    String place = widget.place ?? '';
    double lat = widget.latitude ?? 0.0;
    double lng = widget.longitude ?? 0.0;

    // 1. Check messages loaded in ChatController for system message with birth details
    if (dob.isEmpty) {
      for (final msg in _controller.messages) {
        final content = msg.text;
        if (content.contains('Birth Details:') || content.contains('Date of Birth:')) {
          final lines = content.split('\n');
          for (final line in lines) {
            final trimmed = line.trim().replaceAll(RegExp(r'^-\s*'), '');
            final lower = trimmed.toLowerCase();
            if (lower.startsWith('name:')) {
              name = trimmed.substring(5).trim();
            } else if (lower.startsWith('date of birth:')) {
              dob = trimmed.substring(14).trim();
            } else if (lower.startsWith('time of birth:')) {
              tob = trimmed.substring(14).trim();
            } else if (lower.startsWith('place of birth:')) {
              place = trimmed.substring(15).trim();
            } else if (lower.startsWith('gender:')) {
              gender = trimmed.substring(7).trim();
            }
          }
          if (dob.isNotEmpty) break;
        }
      }
    }

    // 2. Fetch session consumer info from API if dob or coordinates are missing
    if (dob.isEmpty || lat == 0.0 || lng == 0.0) {
      try {
        final apiClient = ApiClient();
        final response = await apiClient.get('/chat/sessions/astrologer');
        if (response.isSuccess && response.body != null) {
          final dataList = response.body['data']?['data'] as List?;
          if (dataList != null) {
            for (final item in dataList) {
              if (item['id'] == widget.sessionId && item['consumer'] != null) {
                final consumer = item['consumer'];
                if (name.isEmpty) name = consumer['name'] ?? name;
                if (gender.isEmpty) gender = consumer['gender'] ?? gender;
                if (place.isEmpty) place = consumer['place_of_birth'] ?? place;
                
                final apiLat = double.tryParse(consumer['latitude']?.toString() ?? '');
                final apiLng = double.tryParse(consumer['longitude']?.toString() ?? '');
                if (apiLat != null && apiLat != 0.0) lat = apiLat;
                if (apiLng != null && apiLng != 0.0) lng = apiLng;

                if (dob.isEmpty && consumer['date_of_birth'] != null) {
                  try {
                    final parsedDate = DateTime.parse(consumer['date_of_birth']).toLocal();
                    dob = "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
                  } catch (_) {
                    dob = consumer['date_of_birth'].toString().split('T')[0];
                  }
                }
                if (tob.isEmpty && consumer['time_of_birth'] != null && consumer['time_of_birth'].toString().isNotEmpty) {
                  tob = consumer['time_of_birth'].toString();
                  if (tob.length == 5) tob += ":00";
                }
                break;
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[ChatScreen] error fetching session for kundli: $e');
      }
    }

    if (tob.length == 5) tob += ":00";

    if (dob.isNotEmpty) {
      Get.to(() => KundliScreen(
        fullName: name,
        gender: gender,
        dob: dob,
        tob: tob.isNotEmpty ? tob : '00:00:00',
        place: place,
        latitude: lat,
        longitude: lng,
      ));
    } else {
      Get.to(() => CreateKundliScreen(
        initialKundliData: {
          'name': name,
          'gender': gender,
          'place': place,
        },
      ));
    }
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_controller.status.value == 'ongoing' || _controller.status.value == 'initiated') {
          _controller.minimizeToBubble(
            context,
            widget.userName,
            widget.userImage,
            shouldPop: false,
          );
          return true;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: CustomAppBar(
          title: '', // Not used since titleWidget is provided
          titleWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.deepPink.withOpacity(0.1),
                backgroundImage: (widget.userImage.isNotEmpty)
                    ? NetworkImage(widget.userImage.startsWith('http') 
                        ? widget.userImage 
                        : '${AppUrls.baseImageUrl}${widget.userImage}')
                    : null,
                child: widget.userImage.isEmpty
                    ? AppText(
                        widget.userName.isNotEmpty ? widget.userName.substring(0, 1).toUpperCase() : 'U',
                        color: AppColors.deepPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: AppText(
                  widget.userName,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E1A47),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          centerTitle: false,
          showLeading: true,
          onLeadingPressed: () {
            if (_controller.status.value == 'ongoing' || _controller.status.value == 'initiated') {
              _controller.minimizeToBubble(
                context,
                widget.userName,
                widget.userImage,
                shouldPop: true,
              );
            } else {
              Navigator.of(context).pop();
            }
          },
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => Get.to(() => const KundliListScreen()),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryColor.withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14, color: AppColors.primaryColor),
                        SizedBox(width: 4),
                        AppText(
                          'Kundli',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Obx(() {
              if (_controller.status.value == 'ongoing') {
                return Padding(
                  padding: const EdgeInsets.only(right: 16), // Adjusted right margin to 16
                  child: InkWell(
                    onTap: () => _showEndChatConfirmation(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: const AppText(
                        "End Chat",
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
              opacity: 0.12,
            ),
          ),
          child: Column(
            children: [
            // Timer / Status Bar
            Obx(() {
              final seconds = _controller.elapsedSeconds.value;
              final status = _controller.status.value.toLowerCase();
              final isEnded = status == 'ended' || status == 'completed' || status == 'cancelled' || status == 'rejected';
              final isInitiated = status == 'initiated';

              if (isInitiated) return const SizedBox.shrink();

              String statusText = "Chat has ended";
              if (status == 'ongoing') {
                statusText = "Chat in progress • ${_formatDuration(seconds)}";
              } else if (status == 'cancelled') {
                statusText = "Chat Cancelled";
              } else if (status == 'rejected') {
                statusText = "Chat Rejected";
              } else if (status == 'completed') {
                statusText = "Chat Completed";
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: isEnded ? Colors.grey.shade300 : AppColors.lightPink.withOpacity(0.3),
                child: Center(
                  child: AppText(
                    statusText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isEnded ? Colors.black54 : AppColors.deepPink,
                  ),
                ),
              );
            }),

            // Messages List
            Expanded(
              child: Obx(() {
                final isInitiated = _controller.status.value == 'initiated';
                if (isInitiated) {
                  return _buildRingingScreen();
                }

                if (_controller.isLoading.value && _controller.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  controller: _controller.scrollController,
                  padding: const EdgeInsets.all(16),
                  reverse: true, // Show latest messages at bottom
                  itemCount: _controller.messages.length,
                  itemBuilder: (context, index) {
                    // Reverse index for display
                    final message = _controller.messages[_controller.messages.length - 1 - index];
                    final isMe = message.isMe;
                    final status = message.status;

                    bool isReply = false;
                    String replyUser = '';
                    String replyText = '';
                    String mainText = message.text;
                    
                    if (message.replyTo != null) {
                      isReply = true;
                      replyUser = message.replyTo!.isMe ? 'You' : widget.userName;
                      replyText = message.replyTo!.text;
                    } else if (mainText.startsWith('>>reply>>')) {
                      // Fallback for old cached messages
                      isReply = true;
                      final endQuote = mainText.indexOf('<<reply<<');
                      if (endQuote != -1) {
                        final quotePart = mainText.substring(9, endQuote);
                        final colonIdx = quotePart.indexOf(': ');
                        if (colonIdx != -1) {
                          replyUser = quotePart.substring(0, colonIdx);
                          replyText = quotePart.substring(colonIdx + 2);
                        } else {
                          replyText = quotePart;
                        }
                        mainText = mainText.substring(endQuote + 9).trimLeft();
                      } else {
                        final quotePartWithText = mainText.substring(9);
                        final newlineIdx = quotePartWithText.indexOf('\n');
                        String quotePart;
                        if (newlineIdx != -1) {
                          quotePart = quotePartWithText.substring(0, newlineIdx);
                          mainText = quotePartWithText.substring(newlineIdx).trimLeft();
                        } else {
                          quotePart = quotePartWithText;
                          mainText = '';
                        }
                        
                        final colonIdx = quotePart.indexOf(': ');
                        if (colonIdx != -1) {
                          replyUser = quotePart.substring(0, colonIdx);
                          replyText = quotePart.substring(colonIdx + 2);
                        } else {
                          replyUser = 'User';
                          replyText = quotePart;
                        }
                      }
                    }

                    return SwipeTo(
                      onRightSwipe: (details) {
                        _controller.setReply(message);
                      },
                      onLeftSwipe: (details) {
                        _controller.setReply(message);
                      },
                      child: Align(
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
                              if (isReply)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border(left: BorderSide(color: isMe ? Colors.white : AppColors.deepPink, width: 4)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppText(replyUser, color: isMe ? Colors.white : AppColors.deepPink, fontWeight: FontWeight.bold, fontSize: 12),
                                      const SizedBox(height: 4),
                                      AppText(replyText, color: isMe ? Colors.white70 : Colors.black87, fontSize: 12, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                            if (message.type == 'image')
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: message.image != null && message.image!.startsWith('http')
                                    ? Image.network(
                                        message.image!,
                                        height: 150,
                                        width: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : (message.image != null && File(message.image!).existsSync()
                                        ? Image.file(
                                            File(message.image!),
                                            height: 150,
                                            width: 200,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            message.attachmentUrl != null && message.attachmentUrl!.startsWith('http')
                                                ? message.attachmentUrl!
                                                : '${AppUrls.baseImageUrl}${message.attachmentUrl ?? ""}',
                                            height: 150,
                                            width: 200,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) => Container(
                                              height: 150,
                                              width: 200,
                                              color: Colors.grey,
                                              child: const Icon(Icons.broken_image, color: Colors.white),
                                            ),
                                          )),
                              )
                            else if (message.type == 'document')
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Iconsax.document, color: Colors.black54, size: 24),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: AppText(
                                        mainText.replaceFirst('📄 ', ''),
                                        fontSize: 14,
                                        color: Colors.black87,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (mainText.isNotEmpty)
                              AppText(
                                mainText,
                                fontSize: 14,
                                color: isMe ? Colors.white : Colors.black87,
                                height: 1.4,
                              ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppText(
                                  "${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')} ${message.time.hour >= 12 ? 'pm' : 'am'}",
                                  fontSize: 10,
                                  color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey,
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    status == 'sending...'
                                        ? Icons.access_time
                                        : status == 'sent'
                                            ? Icons.check
                                            : Icons.done_all,
                                    size: 16,
                                    color: (status == 'seen' || status == 'read')
                                        ? Colors.blueAccent
                                        : Colors.white.withOpacity(0.7),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ));
                  },
                );
              }),
            ),

            // Input Area
            Obx(() {
              final status = _controller.status.value.toLowerCase();
              final isEnded = status == 'ended' || status == 'completed' || status == 'cancelled' || status == 'rejected';
              final isInitiated = status == 'initiated';
              if (isEnded || isInitiated) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_controller.replyingToMessage.value != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: const Border(left: BorderSide(color: AppColors.deepPink, width: 4)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      _controller.replyingToMessage.value!.isMe ? 'You' : widget.userName,
                                      color: AppColors.deepPink,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    const SizedBox(height: 4),
                                    AppText(
                                      _controller.replyingToMessage.value!.text.replaceAll('\n', ' '),
                                      color: Colors.black87,
                                      fontSize: 12,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                                onPressed: () => _controller.cancelReply(),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
                        onPressed: _showAttachmentBottomSheet,
                      ),
                      IconButton(
                        icon: const Icon(Icons.auto_awesome, color: AppColors.primaryColor),
                        tooltip: "Kundli",
                        onPressed: () => _openKundli(context),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller.messageController,
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
                        onTap: () => _controller.sendTextMessage(),
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
                ],
              ),
            ),
          );
          }),
        ],
        ),
        ),
      ),
    );
  }

  Widget _buildRingingScreen() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.deepPink.withOpacity(0.15),
              ),
              clipBehavior: Clip.hardEdge,
              child: widget.userImage.isNotEmpty
                  ? Image.network(
                      widget.userImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            widget.userName.isNotEmpty
                                ? widget.userName.substring(0, 1).toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepPink,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        widget.userName.isNotEmpty
                            ? widget.userName.substring(0, 1).toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepPink,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 28),

            // Astrologer name
            Text(
              widget.userName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Astrologer',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 20),

            // Animated "Ringing..." dots
            AnimatedBuilder(
              animation: _dotController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Waiting for acceptance',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.deepPink,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 2),
                    _buildDot(0),
                    _buildDot(1),
                    _buildDot(2),
                  ],
                );
              },
            ),

            const SizedBox(height: 56),

            // End Call button
            GestureDetector(
              onTap: () => _showEndChatConfirmation(context),
              child: const Icon(Icons.call_end_rounded, color: Colors.red, size: 48),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final progress = _dotController.value;
    final delay = index * 0.25;
    final adjustedProgress = ((progress - delay) % 1.0 + 1.0) % 1.0;
    final opacity = adjustedProgress < 0.5
        ? adjustedProgress * 2
        : 1.0 - ((adjustedProgress - 0.5) * 2);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Opacity(
        opacity: opacity.clamp(0.2, 1.0),
        child: Text(
          '.',
          style: TextStyle(
            fontSize: 22,
            color: AppColors.deepPink,
            fontWeight: FontWeight.bold,
            height: 0.9,
          ),
        ),
      ),
    );
  }

  void _showEndChatConfirmation(BuildContext context) {
    if (_controller.isPackageChat && _controller.isCallAlsoActive) {
      _showGranularEndModal(context);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("End Chat"),
          content: const Text("Are you sure you want to end this chat session?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _controller.terminateEntireSession();
              },
              child: const Text("End Chat", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  void _showGranularEndModal(BuildContext context) {
    final rem = WebSocketService.packageRemainingSeconds.value;
    final m = (rem ~/ 60).toString().padLeft(2, '0');
    final s = (rem % 60).toString().padLeft(2, '0');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Title
            const Row(
              children: [
                Icon(Icons.help_outline_rounded, color: Color(0xFF6B21A8), size: 22),
                SizedBox(width: 8),
                Text(
                  'End Consultation Options',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Package time remaining: $m:$s',
                style: TextStyle(fontSize: 13, color: Colors.orange.shade700, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),

            // Option 1: End Chat Only
            _buildEndOption(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: Colors.blue.shade700,
              bgColor: Colors.blue.shade50,
              title: 'End Chat Only (Continue Calling)',
              subtitle: 'Closes chat window and returns you to the call.',
              onTap: () {
                Navigator.of(ctx).pop();
                _controller.terminateChannelOnly();
              },
            ),
            const SizedBox(height: 12),

            // Option 2: End Entire Session
            _buildEndOption(
              icon: Icons.cancel_rounded,
              iconColor: Colors.red,
              bgColor: Colors.red.shade50,
              title: 'End Entire Session',
              subtitle: 'Completes consultation and finalises package time.',
              onTap: () {
                Navigator.of(ctx).pop();
                _controller.terminateEntireSession();
              },
            ),
            const SizedBox(height: 12),

            // Option 3: Cancel
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndOption({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: iconColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }


  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      _controller.sendImageAttachment(image);
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      _controller.sendDocumentAttachment(result.files.single);
    }
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
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildAttachmentOption(
                  icon: Iconsax.gallery,
                  color: Colors.purple,
                  label: "Gallery",
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _buildAttachmentOption(
                  icon: Iconsax.document,
                  color: Colors.orange,
                  label: "Document",
                  onTap: () {
                    Navigator.of(context).pop();
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
