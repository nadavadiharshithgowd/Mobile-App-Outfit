import 'app_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => AppConfig.apiBaseUrl;

  // Auth
  static const String sendOtp = '/auth/email/send-otp/';
  static const String verifyOtp = '/auth/email/verify-otp/';
  static const String googleAuth = '/auth/google/';
  static const String refreshToken = '/auth/token/refresh/';
  static const String me = '/auth/me/';

  // Upload
  static const String presignedUrl = '/upload/presigned-url/';
  static const String confirmUpload = '/upload/confirm/';

  // Wardrobe
  static const String wardrobe = '/wardrobe/';
  static String wardrobeItem(String id) => '/wardrobe/$id/';
  static const String wardrobeCategories = '/wardrobe/categories/';
  static String wardrobeSimilar(String id) => '/wardrobe/$id/similar/';

  // Outfits
  static const String outfits = '/outfits/';
  static String outfitDetail(String id) => '/outfits/$id/';
  static String outfitFavorite(String id) => '/outfits/$id/favorite/';

  // Recommendations
  static const String dailyRecommendation = '/recommendations/daily/';
  static const String generateRecommendation = '/recommendations/generate/';
  static String acceptRecommendation(String id) =>
      '/recommendations/$id/accept/';
  static String rejectRecommendation(String id) =>
      '/recommendations/$id/reject/';

  // Try-On
  static const String tryOn = '/tryon/';
  static String tryOnDetail(String id) => '/tryon/$id/';

  // WebSocket
  static String get wsBaseUrl => AppConfig.wsBaseUrl;
  static String tryOnStatus(String id) => '/ws/tryon/$id/status/';
}
