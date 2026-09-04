import 'package:astro_astrologer/core/constants/app_urls.dart';
import 'package:astro_astrologer/core/services/websocket/handlers/call_ws_handler.dart';
import 'package:astro_astrologer/core/services/websocket/handlers/chat_ws_handler.dart';
import 'package:astro_astrologer/core/services/websocket/handlers/live_ws_handler.dart';
import 'package:astro_astrologer/core/services/websocket/handlers/package_ws_handler.dart';

class WebSocketEventRouter {
  static void routeEvent(String event, dynamic data) {
    if (event == AppUrls.eventChatAccepted) {
      ChatWsHandler.handleChatAccepted(data);
    } else if (event == AppUrls.eventChatEnded) {
      ChatWsHandler.handleChatEnded(data);
    } else if (event == AppUrls.eventChatDismissed ||
        event == 'App\\Events\\ChatDismissed' ||
        event == '.ChatDismissed') {
      ChatWsHandler.handleChatDismissed(data);
    } else if (event == AppUrls.eventMessageSent ||
        event == 'App\\Events\\MessageSent') {
      ChatWsHandler.handleMessageSent(data);
    } else if (event == AppUrls.eventChatInitiated ||
        event == 'App\\Events\\ChatInitiated') {
      ChatWsHandler.handleChatInitiated(data);
    } else if (event == AppUrls.eventMessageStatusUpdated ||
        event == 'App\\Events\\MessageStatusUpdated') {
      ChatWsHandler.handleMessageStatusUpdated(data);
    } else if (event == AppUrls.eventChatQueueUpdated ||
        event == 'App\\Events\\ChatQueueUpdated') {
      ChatWsHandler.handleChatQueueUpdated(data);
    } else if (event == AppUrls.eventPresenceUpdated ||
        event == 'App\\Events\\PresenceUpdated') {
      ChatWsHandler.handlePresenceUpdated(data);
    } else if (event == AppUrls.eventCallInitiated ||
        event == 'App\\Events\\CallInitiated' ||
        event == '.CallInitiated') {
      CallWsHandler.handleCallInitiated(data);
    } else if (event == AppUrls.eventCallAccepted ||
        event == 'App\\Events\\CallAccepted') {
      CallWsHandler.handleCallAccepted(data);
    } else if (event == AppUrls.eventCallDismissed ||
        event == 'App\\Events\\CallDismissed') {
      CallWsHandler.handleCallDismissed(data);
    } else if (event == AppUrls.eventCallEnded ||
        event == 'App\\Events\\CallEnded') {
      CallWsHandler.handleCallEnded(data);
    } else if (event == AppUrls.eventIceCandidateSent ||
        event == 'App\\Events\\IceCandidateSent') {
      CallWsHandler.handleIceCandidateSent(data);
    } else if (event == AppUrls.eventWebRtcSdpUpdated ||
        event == 'App\\Events\\WebRtcSdpUpdated') {
      CallWsHandler.handleWebRtcSdpUpdated(data);
    } else if (event == AppUrls.eventViewerCountUpdated ||
        event == 'App\\Events\\${AppUrls.eventViewerCountUpdated}' ||
        event == '.${AppUrls.eventViewerCountUpdated}') {
      LiveWsHandler.handleViewerCountUpdated(data);
    } else if (event == AppUrls.eventNewLiveComment ||
        event == 'App\\Events\\${AppUrls.eventNewLiveComment}' ||
        event == '.${AppUrls.eventNewLiveComment}') {
      LiveWsHandler.handleNewLiveComment(data);
    } else if (event == AppUrls.eventSuperChatReceived ||
        event == 'App\\Events\\${AppUrls.eventSuperChatReceived}' ||
        event == '.${AppUrls.eventSuperChatReceived}') {
      LiveWsHandler.handleSuperChatReceived(data);
    } else if (event == AppUrls.eventActiveLiveSessionsUpdated ||
        event == 'App\\Events\\${AppUrls.eventActiveLiveSessionsUpdated}') {
      LiveWsHandler.handleActiveLiveSessionsUpdated(data);
    } else if (event == AppUrls.eventUserJoinedLiveSession ||
        event == 'App\\Events\\${AppUrls.eventUserJoinedLiveSession}' ||
        event == '.${AppUrls.eventUserJoinedLiveSession}') {
      LiveWsHandler.handleUserJoinedLiveSession(data);
    } else if (event == AppUrls.eventUserLeftLiveSession ||
        event == 'App\\Events\\${AppUrls.eventUserLeftLiveSession}' ||
        event == '.${AppUrls.eventUserLeftLiveSession}') {
      LiveWsHandler.handleUserLeftLiveSession(data);
    } else if (event == AppUrls.eventChatAssistanceMessageSent ||
        event == 'App\\Events\\ChatAssistanceMessageSent') {
      ChatWsHandler.handleMessageSent(data);
    } else if (event == AppUrls.eventChatAssistanceMessageStatusUpdated ||
        event == 'App\\Events\\ChatAssistanceMessageStatusUpdated') {
      ChatWsHandler.handleMessageStatusUpdated(data);
    } else if (event == AppUrls.eventChatAssistanceInitiated ||
        event == 'App\\Events\\ChatAssistanceInitiated') {
      ChatWsHandler.handleChatAssistanceInitiated(data);
    } else if (event == AppUrls.eventChatAssistanceLimitReached ||
        event == 'App\\Events\\ChatAssistanceLimitReached') {
      ChatWsHandler.handleChatAssistanceLimitReached(data);
    } else if (event == 'PackageSubSessionStarted' ||
        event == 'App\\Events\\PackageSubSessionStarted') {
      PackageWsHandler.handlePackageSubSessionStarted(data);
    } else if (event == 'PackageSubSessionEnded' ||
        event == 'App\\Events\\PackageSubSessionEnded') {
      PackageWsHandler.handlePackageSubSessionEnded(data);
    } else if (event == AppUrls.eventPackageSessionStateUpdated ||
        event == 'App\\Events\\${AppUrls.eventPackageSessionStateUpdated}') {
      PackageWsHandler.handlePackageSessionStateUpdated(data);
    } else if (event == 'PackageSessionTerminated' ||
        event == 'App\\Events\\PackageSessionTerminated') {
      PackageWsHandler.handlePackageSessionTerminated(data);
    }
  }
}
