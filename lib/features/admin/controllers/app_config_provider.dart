import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

class AppConfigState {
  final String premiumPrice;
  final String premiumDuration;
  final bool isLoading;
  
  AppConfigState({
    this.premiumPrice = '500',
    this.premiumDuration = '1 Year',
    this.isLoading = false,
  });

  AppConfigState copyWith({
    String? premiumPrice,
    String? premiumDuration,
    bool? isLoading,
  }) {
    return AppConfigState(
      premiumPrice: premiumPrice ?? this.premiumPrice,
      premiumDuration: premiumDuration ?? this.premiumDuration,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AppConfigController extends StateNotifier<AppConfigState> {
  final AdminRepository _repository;

  AppConfigController(this._repository) : super(AppConfigState()) {
    loadConfig();
  }

  Future<void> loadConfig() async {
    state = state.copyWith(isLoading: true);
    final price = await _repository.getGlobalPremiumPrice();
    final duration = await _repository.getGlobalPremiumDuration();
    state = state.copyWith(premiumPrice: price, premiumDuration: duration, isLoading: false);
  }

  Future<bool> updatePremiumPrice(String newPrice) async {
    state = state.copyWith(isLoading: true);
    final success = await _repository.updateGlobalPremiumPrice(newPrice);
    if (success) {
      state = state.copyWith(premiumPrice: newPrice, isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<bool> updatePremiumDuration(String newDuration) async {
    state = state.copyWith(isLoading: true);
    final success = await _repository.updateGlobalPremiumDuration(newDuration);
    if (success) {
      state = state.copyWith(premiumDuration: newDuration, isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }
}

final appConfigControllerProvider = StateNotifierProvider<AppConfigController, AppConfigState>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return AppConfigController(repo);
});
