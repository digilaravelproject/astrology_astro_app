class AppUrls {
  static const String baseUrl = "https://darkgoldenrod-peafowl-305286.hostingersite.com/api/v1";
  static const String baseImageUrl = "https://darkgoldenrod-peafowl-305286.hostingersite.com/storage/app/public/";
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
}