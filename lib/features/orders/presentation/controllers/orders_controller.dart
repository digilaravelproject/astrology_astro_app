import 'package:get/get.dart';
import 'package:astro_astrologer/core/services/network/api_client.dart';
import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/network/websocket_service.dart';
import 'package:astro_astrologer/features/chat/presentation/pages/chat_screen.dart';
import 'package:astro_astrologer/features/chat/presentation/bindings/chat_binding.dart';
import 'package:astro_astrologer/features/call/presentation/controllers/call_controller.dart';
import 'package:astro_astrologer/features/call/presentation/pages/call_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../domain/models/astrologer_order_model.dart';
import '../../domain/usecases/get_astrologer_orders_usecase.dart';
import 'package:astro_astrologer/core/utils/custom_snackbar.dart';

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
  StreamSubscription? _callInitiatedSub;
  Worker? _callDismissedWorker;
  Worker? _callEndedWorker;

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

    // Auto-refresh call orders when a call is initiated, dismissed, or ended
    _callInitiatedSub = WebSocketService.callInitiatedEvent.stream.listen((_) {
      fetchCallOrders(isRefresh: true);
    });

    _callDismissedWorker = ever(WebSocketService.callDismissedSessionId, (_) {
      fetchCallOrders(isRefresh: true);
    });

    _callEndedWorker = ever(WebSocketService.callEndedSessionId, (_) {
      fetchCallOrders(isRefresh: true);
    });
  }

  @override
  void onClose() {
    _chatInitiatedSub?.cancel();
    _chatDismissedSub?.cancel();
    _chatQueueUpdatedSub?.cancel();
    _callInitiatedSub?.cancel();
    _callDismissedWorker?.dispose();
    _callEndedWorker?.dispose();
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
        status: 'waiting',
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
        status: 'waiting',
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

  // ─── CHAT ORDER ACTIONS ────────────────────────────────────────────────────

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
        CustomSnackBar.disabledSnackbar('Error', response.message);
      }
    } catch (e) {
      debugPrint('Accept chat error: $e');
      CustomSnackBar.disabledSnackbar('Error', 'Failed to accept chat request: $e');
    }
  }

  Future<void> rejectChatOrder(AstrologerOrderModel order) async {
    try {
      await _apiClient.post(AppUrls.rejectChatSession(order.sessionId));
      // Remove from list or refresh
      fetchChatOrders(isRefresh: true);
    } catch (e) {
      debugPrint('Reject chat error: $e');
      CustomSnackBar.disabledSnackbar('Error', 'Failed to reject chat request: $e');
    }
  }

  // ─── CALL ORDER ACTIONS ────────────────────────────────────────────────────

  /// Accept an incoming CALL order from the Orders screen.
  /// Works exactly like IncomingCallDialog Accept:
  ///  1. Use incomingOfferSdp from WebSocket if available
  ///  2. Fetch SDP from /call/current-session
  ///  3. Fall back to acceptCallDirect() if no SDP found
  Future<void> acceptCallOrder(AstrologerOrderModel order) async {
    try {
      // Remove from list immediately for UX
      callOrders.removeWhere((e) => e.sessionId == order.sessionId);

      if (Get.isRegistered<CallController>()) {
        final callController = Get.find<CallController>();

        // Set up CallController with caller details
        callController.sessionId = order.sessionId;
        callController.consumerId = order.userId;
        callController.consumerName = order.userName;
        callController.consumerImage = order.userProfileImage;

        // ── Step 1: Use SDP from WebSocket event if already received ──
        String? offerSdp = callController.incomingOfferSdp;

        // ── Step 2: Try fetching SDP from /call/current-session ──
        if (offerSdp == null || offerSdp.isEmpty) {
          debugPrint('[Orders] No incomingOfferSdp — fetching from current-session...');
          offerSdp = await callController.fetchOfferSdpFromCurrentSession();
        }

        bool success;
        if (offerSdp != null && offerSdp.isNotEmpty) {
          // ── Same path as IncomingCallDialog Accept ──
          debugPrint('[Orders] SDP found (length: ${offerSdp.length}). Using acceptCall()...');
          success = await callController.acceptCall(offerSdp);
        } else {
          // ── Step 3: Fallback — no SDP available, generate our own offer ──
          debugPrint('[Orders] No SDP available. Using acceptCallDirect()...');
          success = await callController.acceptCallDirect();
        }

        if (success) {
          Get.to(() => const CallScreen());
        } else {
          CustomSnackBar.disabledSnackbar('Error', 'Failed to accept call. Please try again.',
              snackPosition: SnackPosition.TOP);
          fetchCallOrders(isRefresh: true);
        }
      } else {
        // CallController not registered — use direct API call
        await _directAcceptCall(order);
      }
    } catch (e) {
      debugPrint('Accept call order error: $e');
      CustomSnackBar.disabledSnackbar('Error', 'Failed to accept call: $e');
      fetchCallOrders(isRefresh: true);
    }
  }

  /// Fallback: directly call the accept API when CallController is unavailable.
  Future<void> _directAcceptCall(AstrologerOrderModel order) async {
    final response = await _apiClient.post(
      AppUrls.acceptCall(order.sessionId),
      handleError: true,
      showErrorScreen: false,
    );
    if (response.isSuccess) {
      CustomSnackBar.disabledSnackbar('Call Accepted', 'Connecting to ${order.userName}...',
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade800,
          snackPosition: SnackPosition.TOP);
      Get.to(() => const CallScreen());
    } else {
      CustomSnackBar.disabledSnackbar('Error', 'Failed to accept call: ${response.message}');
      fetchCallOrders(isRefresh: true);
    }
  }

  /// Reject an incoming CALL order from the Orders screen.
  Future<void> rejectCallOrder(AstrologerOrderModel order) async {
    try {
      final response = await _apiClient.post(
        AppUrls.rejectCall(order.sessionId),
        handleError: true,
        showErrorScreen: false,
      );
      if (response.isSuccess) {
        // Remove from list and also clean up CallController if it was tracking this call
        callOrders.removeWhere((e) => e.sessionId == order.sessionId);
        if (Get.isRegistered<CallController>()) {
          final callController = Get.find<CallController>();
          if (callController.sessionId == order.sessionId) {
            callController.cleanUp();
          }
        }
        CustomSnackBar.disabledSnackbar(
          'Call Rejected',
          'You rejected the call from ${order.userName}.',
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade800,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      } else {
        CustomSnackBar.disabledSnackbar('Error', 'Failed to reject call: ${response.message}');
        fetchCallOrders(isRefresh: true);
      }
    } catch (e) {
      debugPrint('Reject call error: $e');
      CustomSnackBar.disabledSnackbar('Error', 'Failed to reject call: $e');
      fetchCallOrders(isRefresh: true);
    }
  }
}
