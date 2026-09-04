import 'package:astro_astrologer/core/services/config/env_config.dart';

class AppUrls {
  static String get baseUrl => "${EnvConfig.baseUrl}/api/v1";
  //static const String baseUrl = "https://darkgoldenrod-peafowl-305286.hostingersite.com/api/v1";
  static String get baseImageUrl => "${EnvConfig.baseUrl}/storage/";
  static String get webSocketUrl =>
      "${EnvConfig.baseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://')}/app/astrology-key?protocol=7&client=js&version=8.4.0-rc2&flash=false";
  static const String broadcastingAuth = "/broadcasting/auth";

  static const String sendOtp = "/astrologer/send-otp";
  static const String verifyOtp = "/astrologer/verify-otp";
  static const String astrologerSignup = "/astrologer/signup";
  static const String resendOtp = "/astrologer/resend-otp";
  static const String updateProfilePhoto = "/astrologer/profile/photo";
  static const String updateProfile = "/astrologer/profile";
  static const String logout = "/astrologer/logout";
  static const String performance = "/astrologer/performance";
  static const String deleteAccount = "/astrologer/delete-account";
  static const String sleepHours = "/astrologer/sleep-hours";
  static const String trainingVideos = "/astrologer/training-videos";
  static const String getNotices = "/user/notices";
  static const String getFollowers = "/astrologer/community/followers";
  static const String getFavorites = "/astrologer/community/favorites";
  static String blockUser(int id) => "/astrologer/users/$id/block";
  static String unblockUser(int id) => "/astrologer/users/$id/unblock";
  static const String blockedUsers = "/astrologer/blocked-users";
  static const String getAstroSkills = "/astrologer/profile/skills";
  static const String registerDeviceToken = "/astrologer/device-token";
  static const String removeDeviceToken = "/astrologer/remove-token";
  static String getNotificationCount(int userId) =>
      "/user/notifications/count?user_id=$userId";
  static String getNotifications(int userId, {int page = 1}) =>
      "/user/notifications?user_id=$userId&page=$page";
  static String markAllNotificationsRead(int userId) =>
      "/user/notifications/mark-all-read?user_id=$userId";
  static String deleteNotification(int id, int userId) =>
      "/user/notifications/$id?user_id=$userId";
  static String deleteAllNotifications(int userId) =>
      "/user/notifications/delete-all?user_id=$userId";
  static const String bankAccounts = "/astrologer/bank-accounts";
  static String setDefaultBankAccount(int id) =>
      "/astrologer/bank-accounts/$id/set-default";
  static const String availability = "/astrologer/availability";
  static const String phoneNumbers = "/astrologer/phone-numbers";
  static String verifyPhoneNumber(int id) =>
      "/astrologer/phone-numbers/$id/verify";
  static String setDefaultPhoneNumber(int id) =>
      "/astrologer/phone-numbers/$id/set-default";

  static String getNotificationDetail(int id, int userId) =>
      "/user/notifications/$id?user_id=$userId";
  static String markNotificationRead(int id, int userId) =>
      "/user/notifications/$id/mark-read?user_id=$userId";

  static const String faqs = '/faqs';
  static const String privacyPolicy = '/privacy-policy';
  static const String paymentPolicy = '/payment-policy';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String aboutUs = '/static-pages/about_us';
  static const String feedback = '/feedback';
  static const String customerSupport = '/static-pages/customer_support';

  static String toggleLike(int id) =>
      "/astrologer/community/followers/$id/toggle-like";
  static String getProfile(int id) => "/astrologer/profile/$id";
  static String trainingVideoDetail(int id) =>
      "/astrologer/training-videos/$id";
  static const String toggleOnline = "/astrologer/toggle-online";
  static const String updateOtherDetails = "/astrologer/profile/other-details";

  static const String packageSpawnChannel =
      '/astrologer/packages/session/spawn-channel';
  static const String packageTerminateChannel =
      '/astrologer/packages/session/terminate-channel';
  static const String packageHeartbeat =
      '/astrologer/packages/session/heartbeat';
  static const String packageActiveBanner =
      '/astrologer/packages/active-banner';

  // Gallery
  static const String uploadGallery = "/astrologer/gallery/upload";
  static const String galleryList = "/astrologer/gallery";
  static String toggleGalleryVisibility(int id) =>
      "/astrologer/gallery/$id/toggle-visibility";
  static String deleteGalleryImage(int id) => "/astrologer/gallery/$id";

  // Reviews
  static const String reviewList = "/user/reviews";
  static String replyReview(int id) => "/user/reviews/$id/reply";

  // Live Sessions
  static const String liveSessions = "/astrologer/live";
  static const String currentLiveSession = "/astrologer/live/current";
  static String deleteLiveSession(int id) => "/astrologer/live/$id";
  static String startLiveSession(int id) => "/astrologer/live/$id/start";
  static String stopLiveSession(int id) => "/astrologer/live/$id/stop";
  static String startBroadcast(int id) => "/astrologer/live/$id/broadcast";
  static String stopBroadcast(int id) => "/astrologer/live/$id/stop-broadcast";
  static String reportMediaStatus(int id) =>
      "/astrologer/live/$id/media-status";
  static String getLiveComments(int id) => "/astrologer/live/$id/comments";

  static String updateLiveSession(int id) => "/astrologer/live/$id";

  // Billing Address
  static const String billingAddress = "/astrologer/billing-address";

  // Astrology Blogs
  static const String blogs = "/user/blogs";
  static String blogDetails(int id) => "/user/blogs/$id";

  // Remedies
  static const String remedies = "/user/remedies";
  static String remedyDetails(int id) => "/user/remedies/$id";

  // Default Messages
  static const String defaultMessages = "/astrologer/default-messages";
  static const String activeDefaultMessage =
      "/astrologer/default-messages/active";
  static String defaultMessageUpdate(int id) =>
      "/astrologer/default-messages/$id";
  static String defaultMessageDelete(int id) =>
      "/astrologer/default-messages/$id";
  static String setDefaultMessageActive(int id) =>
      "/astrologer/default-messages/$id/set-default";

  // Chat
  static String loadChatHistory(int sessionId) => "/chat/$sessionId/messages";
  static String sendChatMessage(int sessionId) => "/chat/$sessionId/message";
  static String markMessagesAsRead(int sessionId) => "/chat/$sessionId/read";
  static String endChatSession(int sessionId) => "/chat/$sessionId/end";
  static String acceptChatSession(int sessionId) => "/chat/$sessionId/accept";
  static String rejectChatSession(int sessionId) => "/chat/$sessionId/reject";

  // Orders
  static const String astrologerOrders = "/astrologer/orders";

  // Wallet
  static const String walletSummary = "/astrologer/wallet";
  static const String walletWithdrawalConfig =
      "/astrologer/wallet/withdrawal-config";
  static const String walletEarnings = "/astrologer/wallet/earnings";
  static const String walletWithdrawals = "/astrologer/wallet/withdrawals";
  static const String walletWithdraw = "/astrologer/wallet/withdraw";
  static String downloadWithdrawalReceipt(int id) =>
      "/astrologer/wallet/withdrawals/$id/receipt";
  static const String walletWeeklyRankings =
      "/astrologer/wallet/weekly-rankings";
  static const String walletInvoices = "/astrologer/wallet/invoices";
  static String downloadInvoice(int year, int month) =>
      "/astrologer/wallet/invoices/$year/${month.toString().padLeft(2, '0')}/download";

  static const String getCurrentSession = "/chat/sessions/current";
  static String markChatRead(int sessionId) => "/chat/$sessionId/read";
  static String syncChatStatus(int sessionId) => "/chat/$sessionId/sync-status";
  static const String uploadAttachment = "/chat/upload-attachment";
  static String getChatMessages(int sessionId) => "/chat/$sessionId/messages";
  static const String astrologerChatSessions = "/chat/sessions/astrologer";

  // Saved Kundli Endpoints
  static const String createKundali = '/kundli/create';
  static const String getKundali = '/kundli';
  static String getKundaliById(int id) => '/kundli/$id';
  static String updateKundali(int id) => '/kundli/$id';
  static String deleteKundali(int id) => '/kundli/$id';

  // WebSocket / Pusher Events
  static const String pusherConnectionEstablished =
      'pusher:connection_established';
  static const String pusherSubscriptionSucceeded =
      'pusher_internal:subscription_succeeded';
  static const String pusherSubscribe = 'pusher:subscribe';
  static const String pusherPing = 'pusher:ping';
  static const String pusherPong = '{"event":"pusher:pong"}';

  // Chat System Events
  static const String eventChatInitiated = 'ChatInitiated';
  static const String eventChatQueueUpdated = 'ChatQueueUpdated';
  static const String eventChatAccepted = 'ChatAccepted';
  static const String eventChatEnded = 'ChatEnded';
  static const String eventPackageSubSessionStarted =
      'PackageSubSessionStarted';
  static const String eventPackageSubSessionEnded = 'PackageSubSessionEnded';
  static const String eventPackageSessionTerminated =
      'PackageSessionTerminated';
  static const String eventPackageSessionStateUpdated =
      'PackageSessionStateUpdated';
  static const String eventMessageSent = 'MessageSent';
  static const String eventMessageStatusUpdated = 'MessageStatusUpdated';
  static const String eventPresenceUpdated = 'PresenceUpdated';
  static const String eventChatDismissed = 'ChatDismissed';

  // Channel Names
  static String privateUserChannel(int userId) => 'private-user.$userId';
  static const String presenceRoomChannel = 'presence-room';

  // Call APIs
  static const String initiateCall = '/call/initiate';
  static String acceptCall(int sessionId) => '/call/$sessionId/accept';
  static String rejectCall(int sessionId) => '/call/$sessionId/reject';
  static String cancelCall(int sessionId) => '/call/$sessionId/cancel';
  static String endCallSession(int sessionId) => '/call/$sessionId/end';
  static String updateSdp(int sessionId) => '/call/$sessionId/sdp';
  static String sendIceCandidate(int sessionId) =>
      '/call/$sessionId/ice-candidate';
  static const String currentCallSession = '/call/current-session';
  static const String pendingCallSessions = '/call/pending';
  static const String userCallSessions = '/call/sessions/user';
  static const String astrologerCallSessions = '/call/sessions/astrologer';
  static const String turnCredentials = '/call/turn-credentials';

  // Call System Events
  static const String eventCallInitiated = 'CallInitiated';
  static const String eventCallAccepted = 'CallAccepted';
  static const String eventCallDismissed = 'CallDismissed';
  static const String eventCallEnded = 'CallEnded';
  static const String eventIceCandidateSent = 'IceCandidateSent';
  static const String eventWebRtcSdpUpdated = 'WebRtcSdpUpdated';

  // Live Session System Events
  static const String eventUserJoinedLiveSession = 'UserJoinedLiveSession';
  static const String eventUserLeftLiveSession = 'UserLeftLiveSession';
  static const String eventLiveSessionEnded = 'LiveSessionEnded';
  static const String eventAstrologerMediaStatusChanged =
      'AstrologerMediaStatusChanged';
  static const String eventLiveSessionStarted = 'LiveSessionStarted';
  static const String eventViewerCountUpdated = 'ViewerCountUpdated';
  static const String eventNewLiveComment = 'NewLiveComment';
  static const String eventSuperChatReceived = 'SuperChatReceived';
  static const String eventAstrologerBroadcastStarted =
      'AstrologerBroadcastStarted';

  // Chat Assistance API Endpoints
  static const String chatAssistanceSessions = '/chat-assistance/sessions';
  static String getChatAssistanceMessages(int sessionId) =>
      '/chat-assistance/$sessionId/messages';
  static String sendChatAssistanceMessage(int sessionId) =>
      '/chat-assistance/$sessionId/message';
  static String syncChatAssistanceStatus(int sessionId) =>
      '/chat-assistance/$sessionId/sync-status';
  static const String getAstrologerChatAssistanceStatus =
      '/chat-assistance/astrologer/limits-status';

  // Chat Assistance System Events
  static const String eventChatAssistanceInitiated = 'ChatAssistanceInitiated';
  static const String eventChatAssistanceMessageSent =
      'ChatAssistanceMessageSent';
  static const String eventChatAssistanceMessageStatusUpdated =
      'ChatAssistanceMessageStatusUpdated';
  static const String eventChatAssistanceLimitReached =
      'ChatAssistanceLimitReached';

  // Price Increase Request
  static const String priceIncreaseStatus = "/astrologer/price-increase/status";
  static const String priceIncreaseRequest =
      "/astrologer/price-increase/request";
  static const String priceIncreaseHistory =
      "/astrologer/price-increase/history";

  // Offers & Commissions
  static const String astrologerOffers = "/astrologer/offers";
  static String activateOffer(int id) => "/astrologer/offers/$id/activate";
  static const String offerHistory = "/astrologer/offers/history";
}
