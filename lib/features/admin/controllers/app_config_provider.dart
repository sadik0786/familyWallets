import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

class AppConfigState {
  final Map<String, String> premiumPrices;
  final bool isLoading;
  
  AppConfigState({
    this.premiumPrices = const {
      '1_month': '50',
      '3_months': '140',
      '6_months': '250',
      '1_year': '500',
    },
    this.isLoading = false,
  });

  AppConfigState copyWith({
    Map<String, String>? premiumPrices,
    bool? isLoading,
  }) {
    return AppConfigState(
      premiumPrices: premiumPrices ?? this.premiumPrices,
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
    final prices = await _repository.getPremiumPrices();
    state = state.copyWith(premiumPrices: prices, isLoading: false);
  }

  Future<bool> updatePremiumPrice(String planKey, String newPrice) async {
    state = state.copyWith(isLoading: true);
    final success = await _repository.updatePremiumPrice(planKey, newPrice);
    if (success) {
      final updatedPrices = Map<String, String>.from(state.premiumPrices);
      updatedPrices[planKey] = newPrice;
      state = state.copyWith(premiumPrices: updatedPrices, isLoading: false);
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
