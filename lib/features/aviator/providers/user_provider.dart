import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sm_project/controller/model/get_particular_player_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';

/// Wrapper class for user data that provides a similar API to the old UserModel
class AviatorUserData {
  final GetParticularPlayerModel? model;

  AviatorUserData(this.model);

  Data? get data => model?.data;
  double get wallet => (data?.wallet ?? 0).toDouble();
  String? get id => data?.sId;
  String? get userName => data?.userName;
}

/// Provider that wraps the main app's getParticularPlayerNotifierProvider
/// to provide user data in a format compatible with the aviator feature
final userProvider = FutureProvider.autoDispose<AviatorUserData>((ref) async {
  final state = ref.watch(getParticularPlayerNotifierProvider);
  return state.maybeWhen(
    data: (data) => AviatorUserData(data.getParticularPlayerModel),
    orElse: () => AviatorUserData(null),
  );
});

/// Notifier for user data that provides refresh capabilities
class UserNotifier extends StateNotifier<AsyncValue<AviatorUserData>> {
  final Ref _ref;

  UserNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final playerState = _ref.read(getParticularPlayerNotifierProvider);
      playerState.whenData((data) {
        state = AsyncValue.data(AviatorUserData(data.getParticularPlayerModel));
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _ref
        .read(getParticularPlayerNotifierProvider.notifier)
        .getParticularPlayerModel();
    await _loadUser();
  }

  // Helper getters for user data
  AviatorUserData? get userData => state.valueOrNull;
  String? get userId => userData?.id;
  String? get userName => userData?.userName;
  double? get wallet => userData?.wallet;
}

final userNotifierProvider = StateNotifierProvider.autoDispose<UserNotifier,
    AsyncValue<AviatorUserData>>((ref) {
  return UserNotifier(ref);
});
