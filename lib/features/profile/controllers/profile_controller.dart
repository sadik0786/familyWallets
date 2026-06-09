import 'package:family_wallet/features/auth/controllers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/family_repository.dart';
import '../../../models/family_model.dart';
import '../../../models/member_model.dart';
import '../../../services/local_db_service.dart';
import '../../../core/constants/app_keys.dart';

class ProfileState {
  final List<MemberModel> members;
  final FamilyModel? family;
  final bool isDarkMode;
  final String language;
  final bool isLoading;
  final String? errorMessage;

  ProfileState({
    this.members = const [],
    this.family,
    this.isDarkMode = true, // Default to Dark Obsidian theme
    this.language = 'en', // Default to English
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    List<MemberModel>? members,
    FamilyModel? family,
    bool? isDarkMode,
    String? language,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      members: members ?? this.members,
      family: family ?? this.family,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ProfileController extends StateNotifier<ProfileState> {
  final FamilyRepository _repository;
  final LocalDbService _localDb = LocalDbService();
  final String? _familyId;
  final String? _userId;

  ProfileController(this._repository, this._familyId, this._userId)
    : super(ProfileState()) {
    _initTheme();
    _initLanguage();
    loadFamilyAndMembers();
  }

  void _initTheme() {
    final cached = _localDb.getBool(AppKeys.themeModeKey);
    // Default to dark mode (true) if nothing is cached
    state = state.copyWith(isDarkMode: cached ?? true);
  }

  void _initLanguage() {
    final cached = _localDb.getString('pref_app_language');
    state = state.copyWith(language: cached ?? 'en');
  }

  Future<void> toggleTheme(bool isDark) async {
    await _localDb.setBool(AppKeys.themeModeKey, isDark);
    state = state.copyWith(isDarkMode: isDark);
  }

  Future<void> changeLanguage(String langCode) async {
    await _localDb.setString('pref_app_language', langCode);
    state = state.copyWith(language: langCode);
  }

  Future<void> loadFamilyAndMembers() async {
    String? targetFamilyId = _familyId;

    // If local storage was wiped (e.g., app reinstalled), try to recover from the DB using userId
    if ((targetFamilyId == null || targetFamilyId.isEmpty) && _userId != null) {
      final recoveredFamily = await _repository.getUserFamily(_userId);
      if (recoveredFamily != null) {
        targetFamilyId = recoveredFamily.id;
        await _localDb.setString('current_family_id', targetFamilyId);
      }
    }

    if (targetFamilyId == null || targetFamilyId.isEmpty) return;

    if (!mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final familyDetails = await _repository.getFamilyDetails(targetFamilyId);
      final membersList = await _repository.getFamilyMembers(targetFamilyId);
      if (!mounted) return;
      state = state.copyWith(
        family: familyDetails,
        members: membersList,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> createFamilyWorkspace(
    String name,
    String userId,
    String displayName,
  ) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      final newFamily = await _repository.createFamily(
        name,
        userId,
        displayName,
      );

      // Save current family in local preferences
      await _localDb.setString('current_family_id', newFamily!.id);

      if (!mounted) return;
      state = state.copyWith(family: newFamily, isLoading: false);

      await loadFamilyAndMembers();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> joinFamilyWorkspace(
    String code,
    String userId,
    String displayName,
  ) async {
    if (!mounted) return false;
    state = state.copyWith(isLoading: true);
    try {
      final family = await _repository.joinFamily(code, userId, displayName);
      if (family != null) {
        await _localDb.setString('current_family_id', family.id);
        if (!mounted) return false;
        state = state.copyWith(family: family, isLoading: false);

        await loadFamilyAndMembers();
        return true;
      }
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not join family.',
      );
      return false;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> upgradeSubscription(String planKey) async {
    if (state.family == null) return;
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      int durationDays = 365; // Default to 1 year
      if (planKey == '1_month') {
        durationDays = 30;
      } else if (planKey == '3_months') {
        durationDays = 90;
      } else if (planKey == '6_months') {
        durationDays = 180;
      } else if (planKey == '1_year') {
        durationDays = 365;
      }

      await _repository.updateSubscriptionTier(
        state.family!.id,
        'premium',
        durationDays: durationDays,
      );
      final updatedFamily = state.family!.copyWith(subscriptionTier: 'premium');
      // Note: In a real app we would also update the premiumUntil locally, but a refresh will fetch it anyway.

      if (!mounted) return;
      state = state.copyWith(family: updatedFamily, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> removeMember(String userId) async {
    if (state.family == null) return;
    state = state.copyWith(isLoading: true);
    try {
      await _repository.removeMember(state.family!.id, userId);
      // Remove from state list
      final updatedMembers = state.members
          .where((m) => m.userId != userId)
          .toList();
      if (!mounted) return;
      state = state.copyWith(members: updatedMembers, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// PROVIDERS
final familyRepositoryProvider = Provider<FamilyRepository>(
  (ref) => FamilyRepository(),
);

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      final repo = ref.watch(familyRepositoryProvider);
      final localDb = ref.watch(localDbServiceProvider);
      final authState = ref.watch(authControllerProvider);
      final familyId = localDb.getString('current_family_id') ?? '';
      return ProfileController(repo, familyId, authState.user?.id);
    });
