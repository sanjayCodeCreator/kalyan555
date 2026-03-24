import 'dart:developer';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sm_project/controller/apiservices/api_service.dart';
import 'package:sm_project/controller/model/demo_rank/today_winners_model.dart';

final todayWinnersNotifierProvider =
    AsyncNotifierProvider.autoDispose<TodayWinnersNotifier, TodayWinnersModel>(
        () {
  return TodayWinnersNotifier();
});

class TodayWinnersNotifier extends AutoDisposeAsyncNotifier<TodayWinnersModel> {
  @override
  Future<TodayWinnersModel> build() async {
    return await getTodayWinners();
  }

  Future<TodayWinnersModel> getTodayWinners() async {
    try {
      final response = await ApiService().getTodayWinners();
      log('Today Winners Response: ${response?.toJson()}',
          name: 'TodayWinnersNotifier');
      return response ?? TodayWinnersModel(status: "failure");
    } catch (e) {
      log('Error fetching today winners: $e', name: 'TodayWinnersNotifier');
      return TodayWinnersModel(status: "failure");
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => getTodayWinners());
  }
}

