import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/websocket_service.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/bindings/chat_binding.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../domain/models/astrologer_order_model.dart';
import '../../domain/usecases/get_astrologer_orders_usecase.dart';

class OrdersController extends GetxController {
  final GetAstrologerOrdersUseCase _getAstrologerOrdersUseCase;
  final ApiClient _apiClient;

  OrdersController({
    required GetAstrologerOrdersUseCase getAstrologerOrdersUseCase,
    required ApiClient apiClient,
  })  : _getAstrologerOrdersUseCase = getAstrologerOrdersUseCase,
        _apiClient = apiClient;

  final RxList<AstrologerOrderModel> chatOrders = <AstrologerOrderModel>[].obs;
  final RxList<AstrologerOrderModel> callOrders = <AstrologerOrderModel>[].obs;
  final RxBool isLoadingChat = false.obs;
  final RxBool isLoadingCall = false.obs;
  final RxString chatError = ''.obs;
  final RxString callError = ''.obs;

  int _currentChatPage = 1;
  bool _hasMoreChat = true;

  int _currentCallPage = 1;
  bool _hasMoreCall = true;

  StreamSubscription? _chatInitiatedSub;
  StreamSubscription? _chatDismissedSub;
  StreamSubscription? _chatQueueUpdatedSub;

  @override
  void onInit() {
    super.onInit();
    fetchChatOrders();
    fetchCallOrders();

    // Auto-refresh when a chat is initiated or dismissed
    _chatInitiatedSub = WebSocketService.chatInitiatedEvent.stream.listen((_) {
      fetchChatOrders(isRefresh: true);
    });

    _chatDismissedSub = WebSocketService.chatDismissedSessionId.listen((_) {
      fetchChatOrders(isRefresh: true);
    });

    _chatQueueUpdatedSub = WebSocketService.chatQueueUpdatedEvent.stream.listen((_) {
      fetchChatOrders(isRefresh: true);
    });
  }

  @override
  void onClose() {
    _chatInitiatedSub?.cancel();
    _chatDismissedSub?.cancel();
    _chatQueueUpdatedSub?.cancel();
    super.onClose();
  }

  Future<void> fetchChatOrders({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentChatPage = 1;
      _hasMoreChat = true;
      chatOrders.clear();
      chatError.value = '';
    }

    if (!_hasMoreChat || isLoadingChat.value) return;

    try {
      isLoadingChat.value = true;
      final response = await _getAstrologerOrdersUseCase.execute(
        type: 'chat',
        page: _currentChatPage,
      );
      
      if (response.isNotEmpty) {
        chatOrders.addAll(response);
        _currentChatPage++;
      } else {
        _hasMoreChat = false;
      }
    } catch (e) {
      chatError.value = e.toString();
    } finally {
      isLoadingChat.value = false;
    }
  }

  Future<void> fetchCallOrders({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentCallPage = 1;
      _hasMoreCall = true;
      callOrders.clear();
      callError.value = '';
    }

    if (!_hasMoreCall || isLoadingCall.value) return;

    try {
      isLoadingCall.value = true;
      final response = await _getAstrologerOrdersUseCase.execute(
        type: 'call',
        page: _currentCallPage,
      );
      
      if (response.isNotEmpty) {
        callOrders.addAll(response);
        _currentCallPage++;
      } else {
        _hasMoreCall = false;
      }
    } catch (e) {
      callError.value = e.toString();
    } finally {
      isLoadingCall.value = false;
    }
  }

  Future<void> acceptChatOrder(AstrologerOrderModel order) async {
    try {
      final response = await _apiClient.post(AppUrls.acceptChatSession(order.sessionId));
      if (response.isSuccess) {
        // Ensure we have a valid start time
        final startedAt = response.body?['data']?['session']?['started_at']?.toString() 
                       ?? DateTime.now().toUtc().toIso8601String();

        WebSocketService.sessionStartTimes[order.sessionId] = startedAt;

        // Optionally, remove it from the list or change status before navigating
        order = AstrologerOrderModel(
          sessionId: order.sessionId,
          orderId: order.orderId,
          userId: order.userId,
          userName: order.userName,
          userProfileImage: order.userProfileImage,
          requestType: order.requestType,
          status: 'ongoing',
          durationSeconds: order.durationSeconds,
          amount: order.amount,
          ratePerMinute: order.ratePerMinute,
          paymentStatus: order.paymentStatus,
        );
        final index = chatOrders.indexWhere((e) => e.sessionId == order.sessionId);
        if (index != -1) {
          chatOrders[index] = order;
        }

        Get.to(
          () => ChatScreen(
            userName: order.userName,
            userImage: order.userProfileImage ?? '',
            sessionId: order.sessionId,
            initialStatus: 'ongoing',
            startedAtString: startedAt,
          ),
          binding: ChatBinding(),
        );
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      debugPrint('Accept error: $e');
      Get.snackbar('Error', 'Failed to accept chat request: $e');
    }
  }

  Future<void> rejectChatOrder(AstrologerOrderModel order) async {
    try {
      await _apiClient.post(AppUrls.rejectChatSession(order.sessionId));
      // Remove from list or refresh
      fetchChatOrders(isRefresh: true);
    } catch (e) {
      debugPrint('Reject error: $e');
      Get.snackbar('Error', 'Failed to reject chat request: $e');
    }
  }
}
