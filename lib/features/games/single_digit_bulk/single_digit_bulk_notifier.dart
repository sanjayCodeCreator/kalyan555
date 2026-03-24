import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/controller/model/single_digit_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/kalyan_morning_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

final singleDigitBulkNotifierProvider = AsyncNotifierProvider.autoDispose<
    SingleDigitBulkNotifier, SingleDigitBulkMode>(() {
  return SingleDigitBulkNotifier();
});

class SingleDigitBulkMode {
  final userParticularPlayer = UserParticularPlayer.getParticularUserData();
  String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
  int? startDigit = 0;

  List<SelectedSingleDigitBulkModel> selectedNumberList = [];
  int? totalSelectedNumber = 0;
  int totalPoints = 0;
  int? leftPoints;
  TextEditingController enteredPoints = TextEditingController(text: "");

  String? openDigit;
  String? closeDigit;

  GetSettingModel? getSettingModel = GetSettingModel();

  List<SingleDigitBulkModel> singleDigitNewModel = [
    SingleDigitBulkModel(value: TextEditingController(), points: "0"),
    SingleDigitBulkModel(value: TextEditingController(), points: "1"),
    SingleDigitBulkModel(value: TextEditingController(), points: "2"),
    SingleDigitBulkModel(value: TextEditingController(), points: "3"),
    SingleDigitBulkModel(value: TextEditingController(), points: "4"),
    SingleDigitBulkModel(value: TextEditingController(), points: "5"),
    SingleDigitBulkModel(value: TextEditingController(), points: "6"),
    SingleDigitBulkModel(value: TextEditingController(), points: "7"),
    SingleDigitBulkModel(value: TextEditingController(), points: "8"),
    SingleDigitBulkModel(value: TextEditingController(), points: "9"),
  ];
}

class SingleDigitBulkNotifier
    extends AutoDisposeAsyncNotifier<SingleDigitBulkMode> {
  final SingleDigitBulkMode _outputMode = SingleDigitBulkMode();

  void updateEnteredPoints(String point) {
    _outputMode.enteredPoints.text = point;
  }

  void setStartDigit(int number) {
    for (int i = 0; i < _outputMode.singleDigitNewModel.length; i++) {
      _outputMode.singleDigitNewModel[i].value?.text = '';
      _outputMode.singleDigitNewModel[i].points = '';
    }
    _outputMode.startDigit = number;
    state = AsyncData(_outputMode);
  }

  Future<bool> addPoints(BuildContext context, String number) async {
    try {
      FocusScope.of(context).unfocus();
      EasyLoading.show(status: 'Loading...');

      _outputMode.getSettingModel = await ApiService().getSettingModel();
      final walletAmount = _outputMode.userParticularPlayer?.wallet;

      if (((walletAmount ?? -1) <
          int.parse(_outputMode.enteredPoints.text).abs())) {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, 'Wallet Amount is Low');
        }
        await totalAll();
        return false;
      }

      _outputMode.singleDigitNewModel
          .firstWhere((element) => element.points == number)
          .value
          ?.text = _outputMode.singleDigitNewModel
                  .firstWhere((element) => element.points == number)
                  .value
                  ?.text
                  .isNotEmpty ??
              false
          ? (int.parse(
                    _outputMode.singleDigitNewModel
                            .firstWhere(
                              (element) => element.points == number,
                            )
                            .value
                            ?.text ??
                        "0",
                  ) +
                  int.parse(_outputMode.enteredPoints.text))
              .toString()
          : _outputMode.enteredPoints.text;

      if (_outputMode.singleDigitNewModel.isNotEmpty) {
        _outputMode.selectedNumberList.clear();
        for (var element in _outputMode.singleDigitNewModel) {
          if (element.value?.text.trim() != '') {
            _outputMode.selectedNumberList.add(
              SelectedSingleDigitBulkModel(
                points: element.points,
                value: element.value?.text,
                session:
                    (ref.watch(kalyanMorningNotifierProvider).value?.isClose ??
                            false)
                        ? "close"
                        : "open",
              ),
            );
          }
        }
        EasyLoading.dismiss();
        state = AsyncData(_outputMode);
        await totalAll();
      } else {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, 'No entry found');
        }
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'SingleDigitBulkModel');
      return false;
    }

    EasyLoading.dismiss();
    state = AsyncData(_outputMode);
    return true;
  }

  void removePoints(BuildContext context, String point) async {
    if (_outputMode.selectedNumberList.isNotEmpty) {
      _outputMode.selectedNumberList.remove(
        _outputMode.selectedNumberList.firstWhere(
          (element) => element.points == point,
        ),
      );
      _outputMode.singleDigitNewModel
          .firstWhere((element) => element.points == point)
          .value
          ?.text = '';
      await totalAll();
    } else {
      toast(context: context, 'No entry found');
    }
    state = AsyncData(_outputMode);
  }

  // Delete All
  void deleteAll(BuildContext context) {
    if (_outputMode.selectedNumberList.isNotEmpty) {
      _outputMode.selectedNumberList.clear();
      for (int i = 0; i < _outputMode.singleDigitNewModel.length; i++) {
        _outputMode.singleDigitNewModel[i].value?.text = '';
      }
      totalAll();
    } else {
      toast(context: context, 'No entry found');
    }

    state = AsyncData(_outputMode);
  }

  // clear selectedNumberList
  void clearSelectedNumberList() {
    for (int i = 0; i < _outputMode.singleDigitNewModel.length; i++) {
      _outputMode.singleDigitNewModel[i].value?.text = '';
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
      _outputMode.getSettingModel = await ApiService().getSettingModel();
      int minimumBidAmount =
          _outputMode.getSettingModel?.data?.betting?.min ?? 0;

      if (_outputMode.totalPoints < minimumBidAmount) {
        if (context.mounted) {
          toast(context: context, 'Minimum bid amount is ₹ $minimumBidAmount');
        }
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
                              itemCount: _outputMode.selectedNumberList.length,
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
                                              color: darkBlue.withOpacity(0.1),
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
              "session": _outputMode.selectedNumberList[i].session,
              "tag": tag,
              "open_digit": _outputMode.selectedNumberList[i].session == "open"
                  ? _outputMode.selectedNumberList[i].points
                  : "-",
              "close_digit": _outputMode.selectedNumberList[i].session == "open"
                  ? "-"
                  : _outputMode.selectedNumberList[i].points,
              "open_panna": "-",
              "close_panna": "-",
              "points":
                  int.parse(_outputMode.selectedNumberList[i].value.toString()),
              "game_mode": "single-digit",
              "market_id": marketId,
            },
        ];

        PlayGameAllMarketModel? result =
            await ApiService().postPlayGameAllMarket(jsonDataArray);

        if (result?.status == "success") {
          AudioPlayer().play(AssetSource(bidsSound));
          for (int i = 0; i < _outputMode.singleDigitNewModel.length; i++) {
            _outputMode.singleDigitNewModel[i].value?.text = '';
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
        log(e.toString(), name: 'SingleDigitBulkModel');
      }
    } else {
      toast(context: context, 'No entry found');
    }
  }

  // function total Number
  Future<void> totalAll() async {
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
  Future<SingleDigitBulkMode> build() async {
    _outputMode.leftPoints = _outputMode.userParticularPlayer?.wallet ?? 0;
    return _outputMode;
  }
}

class SingleDigitBulkModel {
  TextEditingController? value;
  String? points;
  SingleDigitBulkModel({this.points, this.value});
}

class SelectedSingleDigitBulkModel {
  String? value;
  String? points;
  String? session;
  SelectedSingleDigitBulkModel({this.session, this.points, this.value});
}
