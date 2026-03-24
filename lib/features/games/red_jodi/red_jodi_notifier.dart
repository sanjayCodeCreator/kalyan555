import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

final redJodiNotifierProvider =
    AsyncNotifierProvider.autoDispose<RedJodiNotifier, RedJodiMode>(() {
  return RedJodiNotifier();
});

class RedJodiMode {
  final userParticularPlayer = UserParticularPlayer.getParticularUserData();
  String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
  int? startDigit = 1;

  List<SelectedRedJodiModel> selectedNumberList = [];
  int? totalSelectedNumber = 0;
  int totalPoints = 0;
  int? leftPoints;

  GetSettingModel? getSettingModel = GetSettingModel();

  List<RedJodiModel> redJodiModel = [
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
    RedJodiModel(value: TextEditingController()),
  ];

  List<RedJodiModel> numbers = [
    RedJodiModel(value: TextEditingController(), points: '00'),
    RedJodiModel(value: TextEditingController(), points: '05'),
    RedJodiModel(value: TextEditingController(), points: '11'),
    RedJodiModel(value: TextEditingController(), points: '16'),
    RedJodiModel(value: TextEditingController(), points: '22'),
    RedJodiModel(value: TextEditingController(), points: '27'),
    RedJodiModel(value: TextEditingController(), points: '33'),
    RedJodiModel(value: TextEditingController(), points: '38'),
    RedJodiModel(value: TextEditingController(), points: '44'),
    RedJodiModel(value: TextEditingController(), points: '49'),
    RedJodiModel(value: TextEditingController(), points: '50'),
    RedJodiModel(value: TextEditingController(), points: '55'),
    RedJodiModel(value: TextEditingController(), points: '61'),
    RedJodiModel(value: TextEditingController(), points: '66'),
    RedJodiModel(value: TextEditingController(), points: '72'),
    RedJodiModel(value: TextEditingController(), points: '77'),
    RedJodiModel(value: TextEditingController(), points: '83'),
    RedJodiModel(value: TextEditingController(), points: '88'),
    RedJodiModel(value: TextEditingController(), points: '94'),
    RedJodiModel(value: TextEditingController(), points: '99'),
  ];
}

class RedJodiNotifier extends AutoDisposeAsyncNotifier<RedJodiMode> {
  final RedJodiMode _outputMode = RedJodiMode();

  void addPoints(BuildContext context) async {
    try {
      FocusScope.of(context).unfocus();
      EasyLoading.show(status: 'Loading...');
      int totalAddPoints = 0;
      for (var element in _outputMode.numbers) {
        if (element.value?.text.trim() != '') {
          totalAddPoints = int.parse(element.value?.text ?? '0').abs();
        }
      }
      EasyLoading.dismiss();

      final walletAmount = _outputMode.userParticularPlayer?.wallet ?? 0;
      if (totalAddPoints == 0) {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, 'Invalid enter number');
        }
        return;
      } else if (walletAmount < totalAddPoints || totalAddPoints == 0) {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, 'Wallet Amount is Low');
        }
        return;
      }

      // Check if total points are within the allowed min/max range
      _outputMode.getSettingModel = await ApiService().getSettingModel();
      int minimumBidAmount =
          _outputMode.getSettingModel?.data?.betting?.min ?? 0;

      if (minimumBidAmount > totalAddPoints) {
        EasyLoading.dismiss();
        clearSelectedNumberList();
        if (context.mounted) {
          toast(context: context, 'Minimum bet amount is $minimumBidAmount');
        }
        return;
      }

      if (_outputMode.numbers.isNotEmpty) {
        for (var element in _outputMode.numbers) {
          if (element.value?.text.trim() != '') {
            _outputMode.selectedNumberList.add(
              SelectedRedJodiModel(
                points: element.points,
                value: element.value?.text,
                isClosed: false,
              ),
            );
          }
        }
        EasyLoading.dismiss();
        totalAll();
      } else {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, 'Please select number and add points');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'red-jodi');
    }

    EasyLoading.dismiss();
    clearSelectedNumberList();
    state = AsyncData(_outputMode);
  }

  void removePoints(BuildContext context, int index) {
    if (_outputMode.selectedNumberList != []) {
      _outputMode.selectedNumberList.remove(
        _outputMode.selectedNumberList.elementAt(index),
      );

      totalAll();
    } else {
      toast(context: context, 'Please select number and add points');
    }
    state = AsyncData(_outputMode);
  }

  void deleteAll(BuildContext context) {
    if (_outputMode.selectedNumberList != []) {
      _outputMode.selectedNumberList.clear();
      totalAll();
    } else {
      toast(context: context, 'Please select number and add points');
    }
    state = AsyncData(_outputMode);
  }

  void clearSelectedNumberList() {
    for (int i = 0; i < _outputMode.numbers.length; i++) {
      _outputMode.numbers[i].value?.text = '';
    }
    state = AsyncData(_outputMode);
  }

  void clearConfirmNumberList() {
    _outputMode.selectedNumberList.clear();
    totalAll();
    state = AsyncData(_outputMode);
  }

  void onSubmitConfirm(
    BuildContext context,
    String tag,
    String marketId,
  ) async {
    if (_outputMode.selectedNumberList.isNotEmpty) {
      try {
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Red Jodi: ${bet.points}'),
                                  Text('Points: ₹${bet.value}'),
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
              "session": "close",
              "tag": tag,
              "open_digit": _outputMode.selectedNumberList[i].points
                      ?.substring(0, 1)
                      .toString() ??
                  "",
              "close_digit": _outputMode.selectedNumberList[i].points
                      ?.substring(1, 2)
                      .toString() ??
                  "",
              "open_panna": "-",
              "close_panna": "-",
              "points":
                  int.parse(_outputMode.selectedNumberList[i].value.toString()),
              "game_mode": "double-digit",
              "market_id": marketId,
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
          await ApiService().getParticularUserData();
        } else {
          EasyLoading.dismiss();
          if (context.mounted) {
            toast(context: context, result?.message ?? 'Something went wrong');
          }
        }
      } catch (e) {
        EasyLoading.dismiss();
        log(e.toString(), name: 'red-jodi');
      }
    } else {
      toast(context: context, 'No entry found');
    }
  }

  void totalAll() {
    _outputMode.totalPoints = _outputMode.selectedNumberList.fold(
      0,
      (a, b) => a + int.parse(b.value!),
    );
    _outputMode.totalSelectedNumber = _outputMode.selectedNumberList.length;
    _outputMode.leftPoints = (_outputMode.userParticularPlayer?.wallet ?? 0) -
        _outputMode.totalPoints;
    state = AsyncData(_outputMode);
  }

  @override
  Future<RedJodiMode> build() async {
    _outputMode.leftPoints = _outputMode.userParticularPlayer?.wallet ?? 0;
    return _outputMode;
  }
}

class RedJodiModel {
  TextEditingController? value;
  String? points;
  RedJodiModel({this.points, this.value});
}

class SelectedRedJodiModel {
  String? value;
  String? points;
  bool? isClosed;
  SelectedRedJodiModel({this.points, this.value, this.isClosed});
}
