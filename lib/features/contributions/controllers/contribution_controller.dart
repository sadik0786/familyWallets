import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/contribution_repository.dart';
import '../../../models/finance_models.dart';
import '../../../services/local_db_service.dart';

class ContributionState {
  final List<ContributionModel> contributions;
  final bool isLoading;
  final String? errorMessage;

  ContributionState({
    this.contributions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ContributionState copyWith({
    List<ContributionModel>? contributions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ContributionState(
      contributions: contributions ?? this.contributions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ContributionController extends StateNotifier<ContributionState> {
  final ContributionRepository _repository;
  final String? _familyId;

  ContributionController(this._repository, this._familyId) : super(ContributionState()) {
    loadContributions();
  }

  Future<void> loadContributions() async {
    if (_familyId == null || _familyId.isEmpty) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getContributions(_familyId);
      state = state.copyWith(contributions: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> addContribution({
    required double amount,
    required String contributorName,
    required String? contributorId,
    required String? note,
    required DateTime date,
  }) async {
    if (_familyId == null) return false;
    state = state.copyWith(isLoading: true);
    try {
      final contribution = ContributionModel(
        id: '',
        familyId: _familyId,
        amount: amount,
        contributorId: contributorId,
        contributorName: contributorName,
        note: note,
        date: date,
        createdAt: DateTime.now(),
      );

      final added = await _repository.addContribution(contribution);
      state = state.copyWith(
        contributions: [added, ...state.contributions],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> deleteContribution(String id) async {
    if (_familyId == null) return;
    try {
      await _repository.deleteContribution(id, _familyId);
      state = state.copyWith(
        contributions: state.contributions.where((element) => element.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

// PROVIDERS
final contributionRepositoryProvider = Provider<ContributionRepository>((ref) => ContributionRepository());

final contributionControllerProvider = StateNotifierProvider<ContributionController, ContributionState>((ref) {
  final repo = ref.watch(contributionRepositoryProvider);
  
  // Fetch current family id from shared preferences or active user
  final localDb = ref.watch(localDbServiceProvider);
  final familyId = localDb.getString('current_family_id') ?? '';

  return ContributionController(repo, familyId);
});
