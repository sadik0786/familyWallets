import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../repositories/admin_repository.dart';

class AdminState {
  final AdminStats? stats;
  final bool isLoading;
  final String? errorMessage;

  AdminState({
    this.stats,
    this.isLoading = false,
    this.errorMessage,
  });

  AdminState copyWith({
    AdminStats? stats,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AdminController extends StateNotifier<AdminState> {
  final AdminRepository _repository;

  AdminController(this._repository) : super(AdminState()) {
    fetchStats();
  }

  Future<void> fetchStats() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final stats = await _repository.getGlobalStats();
      state = state.copyWith(isLoading: false, stats: stats);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> toggleFamilyStatus(String familyId, bool isActive) async {
    final success = await _repository.toggleFamilyStatus(familyId, isActive);
    if (success) {
      // Refresh the stats immediately to show the new status in the UI
      fetchStats();
    }
  }

  Future<void> toggleFamilyPremium(String familyId, bool isPremium) async {
    final success = await _repository.toggleFamilyPremium(familyId, isPremium);
    if (success) {
      // Refresh the stats immediately to show the new status in the UI
      fetchStats();
    }
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final adminControllerProvider = StateNotifierProvider<AdminController, AdminState>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return AdminController(repo);
});
