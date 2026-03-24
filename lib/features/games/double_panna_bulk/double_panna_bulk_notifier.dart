import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/double_panna/double_panna_digit.dart';
import 'package:sm_project/features/games/kalyan_morning_notifier.dart';
import 'package:sm_project/features/starline/starline_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

final doublePanaBulkNotifierProvider = AsyncNotifierProvider.autoDispose<
    DoublePanaBulkNotifier, DoublePanaBulkMode>(() {
  return DoublePanaBulkNotifier();
});

class DoublePanaBulkMode {
  final userParticularPlayer = UserParticularPlayer.getParticularUserData();
  String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());

  List<SelectedDoublePanaBulkModel> selectedNumberList = [];
  int? totalSelectedNumber = 0;
  int totalPoints = 0;
  int? leftPoints;
  TextEditingController enteredPoints = TextEditingController(text: "");

  String? openDigit;
  String? closeDigit;

  GetSettingModel? getSettingModel = GetSettingModel();

  // Map to store points for each panna number
  Map<String, TextEditingController> pannaPoints = {};

  DoublePanaBulkMode() {
    // Initialize points controllers for all double panna numbers
    for (final panna in doublePannaList) {
      pannaPoints[panna] = TextEditingController();
    }
  }
}

class DoublePanaBulkNotifier
    extends AutoDisposeAsyncNotifier<DoublePanaBulkMode> {
  final DoublePanaBulkMode _outputMode = DoublePanaBulkMode();

  void updateEnteredPoints(String point) {
    if (point.isNotEmpty && int.tryParse(point) != null) {
      _outputMode.enteredPoints.text = point;
      state = AsyncData(_outputMode);
    }
  }

  void addPoints(BuildContext context, String digit) async {
    try {
      FocusScope.of(context).unfocus();

      // Validate entered points
      if (_outputMode.enteredPoints.text.isEmpty) {
        toast(context: context, 'Please enter points');
        return;
      }

      final points = int.tryParse(_outputMode.enteredPoints.text)?.abs();
      if (points == null || points <= 0) {
        toast(context: context, 'Invalid points entered');
        return;
      }

      // Check wallet balance
      final walletAmount = _outputMode.userParticularPlayer?.wallet ?? 0;
      if (walletAmount < points) {
        toast(context: context, 'Insufficient wallet balance');
        return;
      }

      // Get all double panna numbers whose sum's last digit matches the selected digit
      final selectedDigit = int.parse(digit);
      final matchingPannaNumbers = doublePannaList.where((panna) {
        final sum =
            panna.split('').map((e) => int.parse(e)).reduce((a, b) => a + b);
        return sum % 10 == selectedDigit;
      }).toList();

      if (matchingPannaNumbers.isEmpty) {
        toast(context: context, 'No matching panna numbers found');
        return;
      }

      // Get points from numbers that won't be updated
      final unchangedPoints = _outputMode.selectedNumberList
          .where((selected) => !matchingPannaNumbers.contains(selected.points))
          .fold(0, (sum, item) => sum + int.parse(item.value ?? '0'));

      // Calculate total points needed
      final totalPointsNeeded =
          unchangedPoints + (points * matchingPannaNumbers.length);

      // Check if total points exceed wallet balance
      if (walletAmount < totalPointsNeeded) {
        toast(
          context: context,
          'Insufficient wallet balance for all selections',
        );
        return;
      }

      // Update or add points for matching panna numbers
      for (final pannaNumber in matchingPannaNumbers) {
        final pannaModel = _outputMode.pannaPoints[pannaNumber];

        // Check if this panna number is already in the selected list
        int existingIndex = _outputMode.selectedNumberList.indexWhere(
          (element) => element.points == pannaNumber,
        );

        if (existingIndex != -1) {
          // Get existing points and add new points
          final existingPoints = int.parse(
            _outputMode.selectedNumberList[existingIndex].value ?? '0',
          );
          final newTotalPoints = existingPoints + points;

          // Update existing selection with combined points
          _outputMode.selectedNumberList[existingIndex] =
              SelectedDoublePanaBulkModel(
            points: pannaNumber,
            value: newTotalPoints.toString(),
            session: (ref.watch(kalyanMorningNotifierProvider).value?.isClose ??
                    false)
                ? "close"
                : "open",
          );

          // Update points in pannaPoints map
          if (pannaModel != null) {
            pannaModel.text = newTotalPoints.toString();
          }
        } else {
          // Add new selection with initial points
          final newSelection = SelectedDoublePanaBulkModel(
            points: pannaNumber,
            value: points.toString(),
            session: (ref.watch(kalyanMorningNotifierProvider).value?.isClose ??
                    false)
                ? "close"
                : "open",
          );

          _outputMode.selectedNumberList.add(newSelection);

          // Set initial points in pannaPoints map
          if (pannaModel != null) {
            pannaModel.text = points.toString();
          }
        }
      }

      totalAll();
      state = AsyncData(_outputMode);
    } catch (e) {
      log(e.toString(), name: 'DoublePanaBulkNotifier-addPoints');
      toast(context: context, 'Error adding points');
    }
  }

  void removePoints(BuildContext context, String pannaNumber) {
    try {
      // Remove from selected list
      _outputMode.selectedNumberList.removeWhere(
        (element) => element.points == pannaNumber,
      );

      // Clear points in model
      final pannaModel = _outputMode.pannaPoints[pannaNumber];
      if (pannaModel != null) {
        pannaModel.text = '';
      }

      totalAll();
      state = AsyncData(_outputMode);
    } catch (e) {
      log(e.toString(), name: 'DoublePanaBulkNotifier-removePoints');
      toast(context: context, 'Error removing points');
    }
  }

  void deleteAll(BuildContext context) {
    _outputMode.selectedNumberList.clear();
    for (var model in _outputMode.pannaPoints.values) {
      model.text = '';
    }
    totalAll();
    state = AsyncData(_outputMode);
  }

  void clearSelectedNumberList() {
    for (var model in _outputMode.pannaPoints.values) {
      model.text = '';
    }
    state = AsyncData(_outputMode);
  }

  void clearConfirmNumberList() {
    _outputMode.selectedNumberList.clear();
    _outputMode.totalSelectedNumber = 0;
    _outputMode.totalPoints = 0;
    _outputMode.enteredPoints.text = '';
    state = AsyncData(_outputMode);
  }

  void totalAll() {
    _outputMode.totalPoints = _outputMode.selectedNumberList.fold(
      0,
      (sum, item) => sum + int.parse(item.value ?? '0'),
    );
    _outputMode.totalSelectedNumber = _outputMode.selectedNumberList.length;
    _outputMode.leftPoints = (_outputMode.userParticularPlayer?.wallet ?? 0) -
        _outputMode.totalPoints;
    state = AsyncData(_outputMode);
  }

  void onSubmitConfirm(
    BuildContext context,
    String tag,
    String marketId,
  ) async {
    if (_outputMode.selectedNumberList.isEmpty) {
      toast(context: context, 'No bets selected');
      return;
    }

    try {
      // Check minimum bid amount
      _outputMode.getSettingModel = await ApiService().getSettingModel();
      int minimumBidAmount =
          _outputMode.getSettingModel?.data?.betting?.min ?? 0;
      if (_outputMode.totalPoints < minimumBidAmount) {
        toast(context: context, 'Minimum bid amount is ₹ $minimumBidAmount');
        return;
      }

      // Show confirmation dialog
      bool? shouldProceed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title:  Text(
              'Confirm Your Bet',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bet Summary:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        ..._outputMode.selectedNumberList.map(
                          (bet) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Panna: ${bet.points}'),
                                Text('Points: ₹${bet.value}'),
                                Text('${bet.session?.toUpperCase()}'),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Bets:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_outputMode.totalSelectedNumber}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '₹${_outputMode.totalPoints}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Bet',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );

      if (shouldProceed != true) {
        return;
      }

      EasyLoading.show(status: 'Loading...');

      // Place bets for each selected number
      List<Map<String, dynamic>> jsonDataArray = [
        for (var selection in _outputMode.selectedNumberList)
          {
            "user_id": ref
                    .watch(getParticularPlayerNotifierProvider)
                    .value
                    ?.getParticularPlayerModel
                    ?.data
                    ?.sId ??
                "",
            "session": ref.watch(starlineNotifierProvider)
                ? "open"
                : selection.session ?? "",
            "tag": tag,
            "open_digit": "-",
            "close_digit": "-",
            "open_panna": ref.watch(starlineNotifierProvider)
                ? selection.points ?? ""
                : selection.session == "open"
                    ? selection.points ?? ""
                    : "-",
            "close_panna": ref.watch(starlineNotifierProvider)
                ? "-"
                : selection.session == "close"
                    ? selection.points ?? ""
                    : "-",
            "points": int.parse(selection.value!),
            "game_mode": "double-panna",
            "market_id": marketId,
          },
      ];

      var result = await ApiService().postPlayGameAllMarket(jsonDataArray);

      // Play success sound
      AudioPlayer().play(AssetSource(bidsSound));
      EasyLoading.dismiss();

      // Show success dialog
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green[400],
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Success!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your bet has been placed successfully',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Total Amount: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '₹${_outputMode.totalPoints}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlue,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }

      clearConfirmNumberList();
      clearSelectedNumberList();

      // Update wallet and show success message
      await ApiService().getParticularUserData();
      ref
          .read(getParticularPlayerNotifierProvider.notifier)
          .getParticularPlayerModel();
    } catch (e) {
      log(e.toString(), name: 'DoublePanaBulkNotifier-onSubmitConfirm');
      if (context.mounted) {
        toast(context: context, 'Error placing bids');
      }
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  build() {
    _outputMode.leftPoints = _outputMode.userParticularPlayer?.wallet ?? 0;
    return _outputMode;
  }
}

class DoublePanaBulkModel {
  TextEditingController? value;
  String? points;
  DoublePanaBulkModel({this.points, this.value});
}

class SelectedDoublePanaBulkModel {
  String? value;
  String? points;
  String? session;
  SelectedDoublePanaBulkModel({this.session, this.points, this.value});
}
