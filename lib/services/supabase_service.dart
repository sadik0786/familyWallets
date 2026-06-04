import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_keys.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isDemoMode = true;
  bool get isDemoMode => _isDemoMode;

  SupabaseClient get client {
    if (_isDemoMode) {
      throw StateError('Cannot access Supabase client while in Demo Mode.');
    }
    return Supabase.instance.client;
  }

  Future<void> initialize() async {
    final url = AppKeys.supabaseUrl;
    final anonKey = AppKeys.supabaseAnonKey;

    if (url.isEmpty || anonKey.isEmpty) {
      debugPrint('[SupabaseService] Supabase credentials not found. Initializing in high-fidelity DEMO fallback mode.');
      _isDemoMode = true;
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _isDemoMode = false;
      debugPrint('[SupabaseService] Supabase successfully initialized in PRODUCTION mode.');
    } catch (e) {
      debugPrint('[SupabaseService] Failed to initialize Supabase: $e. Falling back to DEMO mode.');
      _isDemoMode = true;
    }
  }

  Future<bool> checkConnection() async {
    if (_isDemoMode) return false;
    try {
      // Small network request to check connection
      await client.from('users').select('id').limit(1);
      return true;
    } catch (_) {
      return false;
    }
  }
}
