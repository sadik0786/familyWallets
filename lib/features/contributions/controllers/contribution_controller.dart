import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/contribution_repository.dart';
import '../../../models/finance_models.dart';
import '../../profile/controllers/profile_controller.dart';

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
  String? _familyId;

  ContributionController(this._repository) : super(ContributionState());

  void updateFamilyId(String? familyId) {
    if (_familyId == familyId) return;
    _familyId = familyId;
    if (_familyId != null && _familyId!.isNotEmpty) {
      loadContributions();
    } else {
      state = ContributionState();
    }
  }

  Future<void> loadContributions() async {
    final familyId = _familyId;
    if (familyId == null || familyId.isEmpty) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getContributions(familyId);
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
    final familyId = _familyId;
    if (familyId == null) return false;
    state = state.copyWith(isLoading: true);
    try {
      final contribution = ContributionModel(
        id: '',
        familyId: familyId,
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
    final familyId = _familyId;
    if (familyId == null) return;
    try {
      await _repository.deleteContribution(id, familyId);
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
  final controller = ContributionController(repo);
  
  ref.listen(profileControllerProvider, (previous, next) {
    if (previous?.family?.id != next.family?.id) {
      controller.updateFamilyId(next.family?.id);
    }
  });

  final initialFamilyId = ref.read(profileControllerProvider).family?.id;
  controller.updateFamilyId(initialFamilyId);

  return controller;
});
