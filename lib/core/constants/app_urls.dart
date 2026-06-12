class AppUrls {
  static const String baseUrl = "https://suryapathkundli.com/api/v1";
  //static const String baseUrl = "https://darkgoldenrod-peafowl-305286.hostingersite.com/api/v1";
  static const String baseImageUrl = "https://suryapathkundli.com/storage/";
  static const String webSocketUrl = "wss://suryapathkundli.com/app/astrology-key?protocol=7&client=js&version=8.4.0-rc2&flash=false";
  static const String broadcastingAuth = "/broadcasting/auth";

  static const String sendOtp = "/astrologer/send-otp";
  static const String verifyOtp = "/astrologer/verify-otp";
  static const String astrologerSignup = "/astrologer/signup";
  static const String resendOtp = "/astrologer/resend-otp";
  static const String updateProfilePhoto = "/astrologer/profile/photo";
  static const String updateProfile = "/astrologer/profile";
  static const String logout = "/astrologer/logout";
  static const String deleteAccount = "/astrologer/delete-account";
  static const String sleepHours = "/astrologer/sleep-hours";
  static const String trainingVideos = "/astrologer/training-videos";
  static const String getNotices = "/user/notices";
  static const String getFollowers = "/astrologer/community/followers";
  static const String getFavorites = "/astrologer/community/favorites";
  static const String getAstroSkills = "/astrologer/profile/skills";
  static String getNotificationCount(int userId) => "/user/notifications/count?user_id=$userId";
  static String getNotifications(int userId) => "/user/notifications?user_id=$userId";
  static const String bankAccounts = "/astrologer/bank-accounts";
  static String setDefaultBankAccount(int id) => "/astrologer/bank-accounts/$id/set-default";
  static const String availability = "/astrologer/availability";
  static const String phoneNumbers = "/astrologer/phone-numbers";
  static String verifyPhoneNumber(int id) => "/astrologer/phone-numbers/$id/verify";
  static String setDefaultPhoneNumber(int id) => "/astrologer/phone-numbers/$id/set-default";

  static String getNotificationDetail(int id, int userId) => "/user/notifications/$id?user_id=$userId";
  static String markNotificationRead(int id, int userId) => "/user/notifications/$id/mark-read?user_id=$userId";

  static const String faqs = '/faqs';
  static const String privacyPolicy = '/privacy-policy';
  static const String paymentPolicy = '/payment-policy';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String aboutUs = '/static-pages/about_us';
  static const String feedback = '/feedback';
  static const String customerSupport = '/static-pages/customer_support';

  static String toggleLike(int id) => "/astrologer/community/followers/$id/toggle-like";
  static String getProfile(int id) => "/astrologer/profile/$id";
  static String trainingVideoDetail(int id) => "/astrologer/training-videos/$id";
  static const String toggleOnline = "/astrologer/toggle-online";
  static const String updateOtherDetails = "/astrologer/profile/other-details";

  // Gallery
  static const String uploadGallery = "/astrologer/gallery/upload";
  static const String galleryList = "/astrologer/gallery";
  static String toggleGalleryVisibility(int id) => "/astrologer/gallery/$id/toggle-visibility";
  static String deleteGalleryImage(int id) => "/astrologer/gallery/$id";

  // Reviews
  static const String reviewList = "/user/reviews";
  static String replyReview(int id) => "/user/reviews/$id/reply";

  // Live Sessions
  static const String liveSessions = "/astrologer/live";
  static String deleteLiveSession(int id) => "/astrologer/live/$id";

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
  static const String activeDefaultMessage = "/astrologer/default-messages/active";
  static String defaultMessageUpdate(int id) => "/astrologer/default-messages/$id";
  static String defaultMessageDelete(int id) => "/astrologer/default-messages/$id";
  static String setDefaultMessageActive(int id) => "/astrologer/default-messages/$id/set-default";

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
  static const String walletEarnings = "/astrologer/wallet/earnings";
  static const String walletWithdrawals = "/astrologer/wallet/withdrawals";
  static const String walletWithdraw = "/astrologer/wallet/withdraw";
  static const String walletWeeklyRankings = "/astrologer/wallet/weekly-rankings";
  
  static const String getCurrentSession = "/chat/sessions/current";
  static String markChatRead(int sessionId) => "/chat/$sessionId/read";
  static String syncChatStatus(int sessionId) => "/chat/$sessionId/sync-status";
  static const String uploadAttachment = "/chat/upload-attachment";
  static String getChatMessages(int sessionId) => "/chat/$sessionId/messages";
  static const String astrologerChatSessions = "/chat/sessions/astrologer";

  // WebSocket / Pusher Events
  static const String pusherConnectionEstablished = 'pusher:connection_established';
  static const String pusherSubscriptionSucceeded = 'pusher_internal:subscription_succeeded';
  static const String pusherSubscribe = 'pusher:subscribe';
  static const String pusherPing = 'pusher:ping';
  static const String pusherPong = '{"event":"pusher:pong"}';

  // Chat System Events
  static const String eventChatInitiated = 'ChatInitiated';
  static const String eventChatQueueUpdated = 'ChatQueueUpdated';
  static const String eventChatAccepted = 'ChatAccepted';
  static const String eventChatEnded = 'ChatEnded';
  static const String eventMessageSent = 'MessageSent';
  static const String eventMessageStatusUpdated = 'MessageStatusUpdated';
  static const String eventPresenceUpdated = 'PresenceUpdated';
  static const String eventChatDismissed = 'ChatDismissed';

  // Channel Names
  static String privateUserChannel(int userId) => 'private-user.$userId';
  static const String presenceRoomChannel = 'presence-room';

  // Call System Endpoints
  static const String initiateCall = '/call/initiate';
  static String acceptCall(int sessionId) => '/call/$sessionId/accept';
  static String rejectCall(int sessionId) => '/call/$sessionId/reject';
  static String cancelCall(int sessionId) => '/call/$sessionId/cancel';
  static String endCallSession(int sessionId) => '/call/$sessionId/end';
  static String sendIceCandidate(int sessionId) => '/call/$sessionId/ice-candidate';
  static const String currentCallSession = '/call/current-session';
  static const String pendingCallSessions = '/call/pending';
  static const String userCallSessions = '/call/sessions/user';
  static const String astrologerCallSessions = '/call/sessions/astrologer';

  // Call System Events
  static const String eventCallInitiated = 'CallInitiated';
  static const String eventCallAccepted = 'CallAccepted';
  static const String eventCallDismissed = 'CallDismissed';
  static const String eventCallEnded = 'CallEnded';
  static const String eventIceCandidateSent = 'IceCandidateSent';

  // Price Increase Request
  static const String priceIncreaseStatus = "/price-increase/status";
  static const String priceIncreaseRequest = "/price-increase/request";
  static const String priceIncreaseHistory = "/price-increase/history";
}