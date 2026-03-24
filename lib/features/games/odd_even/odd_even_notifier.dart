import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/kalyan_morning_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

final oddEvenNotifierProvider =
    AsyncNotifierProvider.autoDispose<OddEvenNotifier, OddEvenMode>(() {
  return OddEvenNotifier();
});

class OddEvenMode {
  final userParticularPlayer = UserParticularPlayer.getParticularUserData();
  String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
  int? startDigit = 1;
  TextEditingController enteredPoints = TextEditingController(text: "");
  TextEditingController enteredNumber = TextEditingController(text: "");

  int? totalSelectedNumber = 0;
  int totalPoints = 0;
  int? leftPoints;

  String? selectedOption = 'Odd';
  List<String> selectedNumberList = [];
  List<String> selectedNumbers = [];
  List<String> sessionList = [];
  int totalNumber = 0;

  GetSettingModel? getSettingModel = GetSettingModel();
}

class OddEvenNotifier extends AutoDisposeAsyncNotifier<OddEvenMode> {
  final OddEvenMode _outputMode = OddEvenMode();

  void handleEvenChanged(String? value) {
    _outputMode.selectedOption = value;
    state = AsyncData(_outputMode);
  }

  // Add
  void addPoints(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (_outputMode.enteredPoints.text.isEmpty) {
      toast(context: context, "Please Enter Number");
      return;
    }

    int enteredPoints = int.parse(_outputMode.enteredPoints.text).abs();
    if (enteredPoints < 0) {
      toast(context: context, "Please Enter Valid Number");
      return;
    }

    // Calculate total amount (5 numbers × entered points)
    int totalAmount = enteredPoints * 5;

    final walletAmount = _outputMode.userParticularPlayer?.wallet ?? 0;
    if (walletAmount < totalAmount || enteredPoints <= 0) {
      if (context.mounted) {
        toast(
          context: context,
          'Insufficient wallet balance for total bet amount',
        );
      }
      return;
    }

    _outputMode.selectedNumbers.clear();
    _outputMode.selectedNumberList.clear();
    _outputMode.sessionList.clear();

    // Assign odd/even list based on selection
    List<String> numbersToAdd = [];
    if (_outputMode.selectedOption == 'Odd') {
      numbersToAdd = ['1', '3', '5', '7', '9'];
    } else if (_outputMode.selectedOption == 'Even') {
      numbersToAdd = ['0', '2', '4', '6', '8'];
    }

    // Check if total points are within the allowed min/max range
    _outputMode.getSettingModel = await ApiService().getSettingModel();
    int minimumBidAmount = _outputMode.getSettingModel?.data?.betting?.min ?? 0;

    if (minimumBidAmount > enteredPoints) {
      EasyLoading.dismiss();
      if (context.mounted) {
        toast(context: context, 'Minimum bet amount is $minimumBidAmount');
      }
      return;
    }

    // Add points for each number
    for (String number in numbersToAdd) {
      _outputMode.selectedNumberList.add(_outputMode.enteredPoints.text);
      _outputMode.selectedNumbers.add(number);
      if (ref.watch(kalyanMorningNotifierProvider).value?.isClose == true) {
        _outputMode.sessionList.add("close");
      } else {
        _outputMode.sessionList.add("open");
      }
    }

    // Calculate total number
    _outputMode.totalNumber = enteredPoints * numbersToAdd.length;

    totalAll();
    _outputMode.enteredPoints.clear();
    state = AsyncData(_outputMode);
  }

  // remove points
  void removePoints(BuildContext context, int index) {
    if (_outputMode.selectedNumberList.isNotEmpty) {
      _outputMode.selectedNumberList.removeAt(index);
      _outputMode.selectedNumbers.removeAt(index);
      _outputMode.sessionList.removeAt(index);
    }

    totalAll();
    state = AsyncData(_outputMode);
  }

  void totalAll() {
    _outputMode.totalPoints = _outputMode.selectedNumberList.fold(
      0,
      (a, b) => a + int.parse(b),
    );
    _outputMode.totalSelectedNumber = _outputMode.selectedNumberList.length;
    _outputMode.totalNumber = _outputMode.totalPoints;

    _outputMode.leftPoints = (_outputMode.userParticularPlayer?.wallet ?? 0) -
        _outputMode.totalPoints;

    state = AsyncData(_outputMode);
  }

  // Delete All
  void deleteAll(BuildContext context) {
    if (_outputMode.selectedNumberList.isNotEmpty) {
      _outputMode.selectedNumberList.clear();
      _outputMode.selectedNumbers.clear();
      _outputMode.sessionList.clear();
      _outputMode.totalNumber = 0;
    }

    state = AsyncData(_outputMode);
  }

  void onSubmitConfirm(BuildContext context, String tag, String id) async {
    if (_outputMode.selectedNumberList.isNotEmpty) {
      _outputMode.getSettingModel = await ApiService().getSettingModel();
      int minimumBidAmount =
          _outputMode.getSettingModel?.data?.betting?.min ?? 0;
      if (_outputMode.totalNumber < minimumBidAmount) {
        if (context.mounted) {
          toast(context: context, 'Minimum bid amount is ₹ $minimumBidAmount');
        }
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
                        for (int i = 0;
                            i < _outputMode.selectedNumberList.length;
                            i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Type: ${_outputMode.selectedNumbers[i]}'),
                                Text(
                                  'Points: ₹${_outputMode.selectedNumberList[i]}',
                                ),
                                Text(_outputMode.sessionList[i]),
                              ],
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
                              '₹${_outputMode.totalNumber}',
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

      try {
        EasyLoading.show(status: 'Loading...');

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
              "session": _outputMode.sessionList[i],
              "tag": tag,
              "open_digit": _outputMode.sessionList[i] == "open"
                  ? _outputMode.selectedNumbers[i]
                  : "-",
              "close_digit": _outputMode.sessionList[i] == "close"
                  ? _outputMode.selectedNumbers[i]
                  : "-",
              "open_panna": "-",
              "close_panna": "-",
              "points": int.parse(_outputMode.selectedNumberList[i]),
              "game_mode": "even-odd-digit",
              "market_id": id,
            },
        ];

        var result = await ApiService().postPlayGameAllMarket(jsonDataArray);

        if (result?.status == "success") {
          AudioPlayer().play(AssetSource(bidsSound));
          EasyLoading.dismiss();

          ref
              .read(getParticularPlayerNotifierProvider.notifier)
              .getParticularPlayerModel();

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
                                '₹${_outputMode.totalNumber}',
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
          if (context.mounted) {
            deleteAll(context);
            await ApiService().getParticularUserData();
          }
        } else {
          EasyLoading.dismiss();
          if (context.mounted) {
            toast(context: context, result?.message ?? 'Something went wrong');
          }
        }
      } catch (e) {
        EasyLoading.dismiss();
        log(e.toString(), name: 'OddEvenNotifier');
      }
    } else {
      toast(context: context, 'No entry found');
    }
  }

  @override
  Future<OddEvenMode> build() async {
    _outputMode.leftPoints = _outputMode.userParticularPlayer?.wallet ?? 0;
    return _outputMode;
  }
}
