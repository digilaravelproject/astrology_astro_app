class AppUrls {
  static const String baseUrl = "https://darkgoldenrod-peafowl-305286.hostingersite.com";
  static const String baseImageUrl = "https://darkgoldenrod-peafowl-305286.hostingersite.com/storage/app/public/";
  static const String sendOtp = "/api/v1/astrologer/send-otp";
  static const String verifyOtp = "/api/v1/astrologer/verify-otp";
  static const String astrologerSignup = "/api/v1/astrologer/signup";
  static const String resendOtp = "/api/v1/astrologer/resend-otp";
  static const String updateProfilePhoto = "/api/v1/astrologer/profile/photo";
  static const String updateProfile = "/api/v1/astrologer/profile";
  static const String getNotices = "/api/v1/user/notices";
  static const String getFollowers = "/api/v1/astrologer/community/followers";
  static const String getFavorites = "/api/v1/astrologer/community/favorites";
  static const String getAstroSkills = "/api/v1/astrologer/profile/skills";
  
  static String toggleLike(int id) => "/api/v1/astrologer/community/followers/$id/toggle-like";
  static String getProfile(int id) => "/api/v1/astrologer/profile/$id";

}