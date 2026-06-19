import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/local_db_service.dart';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

class AuthRepository {
  final SupabaseService _supabase = SupabaseService();
  final LocalDbService _localDb = LocalDbService();

  // Convert phone number to a fake email for Supabase email+password auth
  String _phoneToEmail(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return '$digits@familywallet.auth';
  }

  // Build a UserModel from Supabase auth user (no users table needed)
  UserModel _userFromAuth(User authUser, {String? displayName, String? email}) {
    final name =
        displayName ??
        authUser.userMetadata?['display_name'] as String? ??
        authUser.email?.split('@').first ??
        'User';
    return UserModel(
      id: authUser.id,
      email: email ?? authUser.email ?? '',
      displayName: name,
      role: 'user',
      createdAt: DateTime.now(),
    );
  }

  // Try to insert user profile — non-fatal, errors are logged only
  Future<void> _upsertUserProfile(
    String id,
    String email,
    String displayName,
  ) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      await _supabase.client.from('users').upsert({
        'id': id,
        'email': email,
        'display_name': displayName,
        'role': 'user',
        'created_at': now,
        'updated_at': now,
      }, onConflict: 'id');
    } catch (e) {
      debugPrint(
        '[AuthRepository] Could not upsert user profile (non-fatal): $e',
      );
    }
  }

  Future<UserModel?> getCurrentUser() async {
    if (_supabase.isDemoMode) {
      final cached = _localDb.getString('current_user');
      if (cached != null && cached.isNotEmpty) {
        return UserModel(
          id: cached,
          email: 'demo@familywallet.com',
          displayName: 'Demo',
          role: 'user',
          createdAt: DateTime.now(),
        );
      }
      return null;
    }

    try {
      final authUser = _supabase.client.auth.currentUser;
      if (authUser == null) return null;

      // Try users table first
      final res = await _supabase.client
          .from('users')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();
          
      if (res != null) {
        return UserModel.fromJson(res);
      } else {
        // If not in users table, sign out to invalidate session
        await _supabase.client.auth.signOut();
        return null;
      }
    } catch (e) {
      debugPrint('[AuthRepository] Error fetching user: $e');
      return null;
    }
  }

  Future<UserModel?> signInWithEmail(String email, String password) async {
    if (_supabase.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 1000));
      const mockId = 'mock-user-uuid-12345';
      await _localDb.setString('current_user', mockId);
      return UserModel(
        id: mockId,
        email: email,
        displayName: email.split('@').first,
        role: 'user',
        createdAt: DateTime.now(),
      );
    }

    try {
      final response = await _supabase.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final authUser = response.user;
      if (authUser == null) return null;

      // Enforce that the user profile exists in the database
      final res = await _supabase.client
          .from('users')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();
          
      if (res != null) {
        return UserModel.fromJson(res);
      } else {
        await _supabase.client.auth.signOut();
        throw Exception('User not found in database.');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<UserModel?> signInWithPhone(String phone, String password) async {
    final email = _phoneToEmail(phone);
    return signInWithEmail(email, password);
  }

  Future<UserModel?> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    if (_supabase.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 1000));
      final mockId = const Uuid().v4();
      await _localDb.setString('current_user', mockId);
      return UserModel(
        id: mockId,
        email: email,
        displayName: displayName,
        role: 'user',
        createdAt: DateTime.now(),
      );
    }

    try {
      final response = await _supabase.client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );
      final authUser = response.user;
      if (authUser == null) return null;

      // Non-fatal: try to create profile row
      await _upsertUserProfile(authUser.id, email, displayName);

      return _userFromAuth(authUser, email: email, displayName: displayName);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<UserModel?> signUpWithPhone(
    String phone,
    String password,
    String displayName,
  ) async {
    final email = _phoneToEmail(phone);
    if (_supabase.isDemoMode) {
      return signUpWithEmail(email, password, displayName);
    }

    try {
      final response = await _supabase.client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName, 'phone': phone},
      );
      final authUser = response.user;
      if (authUser == null) return null;

      // Non-fatal: try to create profile row
      await _upsertUserProfile(authUser.id, email, displayName);

      return _userFromAuth(authUser, email: email, displayName: displayName);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> signInWithOtp(String phone) async {
    if (_supabase.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 1000));
      return true;
    }
    try {
      await _supabase.client.auth.signInWithOtp(phone: phone);
      return true;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel?> verifyOtp(String phone, String token) async {
    if (_supabase.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 1000));
      const mockId = 'mock-user-uuid-12345';
      await _localDb.setString('current_user', mockId);
      return UserModel(
        id: mockId,
        email: 'phone_user@familywallet.com',
        displayName: 'Phone User',
        role: 'user',
        createdAt: DateTime.now(),
      );
    }
    try {
      final response = await _supabase.client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      final authUser = response.user;
      if (authUser == null) return null;
      return _userFromAuth(authUser);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    if (_supabase.isDemoMode) {
      await _localDb.setString('current_user', '');
      await _localDb.setString('current_family_id', '');
      return;
    }
    await _supabase.client.auth.signOut();
  }
}
