import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/controller/model/single_digit_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/games/double_panna/double_panna_digit.dart';
import 'package:sm_project/features/games/kalyan_morning_notifier.dart';
import 'package:sm_project/features/home/main_screen.dart';
import 'package:sm_project/utils/filecollection.dart';

final dpMotorGameNotifierProvider =
    StateNotifierProvider<DpMotorGameNotifier, DpMotorGameState>((ref) {
  return DpMotorGameNotifier();
});

class DpMotorGameState {
  var userParticularPlayer = UserParticularPlayer.getParticularUserData();
  String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
  TextEditingController enteredNumber = TextEditingController();
  TextEditingController enteredPoints = TextEditingController();

  List<SelectedSpMotorModel> selectedNumberList = [];
  int? totalSelectedNumber = 0;
  int? totalPoints = 0;
  int? leftPoints;

  GetSettingModel? getSettingModel = GetSettingModel();

  // Add a session getter for UI
  String get session {
    if (selectedNumberList.isNotEmpty &&
        selectedNumberList.first.session != null) {
      return selectedNumberList.first.session!;
    }
    // Default logic: use open/close based on kalyanMorningNotifierProvider if available
    // But we can't access ref here, so return empty or a default value
    return '';
  }
}

class DpMotorGameNotifier extends StateNotifier<DpMotorGameState> {
  DpMotorGameNotifier() : super(DpMotorGameState()) {
    state.leftPoints = state.userParticularPlayer?.wallet ?? 0;
  }

  Future<void> refreshWalletData(BuildContext context, WidgetRef ref) async {
    EasyLoading.show(status: 'Updating wallet...');
    try {
      // Preserve UI-related state that should not be reset by a wallet refresh

      final preservedEnteredNumberController = state.enteredNumber;
      final preservedEnteredPointsController = state.enteredPoints;
      final preservedSelectedNumberList =
          List<SelectedSpMotorModel>.from(state.selectedNumberList);
      final preservedGetSettingModel = state.getSettingModel;

      // 1. Fetch the latest user data. This should update the data source for UserParticularPlayer.getParticularUserData().
      await ref
          .read(homeNotifierProvider.notifier)
          .getParticularPlayerModel(context);

      // 2. Create the new state. Its 'userParticularPlayer' will be initialized by its constructor
      //    using the now-fresh data from UserParticularPlayer.getParticularUserData().
      //    All other fields of this new 'state' object will be default-initialized by SpMotorGameState().
      state = DpMotorGameState();

      // 3. Now, populate this new 'state' with preserved UI values and correctly calculated financial values.
      //    'state.userParticularPlayer' is already the fresh one from the SpMotorGameState() call above.
      int newTotalPoints = preservedSelectedNumberList.fold(
          0,
          (previousValue, element) =>
              previousValue + int.parse(element.value!));
      int newTotalSelectedNumber = preservedSelectedNumberList.length;
      int newLeftPoints =
          (state.userParticularPlayer?.wallet ?? 0) - newTotalPoints;

      // Assign all fields to the 'state' object.
      state
        ..enteredNumber = preservedEnteredNumberController
        ..enteredPoints = preservedEnteredPointsController
        ..selectedNumberList = preservedSelectedNumberList
        ..totalSelectedNumber = newTotalSelectedNumber
        ..totalPoints = newTotalPoints
        ..leftPoints = newLeftPoints
        ..getSettingModel = preservedGetSettingModel;
      // ..userParticularPlayer is already set by 'state = SpMotorGameState()' and is the fresh one.
    } catch (e) {
      log(e.toString(), name: 'refreshWalletDataError');
      if (context.mounted) {
        toast(context: context, 'Failed to update wallet balance.');
      }
      // Fallback: ensure leftPoints is consistent with current (possibly stale) data
      final currentTotalPoints = state.selectedNumberList.fold(
          0,
          (previousValue, element) =>
              previousValue + int.parse(element.value!));
      final currentWallet = state.userParticularPlayer?.wallet ?? 0;

      // Create a new state instance to assign to state, similar to other methods

      final TextEditingController enteredNumber = state.enteredNumber;
      final TextEditingController enteredPoints = state.enteredPoints;
      final List<SelectedSpMotorModel> selectedNumberList =
          state.selectedNumberList;
      final GetSettingModel? getSettingModel = state.getSettingModel;
      final userParticularPlayer =
          state.userParticularPlayer; // current (possibly stale)

      state = DpMotorGameState()
        ..enteredNumber = enteredNumber
        ..enteredPoints = enteredPoints
        ..selectedNumberList = selectedNumberList
        ..totalSelectedNumber = selectedNumberList.length
        ..totalPoints = currentTotalPoints
        ..leftPoints = currentWallet - currentTotalPoints
        ..getSettingModel = getSettingModel
        ..userParticularPlayer = userParticularPlayer;
    } finally {
      EasyLoading.dismiss();
    }
  }

  void updateSession(String? session) {
    if (session != null) {
      state = DpMotorGameState()
        ..enteredNumber = state.enteredNumber
        ..enteredPoints = state.enteredPoints
        ..selectedNumberList = state.selectedNumberList
        ..totalSelectedNumber = state.totalSelectedNumber
        ..totalPoints = state.totalPoints
        ..leftPoints = state.leftPoints
        ..getSettingModel = state.getSettingModel
        ..userParticularPlayer = state.userParticularPlayer;
    }
  }

  void updateEnteredNumber(String number) {
    state.enteredNumber.text = number;
  }

  void updateEnteredPoints(String points) {
    state.enteredPoints.text = points;
  }

  void addPoints(BuildContext context, WidgetRef ref) async {
    try {
      FocusScope.of(context).unfocus();
      EasyLoading.show(status: 'Loading...');
      state.getSettingModel = await ApiService().getSettingModel();

      final String enteredMotor = state.enteredNumber.text;
      final String pointsPerBidStr = state.enteredPoints.text;

      if (enteredMotor.isEmpty) {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, 'Please enter SP Motor digits.');
        }
        return;
      }

      if (pointsPerBidStr.isEmpty) {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, 'Please enter points.');
        }
        return;
      }

      final int? pointsPerBid = int.tryParse(pointsPerBidStr);
      if (pointsPerBid == null || pointsPerBid == 0) {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, 'Invalid points entered.');
        }
        return;
      }

      // Min/Max bet validation for individual bid amount
      if ((state.getSettingModel?.data?.betting?.min ?? 0) > pointsPerBid ||
          (state.getSettingModel?.data?.betting?.max ?? 0) < pointsPerBid) {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(
              context: context,
              'Minimum bet amount is ${state.getSettingModel?.data?.betting?.min} and Maximum bet amount is ${state.getSettingModel?.data?.betting?.max}');
        }
        return;
      }

      // New logic: Find qualifying pannas
      List<String> qualifyingPannas = [];
      Set<String> motorDigits = enteredMotor.split('').toSet();

      for (String panna in doublePannaList) {
        bool allDigitsPresent = true;
        for (String pannaDigit in panna.split('')) {
          if (!motorDigits.contains(pannaDigit)) {
            allDigitsPresent = false;
            break;
          }
        }
        if (allDigitsPresent) {
          qualifyingPannas.add(panna);
        }
      }

      if (qualifyingPannas.isEmpty) {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(
              context: context,
              'No qualifying panna found for the entered motor digits.');
        }
        return;
      }

      int totalPointsForNewBids = pointsPerBid * qualifyingPannas.length;

      // Wallet check against total points for new bids
      if ((state.leftPoints ?? 0) < totalPointsForNewBids) {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(
              context: context,
              'Wallet Amount is Low for the selected bids. Required: $totalPointsForNewBids');
        }
        return;
      }

      // Add to selected numbers list
      for (String panna in qualifyingPannas) {
        state.selectedNumberList.add(SelectedSpMotorModel(
          value: pointsPerBidStr, // Points entered by user
          points: panna, // The qualifying panna
          session:
              (ref.watch(kalyanMorningNotifierProvider).value?.isClose ?? false)
                  ? "close"
                  : "open",
        ));
      }

      EasyLoading.dismiss();
      totalAll(); // Calculate totals based on the updated list
      clearInputs(); // Clear input fields

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${qualifyingPannas.length} bids added successfully!')),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'spMotorGameAddPoints');
      if (context.mounted) {
        toast(context: context, 'An error occurred: ${e.toString()}');
      }
    }

    // Update state to reflect changes
    state = DpMotorGameState()
      ..enteredNumber =
          state.enteredNumber // Controllers are already cleared by clearInputs
      ..enteredPoints =
          state.enteredPoints // Controllers are already cleared by clearInputs
      ..selectedNumberList = state.selectedNumberList
      ..totalSelectedNumber = state.totalSelectedNumber
      ..totalPoints = state.totalPoints
      ..leftPoints = state.leftPoints
      ..getSettingModel = state.getSettingModel
      ..userParticularPlayer = state.userParticularPlayer;
  }

  void removePoints(BuildContext context, int index) {
    if (state.selectedNumberList.isNotEmpty) {
      state.selectedNumberList.removeAt(index);
      totalAll();
    } else {
      toast(context: context, 'Please select number and add points');
    }

    state = DpMotorGameState()
      ..enteredNumber = state.enteredNumber
      ..enteredPoints = state.enteredPoints
      ..selectedNumberList = state.selectedNumberList
      ..totalSelectedNumber = state.totalSelectedNumber
      ..totalPoints = state.totalPoints
      ..leftPoints = state.leftPoints
      ..getSettingModel = state.getSettingModel
      ..userParticularPlayer = state.userParticularPlayer;
  }

  // Delete All
  void deleteAll(BuildContext context) {
    if (state.selectedNumberList.isNotEmpty) {
      state.selectedNumberList.clear();
      totalAll();
    } else {
      toast(context: context, 'Please select number and add points');
    }

    state = DpMotorGameState()
      ..enteredNumber = state.enteredNumber
      ..enteredPoints = state.enteredPoints
      ..selectedNumberList = state.selectedNumberList
      ..totalSelectedNumber = state.totalSelectedNumber
      ..totalPoints = state.totalPoints
      ..leftPoints = state.leftPoints
      ..getSettingModel = state.getSettingModel
      ..userParticularPlayer = state.userParticularPlayer;
  }

  // Clear inputs only
  void clearInputs() {
    state.enteredNumber.clear();
    state.enteredPoints.clear();
  }

  // clear selectedNumberList
  void clearSelectedNumberList() {
    state.enteredNumber.clear();
    state.enteredPoints.clear();

    state = DpMotorGameState()
      ..enteredNumber = state.enteredNumber
      ..enteredPoints = state.enteredPoints
      ..selectedNumberList = state.selectedNumberList
      ..totalSelectedNumber = state.totalSelectedNumber
      ..totalPoints = state.totalPoints
      ..leftPoints = state.leftPoints
      ..getSettingModel = state.getSettingModel
      ..userParticularPlayer = state.userParticularPlayer;
  }

  void clearConfirmNumberList() {
    state.selectedNumberList.clear();
    totalAll();

    state = DpMotorGameState()
      ..enteredNumber = state.enteredNumber
      ..enteredPoints = state.enteredPoints
      ..selectedNumberList = state.selectedNumberList
      ..totalSelectedNumber = state.totalSelectedNumber
      ..totalPoints = state.totalPoints
      ..leftPoints = state.leftPoints
      ..getSettingModel = state.getSettingModel
      ..userParticularPlayer = state.userParticularPlayer;
  }

  void onSubmitConfirm(
      BuildContext context, String tag, String marketId, WidgetRef ref) async {
    if (state.selectedNumberList.isNotEmpty) {
      try {
        EasyLoading.show(status: 'Loading...');
        List<Map<String, dynamic>> jsonDataArray = [
          for (int i = 0; i < state.selectedNumberList.length; i++)
            {
              "user_id": ref
                      .watch(getParticularPlayerNotifierProvider)
                      .value
                      ?.getParticularPlayerModel
                      ?.data
                      ?.sId ??
                  "",
              "session": state.selectedNumberList[i].session?.toLowerCase(),
              "tag": tag,
              "open_panna":
                  state.selectedNumberList[i].session?.toLowerCase() == "open"
                      ? state.selectedNumberList[i].points
                      : "-",
              "close_panna":
                  state.selectedNumberList[i].session?.toLowerCase() == "close"
                      ? state.selectedNumberList[i].points
                      : "-",
              "open_digit": "-",
              "close_digit": "-",
              "points": int.parse(state.selectedNumberList[i].value.toString()),
              "game_mode": "dp-motor",
              "market_id": marketId,
            },
        ];

        log(jsonDataArray.toList().toString(), name: 'spMotorGame');
        PlayGameAllMarketModel? spMotorGameModel =
            await ApiService().postPlayGameAllMarket(jsonDataArray.toList());
        if (spMotorGameModel?.status == "success") {
          if (context.mounted) {
            await ref
                .read(homeNotifierProvider.notifier)
                .getParticularPlayerModel(context);
            state.userParticularPlayer =
                UserParticularPlayer.getParticularUserData();
            state.leftPoints = state.userParticularPlayer?.wallet;
          }
          clearConfirmNumberList();
          AudioPlayer().play(AssetSource(bidsSound));
          EasyLoading.dismiss();
          if (context.mounted) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MainScreen()));
          }
        } else if (spMotorGameModel?.status == "failure") {
          clearConfirmNumberList();
          EasyLoading.dismiss();
          if (context.mounted) {
            toast(context: context, spMotorGameModel?.message ?? '');
          }
        }
      } catch (e) {
        EasyLoading.dismiss();
        log(e.toString(), name: 'spMotorGame');
      }
    } else {
      toast(context: context, 'Please select number and add points');
    }
  }

  // function total Number
  void totalAll() {
    state.totalPoints =
        state.selectedNumberList.fold(0, (a, b) => a! + int.parse(b.value!));
    state.totalSelectedNumber = state.selectedNumberList.length;

    state.leftPoints =
        (state.userParticularPlayer?.wallet)! - state.totalPoints!;
  }
}

class SelectedSpMotorModel {
  String? value;
  String? points;
  String? session;
  SelectedSpMotorModel({this.points, this.value, this.session});
}

final List<String> motorList = [
  '12345',
  '123456',
  '1234567',
  '12345678',
  '123456789',
  '1234567890',
];
