// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:sm_project/controller/apiservices/api_constant.dart';
import 'package:sm_project/controller/model/allow_notification_model.dart';
import 'package:sm_project/controller/model/get_all_market_model.dart';
import 'package:sm_project/controller/model/get_particular_player_model.dart';
import 'package:sm_project/features/home/get_setting_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:url_launcher/url_launcher.dart';

final homeNotifierProvider =
    AsyncNotifierProvider<HomeScreenNotifier, HomeScreenMode>(() {
  return HomeScreenNotifier();
});

class HomeScreenMode {
  String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
  bool isPersonalNotification = true;
  bool? isResultNotification;
  GetParticularPlayerModel? getParticularPlayerModel =
      GetParticularPlayerModel();
  GetAllMarketModel? getAllMarketModel = GetAllMarketModel();
  // A monotonically increasing version used to force Riverpod rebuilds
  // when we mutate nested collections (e.g. append markets for pagination).
  int _version = 0;

  void bumpVersion() => _version++;

  // Equality & hashCode include the version so each bump triggers UI updates
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HomeScreenMode && other._version == _version);

  @override
  int get hashCode => _version.hashCode;

  // String formattedTime = DateFormat('kk:mm').format(DateTime.now());
  String myCurrentDay = DateFormat('EEEE').format(DateTime.now()).toLowerCase();

  // final RefreshController ? refreshController = RefreshController(initialRefresh: false);
  // RefreshController refreshController =
  //     RefreshController(initialRefresh: false);

  AllowNotificationModel? allowNotificationModel = AllowNotificationModel();

  bool isMarketText = false;
}

class HomeScreenNotifier extends AsyncNotifier<HomeScreenMode> {
  final HomeScreenMode _homescreenMode = HomeScreenMode();

  // // Add version checking method
  // void checkAppVersion(BuildContext context, GetSettingModel? settingModel) {
  //   if (settingModel?.data?.appVersion == null ||
  //       settingModel?.data?.appLink == null) {
  //     return;
  //   }

  //   try {
  //     // Get current app version from package info
  //     PackageInfo.fromPlatform().then((packageInfo) {
  //       String currentVersion = packageInfo.version;
  //       String apiVersion = settingModel!.data!.appVersion!;
  //       String appLink = settingModel.data!.appLink!;

  //       log('Current Version: $currentVersion', name: 'Version Check');
  //       log('API Version: $apiVersion', name: 'Version Check');

  //       // Compare versions
  //       if (_isVersionLower(currentVersion, apiVersion)) {
  //         log('Update required: Current $currentVersion < API $apiVersion',
  //             name: 'Version Check');

  //         // Navigate to download screen
  //         if (context.mounted) {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => LocalDownloadWebsite(
  //                 appVersion: apiVersion,
  //                 appLink: ref
  //                         .watch(getSettingNotifierProvider)
  //                         .value
  //                         ?.getSettingModel
  //                         ?.data
  //                         ?.appLink ??
  //                     '',
  //               ),
  //             ),
  //           );
  //         }
  //       } else {
  //         log('App is up to date: Current $currentVersion >= API $apiVersion',
  //             name: 'Version Check');
  //       }
  //     });
  //   } catch (e) {
  //     log('Error checking app version: $e', name: 'Version Check');
  //   }
  // }

  // Helper method to compare version strings
  bool _isVersionLower(String currentVersion, String apiVersion) {
    try {
      List<int> current =
          currentVersion.split('.').map((e) => int.parse(e)).toList();
      List<int> api = apiVersion.split('.').map((e) => int.parse(e)).toList();

      // Pad with zeros if needed
      while (current.length < api.length) current.add(0);
      while (api.length < current.length) api.add(0);

      for (int i = 0; i < current.length; i++) {
        if (current[i] < api[i]) return true;
        if (current[i] > api[i]) return false;
      }
      return false; // Versions are equal
    } catch (e) {
      log('Error comparing versions: $e', name: 'Version Check');
      return false;
    }
  }

  void onRefresh(BuildContext context) async {
    try {
      await Future.delayed(Duration.zero, () {
        getAllMarket(context, reset: true);
        getParticularPlayerModel(context);
        ref.read(getSettingNotifierProvider.notifier).getSettingModel();
      });
    } catch (e) {
      log("$e");
    }
  }

  void showSettingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Settings",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     const Expanded(
              //       child: Text("Personal Notifications",
              //           style: TextStyle(
              //               fontSize: 18,
              //               fontWeight: FontWeight.w600,
              //               color: textColor)),
              //     ),
              //     Text(_homescreenMode.isPersonalNotification ? 'ON' : 'OFF',
              //         style: TextStyle(
              //             fontSize: 18,
              //             fontWeight: FontWeight.w600,
              //             color: _homescreenMode.isPersonalNotification
              //                 ? buttonColor
              //                 : Colors.red)),
              //     const SizedBox(width: 10),
              //     Switch(
              //       value:
              //           Prefs.getBool(PrefNames.isPersonalNotification) ?? true,
              //       onChanged: (bool value) async {
              //         Map<String, bool> body = {
              //           "personal_notification": false,
              //         };
              //         _homescreenMode.allowNotificationModel =
              //             await ApiService().postAllowNotification(body);
              //         if (_homescreenMode.allowNotificationModel?.status ==
              //             "success") {
              //           // set in local storage
              //           Prefs.setBool(PrefNames.isPersonalNotification, value);

              //           context.pop();
              //           toast(_homescreenMode.allowNotificationModel?.message ??
              //               '');
              //           showSettingDialog(context);
              //         } else {
              //           context.pop();
              //           toast(_homescreenMode.allowNotificationModel?.message ??
              //               '');
              //         }
              //       },
              //       activeTrackColor: const Color(0xFFB1E0DA),
              //       activeColor: buttonColor,
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text("Result\nNotifications",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor)),
                  ),
                  Text(
                      Prefs.getBool(PrefNames.isResultNotification) ?? true
                          ? 'ON'
                          : 'OFF',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color:
                              Prefs.getBool(PrefNames.isResultNotification) ??
                                      true
                                  ? buttonColor
                                  : Colors.red)),
                  const SizedBox(width: 10),
                  Switch(
                    value:
                        Prefs.getBool(PrefNames.isResultNotification) ?? true,
                    onChanged: (value) async {
                      Map<String, bool> body = {
                        "result_notification": value,
                      };

                      _homescreenMode.allowNotificationModel =
                          await ApiService().postAllowNotification(body);
                      if (_homescreenMode.allowNotificationModel?.status ==
                          "success") {
                        Prefs.setBool(PrefNames.isResultNotification, value);
                        context.pop();
                        toast(_homescreenMode.allowNotificationModel?.message ??
                            '');
                        showSettingDialog(context);
                      } else {
                        context.pop();
                        toast(_homescreenMode.allowNotificationModel?.message ??
                            '');
                      }
                    },
                    activeTrackColor: const Color(0xFFB1E0DA),
                    activeColor: buttonColor,
                  ),
                ],
              ),
            ],
          ),
          // actions: [
          //   okButton,
          // ],
        );
      },
    );
    state = AsyncData(_homescreenMode);
  }

  String starlineresults(String openPana, String opendDigit) {
    var data = "";
    if (openPana == "-") {
      data = "***";
    } else {
      data = openPana;
    }
    data = "$data-";
    if (opendDigit == "-") {
      data = '$data*';
    } else {
      data = data + opendDigit;
    }
    return data;
  }

  // Get Particular PlayerId user

  Future<void> getParticularPlayerModel(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Loading...');
      _homescreenMode.getParticularPlayerModel =
          await ApiService().getParticularUserData();
      if (_homescreenMode.getParticularPlayerModel?.status == "success") {
        EasyLoading.dismiss();
      } else if (_homescreenMode.getParticularPlayerModel?.status ==
          "failure") {
        EasyLoading.dismiss();
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'getParticularPlayerModel');
    }
    state = AsyncData(_homescreenMode);
  }

  // Get Particular PlayerId user

  void getAllMarket(BuildContext context, {bool reset = true}) async {
    try {
      if (reset) {
        EasyLoading.show(status: 'Loading...');
        if (_homescreenMode.getAllMarketModel != null) {
          _homescreenMode.getAllMarketModel?.data?.clear();
        }
      }

      final result = await ApiService().getAllMarket(tag: "main");

      if (result?.status == "success") {
        if (reset) {
          _homescreenMode.getAllMarketModel = result;
        } else {
          // Append new data to existing list
          _homescreenMode.getAllMarketModel?.data?.addAll(result?.data ?? []);
          _homescreenMode.getAllMarketModel?.total = result?.total;
        }

        // Force rebuild after mutating existing model
        _homescreenMode.bumpVersion();
        // Delay state update to avoid modifying provider during widget building
        Future(() {
          state = AsyncData(_homescreenMode);
        });
        if (reset) EasyLoading.dismiss();
      } else if (result?.status == "failure") {
        if (reset) EasyLoading.dismiss();
        toast("Failed to load markets");
      }
    } catch (e) {
      if (reset) EasyLoading.dismiss();
      log(e.toString(), name: 'getAllMarketModel');
    } finally {
      // Ensure version bump in case of silent failures to trigger possible UI refresh
      _homescreenMode.bumpVersion();
      // Delay state update to avoid modifying provider during widget building
      Future(() {
        state = AsyncData(_homescreenMode);
      });
    }
  }

  // Logout
  Future<void> logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Container(
            height: 50,
            decoration: BoxDecoration(
              color: darkBlue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Center(
              child: Text(
                "Quit",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          titlePadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                logoutBack,
                width: 40,
              ),
              const SizedBox(
                height: 16,
              ),
              const Text("Are you  sure you want to quit"),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        surfaceTintColor: Colors.white,
                        side: BorderSide(color: darkBlue),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text("No"),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        await Prefs.clear();

                        context.go(RouteNames.logInScreen);
                      },
                      child: const Text("Yes"),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

//   bool isTimePassed(String timeString) {
//   List<String> timeComponents = timeString.split(":");
//   int hour = int.parse(timeComponents[0]);
//   int minute = int.parse(timeComponents[1]);

//   TimeOfDay closeTime = TimeOfDay(hour: hour, minute: minute);

//   TimeOfDay currentTime = TimeOfDay.now();

//   // Convert to 12-hour format
//   String closeTimeFormatted =
//       DateFormat.jm().format(DateTime(2022, 1, 1, closeTime.hour, closeTime.minute));

//   String currentTimeFormatted =
//       DateFormat.jm().format(DateTime(2022, 1, 1, currentTime.hour, currentTime.minute));

//   closeTime = TimeOfDay.fromDateTime(DateFormat.jm().parse(closeTimeFormatted));
//   currentTime = TimeOfDay.fromDateTime(DateFormat.jm().parse(currentTimeFormatted));

//   // Compare the target time with the current time
//   if (currentTime.hour > closeTime.hour ||
//       (currentTime.hour == closeTime.hour && currentTime.minute >= closeTime.minute)) {
//     // Time has passed
//     return true;
//   } else {
//     // Time has not passed
//     return false;
//   }
// }

  bool isTimePassed(String timeString) {
    if (timeString == "-" || timeString == "") {
      return false;
    }
    List<String> timeComponents = timeString.split(":");
    int hour = int.parse(timeComponents[0]);
    int minute = int.parse(timeComponents[1]);

    TimeOfDay closeTime = TimeOfDay(hour: hour, minute: minute);

    TimeOfDay currentTime = TimeOfDay.now();
    // Compare the target time with the current time
    if (currentTime.hour > closeTime.hour ||
        (currentTime.hour == closeTime.hour &&
            currentTime.minute >= closeTime.minute)) {
      //Time has passed

      return true;
    } else {
      // Time has not passed

      return false;
    }
  }

  String results(
      String openPana, String opendDigit, String closeDigit, String closePana) {
    var data = "";
    if (openPana == "-") {
      data = "XXX";
    } else {
      data = openPana;
    }
    data = "$data-";
    if (opendDigit == "-") {
      data = '${data}X';
    } else {
      data = data + opendDigit;
    }

    if (closeDigit == "-") {
      data = '${data}X';
    } else {
      data = data + closeDigit;
    }
    data = "$data-";
    if (closePana == "-") {
      data = "${data}XXX";
    } else {
      data = data + closePana;
    }
    return data;
  }

  launchCall(String whatsapp) async {
    var whatsappAndroid = Uri.parse("tel://$whatsapp");
    try {
      if (await canLaunchUrl(whatsappAndroid)) {
        await launchUrl(whatsappAndroid);
      } else {
        EasyLoading.showError('Something went wrong');
      }
    } on Exception {
      EasyLoading.showError('Something went wrong');
    }
  }

  Future<void> launchWhatsapp(String phone) async {
    try {
      // Remove all non-numeric characters
      log(phone, name: 'phone');
      final String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');

      // Validate minimum 10 digits
      if (digits.length < 10) {
        EasyLoading.showError('Invalid phone number');
        return;
      }

      log(digits, name: 'digits');

      // Take last 10 digits (Indian number)
      final String mobile = digits.substring(digits.length - 10);

      final Uri whatsappUri = Uri.parse("https://wa.me/91$mobile");

      final bool launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        EasyLoading.showError('WhatsApp not installed');
      }
    } catch (e) {
      EasyLoading.showError('Unable to open WhatsApp');
    }
  }

  // Telegram

  void launchTelegram(String telegramId) async {
    String url = "https://telegram.me/$telegramId";
    try {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault)) {}
    } on Exception {
      EasyLoading.showError('Telegram is not installed.');
    }
  }

  // Call us
  void callUs(String? callNumber) async {
    String url = 'tel:$callNumber';
    try {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault)) {}
    } on Exception {
      EasyLoading.showError('Something went wrong');
    }
  }

  void launchCalendarView(String marketId) async {
    EasyLoading.show(status: 'Loading...');
    String url = "${APIConstants.websiteUrl}pana0b8c.html?market=$marketId";
    try {
      EasyLoading.dismiss();
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault)) {}
    } on Exception {
      EasyLoading.dismiss();
      EasyLoading.showError('Something went wrong');
    }
    EasyLoading.dismiss();
  }

  // Starline
  void launchStarlineCalendarView() async {
    EasyLoading.show(status: 'Loading...');
    String url = "${APIConstants.websiteUrl}starline";
    try {
      EasyLoading.dismiss();
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault)) {}
    } on Exception {
      EasyLoading.dismiss();
      EasyLoading.showError('Something went wrong');
    }
    EasyLoading.dismiss();
  }

  // Website Open
  void launchWebsite() async {
    EasyLoading.show(status: 'Loading...');
    String url = APIConstants.websiteUrl;
    try {
      EasyLoading.dismiss();
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault)) {}
    } on Exception {
      EasyLoading.dismiss();
      EasyLoading.showError('Something went wrong');
    }
    EasyLoading.dismiss();
  }

  // Rate Us
  Future<void> appPlayStoreLauncher(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  void updateContainerSize(int index) {
    state = AsyncData(_homescreenMode);
  }

  void updateEndContainerSize(int index) {
    state = AsyncData(_homescreenMode);
  }

  @override
  build() {
    return _homescreenMode;
  }
}
