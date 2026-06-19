import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/auth_repository.dart';
import '../../../models/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isSessionRestored;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isSessionRestored = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool? isSessionRestored,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSessionRestored: isSessionRestored ?? this.isSessionRestored,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(AuthState()) {
    restoreSession();
  }

  Future<void> restoreSession() async {
    state = state.copyWith(isLoading: true);
    
    // Run both user fetching and a minimum 2-second delay in parallel
    // This ensures the splash screen animation has time to finish before redirecting
    final results = await Future.wait([
      _repository.getCurrentUser(),
      Future.delayed(const Duration(seconds: 2)),
    ]);
    
    final user = results[0] as UserModel?;
    state = AuthState(user: user, isSessionRestored: true);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.signInWithEmail(email, password);
      if (user != null) {
        state = AuthState(user: user, isSessionRestored: true);
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Sign in failed. Please try again.');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signup(String email, String password, String displayName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.signUpWithEmail(email, password, displayName);
      if (user != null) {
        // Sign out immediately so user has to manually login
        await _repository.signOut();
        state = AuthState(user: null, isSessionRestored: true);
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Registration failed.');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repository.signInWithOtp(phone);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String code) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.verifyOtp(phone, code);
      if (user != null) {
        state = AuthState(user: user, isSessionRestored: true);
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Invalid OTP code.');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> loginWithPhone(String phone, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.signInWithPhone(phone, password);
      if (user != null) {
        state = AuthState(user: user, isSessionRestored: true);
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Sign in failed. Please try again.');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signupWithPhone(String phone, String password, String displayName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.signUpWithPhone(phone, password, displayName);
      if (user != null) {
        // Sign out immediately so user has to manually login
        await _repository.signOut();
        state = AuthState(user: null, isSessionRestored: true);
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Registration failed.');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repository.signOut();
    state = AuthState(isSessionRestored: true);
  }
}

// PROVIDERS
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});
