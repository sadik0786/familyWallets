import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppKeys {
  AppKeys._();

  // Supabase Configuration — loaded from .env file
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // SharedPreferences Keys
  static const String themeModeKey = 'pref_theme_mode';
  static const String userSessionKey = 'pref_user_session';
  static const String familySessionKey = 'pref_family_session';
  static const String localCachePrefix = 'local_cache_';
  static const String isDemoModeKey = 'pref_is_demo_mode';
}
