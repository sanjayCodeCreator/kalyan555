import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/kalyan_morning_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

// Define the triple panna list here
List<String> triplePannaList = [
  '000',
  '666',
  '111',
  '777',
  '222',
  '888',
  '333',
  '999',
  '444',
  '555',
];

final triplePanaBulkNotifierProvider = AsyncNotifierProvider.autoDispose<
    TriplePanaBulkNotifier, TriplePanaBulkMode>(() {
  return TriplePanaBulkNotifier();
});

class TriplePanaBulkMode {
  final userParticularPlayer = UserParticularPlayer.getParticularUserData();
  String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());

  List<SelectedTriplePanaBulkModel> selectedNumberList = [];
  int? totalSelectedNumber = 0;
  int totalPoints = 0;
  int? leftPoints;
  TextEditingController enteredPoints = TextEditingController(text: "");

  String? openDigit;
  String? closeDigit;

  GetSettingModel? getSettingModel = GetSettingModel();

  // Map to store points for each panna number
  Map<String, TextEditingController> pannaPoints = {};

  TriplePanaBulkMode() {
    // Initialize points controllers for all triple panna numbers
    for (final panna in triplePannaList) {
      pannaPoints[panna] = TextEditingController();
    }
  }
}

class TriplePanaBulkNotifier
    extends AutoDisposeAsyncNotifier<TriplePanaBulkMode> {
  final TriplePanaBulkMode _outputMode = TriplePanaBulkMode();

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

      // Get all triple panna numbers whose sum's last digit matches the selected digit
      final selectedDigit = int.parse(digit);
      final matchingPannaNumbers = triplePannaList.where((panna) {
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
              SelectedTriplePanaBulkModel(
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
          final newSelection = SelectedTriplePanaBulkModel(
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
      log(e.toString(), name: 'TriplePanaBulkNotifier-addPoints');
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
      pannaModel?.text = '';

      totalAll();
      state = AsyncData(_outputMode);
    } catch (e) {
      log(e.toString(), name: 'TriplePanaBulkNotifier-removePoints');
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
        barrierColor: Colors.black54,
        builder: (BuildContext context) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: darkBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.confirmation_number_outlined,
                          color: darkBlue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Confirm Your Bet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.summarize_outlined,
                                size: 16, color: Colors.grey),
                            SizedBox(width: 6),
                            Text(
                              'Bet Summary',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        SizedBox(
                          height: 180,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _outputMode.selectedNumberList.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final bet = _outputMode.selectedNumberList[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: darkBlue.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${bet.points}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: darkBlue,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('${bet.session?.toUpperCase()}'),
                                      ],
                                    ),
                                    Text(
                                      '₹${bet.value}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Bets:',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_outputMode.totalSelectedNumber}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '₹${_outputMode.totalPoints}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkBlue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Submit Bet',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (shouldProceed != true) {
        return;
      }

      EasyLoading.show(status: 'Loading...');

      // Place bets for each selected number
      List<Map<String, dynamic>> jsonDataArray = [
        for (int i = 0; i < _outputMode.selectedNumberList.length; i++)
          {
            "user_id": ref
                    .watch(getParticularPlayerNotifierProvider)
                    .value
                    ?.getParticularPlayerModel
                    ?.data
                    ?.sId ??
                "",
            "session": _outputMode.selectedNumberList[i].session ?? "open",
            "tag": tag,
            "open_digit": "-",
            "close_digit": "-",
            "open_panna": _outputMode.selectedNumberList[i].session == "open"
                ? _outputMode.selectedNumberList[i].points ?? ""
                : "-",
            "close_panna": _outputMode.selectedNumberList[i].session == "close"
                ? _outputMode.selectedNumberList[i].points ?? ""
                : "-",
            "points":
                int.parse(_outputMode.selectedNumberList[i].value.toString()),
            "game_mode": "triple-panna-bulk",
            "market_id": marketId,
          },
      ];

      var result = await ApiService().postPlayGameAllMarket(jsonDataArray);

      if (result?.status == "success") {
        // Play success sound
        AudioPlayer().play(AssetSource(bidsSound));

        ref
            .read(getParticularPlayerNotifierProvider.notifier)
            .getParticularPlayerModel();

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
        await ApiService().getParticularUserData();
      } else {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, result?.message ?? 'Something went wrong');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'TriplePanaBulkNotifier-onSubmitConfirm');
      if (context.mounted) {
        toast(context: context, 'Error placing bids');
      }
    }
  }

  @override
  Future<TriplePanaBulkMode> build() async {
    _outputMode.leftPoints = _outputMode.userParticularPlayer?.wallet ?? 0;
    return _outputMode;
  }
}

class TriplePanaBulkModel {
  TextEditingController? value;
  String? points;
  TriplePanaBulkModel({this.points, this.value});
}

class SelectedTriplePanaBulkModel {
  String? value;
  String? points;
  String? session;
  SelectedTriplePanaBulkModel({this.session, this.points, this.value});
}
