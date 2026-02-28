import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class AppConfig {
  // Google Sign-In: Replace with your Web OAuth Client ID from Google Cloud Console
  // This is the WEB client ID (not Android), needed for idToken on Android
  static const String googleWebClientId =
      '702596586580-lt6m2jha8j9da3l52jid1nle43cpp135.apps.googleusercontent.com';

  // Backend API - auto-detect host based on platform
  // Web: localhost, Android emulator: 10.0.2.2, Physical device: use your PC's IP
  static String get _host {
    if (kIsWeb) return 'localhost';
    if (defaultTargetPlatform == TargetPlatform.android) return '10.107.231.80';
    return 'localhost'; // iOS simulator uses localhost
  }

  static String get apiBaseUrl => 'http://$_host:8000/api/v1';
  static String get wsBaseUrl => 'ws://$_host:8000';
}
