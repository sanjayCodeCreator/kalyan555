import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/jodi_digit/jodi_digit_list.dart';
import 'package:sm_project/utils/filecollection.dart';

final jodiBulkNotifierProvider =
    AsyncNotifierProvider.autoDispose<JodiBulkNotifier, JodiBulkMode>(() {
  return JodiBulkNotifier();
});

class JodiBulkMode {
  final userParticularPlayer = UserParticularPlayer.getParticularUserData();
  String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
  int? startDigit = 0;
  TextEditingController enteredPoints = TextEditingController(text: "");
  TextEditingController enteredNumber = TextEditingController(text: "");

  List<SelectedJodiBulkModel> selectedNumberList = [];
  int? totalSelectedNumber = 0;
  int totalPoints = 0;
  int? leftPoints;

  String? openDigit;
  String? closeDigit;

  GetSettingModel? getSettingModel = GetSettingModel();

  List<JodiBulkModel> jodiModel = [
    JodiBulkModel(value: TextEditingController()),
    JodiBulkModel(value: TextEditingController()),
    JodiBulkModel(value: TextEditingController()),
    JodiBulkModel(value: TextEditingController()),
    JodiBulkModel(value: TextEditingController()),
    JodiBulkModel(value: TextEditingController()),
    JodiBulkModel(value: TextEditingController()),
    JodiBulkModel(value: TextEditingController()),
    JodiBulkModel(value: TextEditingController()),
    JodiBulkModel(value: TextEditingController()),
  ];
}

class JodiBulkNotifier extends AutoDisposeAsyncNotifier<JodiBulkMode> {
  final JodiBulkMode _outputMode = JodiBulkMode();

  void updateEnteredPoints(String point) {
    _outputMode.enteredPoints.text = point;
  }

  void updateEnteredNumber(String value) {
    _outputMode.enteredNumber.text = value;
  }

  void setStartDigit(int number) {
    for (int i = 0; i < _outputMode.jodiModel.length; i++) {
      _outputMode.jodiModel[i].value?.text = '';
      _outputMode.jodiModel[i].points = '';
    }
    _outputMode.startDigit = number;
    state = AsyncData(_outputMode);
  }

  void addPoints(BuildContext context) async {
    try {
      FocusScope.of(context).unfocus();
      if (true) {
        if (!jodiDigitList.contains(_outputMode.enteredNumber.text)) {
          toast(context: context, "Jodi Number is Incorrect");
          return;
        }
      }
      EasyLoading.show(status: 'Loading...');
      int totalAddPoints = 0;
      totalAddPoints = _outputMode.enteredPoints.text.isEmpty
          ? 0
          : (int.tryParse(_outputMode.enteredPoints.text) ?? 0).abs();
      _outputMode.jodiModel.first = JodiBulkModel(
        value: TextEditingController(text: _outputMode.enteredPoints.text),
        points: _outputMode.enteredNumber.text,
      );

      for (final element in _outputMode.jodiModel) {
        if (element.value?.text.trim().isNotEmpty ?? false) {
          totalAddPoints =
              (int.tryParse(element.value?.text ?? '0') ?? 0).abs();
        }
      }
      EasyLoading.dismiss();
      final walletAmount = _outputMode.userParticularPlayer?.wallet;
      if (totalAddPoints == 0) {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, 'Invalid enter number');
        }
        return;
      } else if ((walletAmount ?? -1) < totalAddPoints || totalAddPoints == 0) {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, 'Wallet Amount is Low');
        }
        return;
      }
      if (_outputMode.jodiModel.isNotEmpty) {
        for (var element in _outputMode.jodiModel) {
          if (element.value?.text.trim() != '') {
            _outputMode.selectedNumberList.add(
              SelectedJodiBulkModel(
                points: element.points,
                value: element.value?.text,
              ),
            );
          }
        }
        EasyLoading.dismiss();
        totalAll();
      } else {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, 'No entry found');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'jodiDigitModel');
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
      toast(context: context, 'No entry found');
    }
    state = AsyncData(_outputMode);
  }

  // Delete All
  void deleteAll(BuildContext context) {
    if (_outputMode.selectedNumberList != []) {
      _outputMode.selectedNumberList.clear();
      // _outputMode.singleDigitList.clear();
      totalAll();
    } else {
      toast(context: context, 'No entry found');
    }

    state = AsyncData(_outputMode);
  }

  // clear selectedNumberList
  void clearSelectedNumberList() {
    _outputMode.enteredNumber.clear();
    // _outputMode.enteredPoints.clear();
    for (int i = 0; i < _outputMode.jodiModel.length; i++) {
      _outputMode.jodiModel[i].value?.text = '';
      _outputMode.jodiModel[i].points = '';
    }
    state = AsyncData(_outputMode);
  }

  void clearConfirmNumberList() {
    _outputMode.selectedNumberList.clear();
    _outputMode.totalSelectedNumber = 0;
    _outputMode.totalPoints = 0;
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
        if (context.mounted) {
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                            child:  Icon(
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
                                itemCount:
                                    _outputMode.selectedNumberList.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final bet =
                                      _outputMode.selectedNumberList[index];
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
                                                color:
                                                    darkBlue.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '${bet.points}',
                                                style:  TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: darkBlue,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text('JODI'),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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

          for (int i = 0; i < _outputMode.jodiModel.length; i++) {
            _outputMode.jodiModel[i].value?.text = '';
            _outputMode.jodiModel[i].points = '';
          }

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
          await ApiService().getParticularUserData();
        } else {
          EasyLoading.dismiss();
          if (context.mounted) {
            toast(context: context, result?.message ?? 'Something went wrong');
          }
        }
      } catch (e) {
        EasyLoading.dismiss();
        log(e.toString(), name: 'jodiDigitModel');
      }
    } else {
      toast(context: context, 'No entry found');
    }
  }

  // function total Number
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
  Future<JodiBulkMode> build() async {
    _outputMode.leftPoints = _outputMode.userParticularPlayer?.wallet ?? 0;
    return _outputMode;
  }
}

class JodiBulkModel {
  TextEditingController? value;
  String? points;
  JodiBulkModel({this.points, this.value});
}

class SelectedJodiBulkModel {
  String? value;
  String? points;
  SelectedJodiBulkModel({this.points, this.value});
}
