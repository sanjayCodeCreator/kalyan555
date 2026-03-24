import 'package:sm_project/controller/model/contact_us_model.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:url_launcher/url_launcher.dart';

final getContactUsNotifierProvider =
    AsyncNotifierProvider.autoDispose<GetContactUsNotifier, GetContactUsMode>(
        () {
  return GetContactUsNotifier();
});

class GetContactUsMode {
  ContactUsModel? getContactUsModel = ContactUsModel();
}

class GetContactUsNotifier extends AutoDisposeAsyncNotifier<GetContactUsMode> {
  final GetContactUsMode _getContactUsModel = GetContactUsMode();

  // // Get Particular PlayerId user

  // void getContactUsModelModel() async {
  //   try {
  //     EasyLoading.show(status: 'Loading...');
  //     _getContactUsModel.getContactUsModel =
  //         await ApiService().getNeedHelpUser();
  //     if (_getContactUsModel.getContactUsModel?.status == "success") {
  //       EasyLoading.dismiss();
  //     } else if (_getContactUsModel.getContactUsModel?.status == "failure") {
  //       EasyLoading.dismiss();
  //       // toast(loginModel?.message ?? '');
  //     }
  //   } catch (e) {
  //     EasyLoading.dismiss();
  //     log(e.toString(), name: '_getContactUsModel');
  //   }
  //   state = AsyncData(_getContactUsModel);
  // }

  launchWhatsapp({String? message}) async {
    EasyLoading.show(status: 'Loading...');

    try {
      await ApiService().getNeedHelpUser();

      _getContactUsModel.getContactUsModel =
          await ApiService().getNeedHelpUser();
      if (_getContactUsModel.getContactUsModel?.status == "success") {
        EasyLoading.dismiss();
        final String number =
            _getContactUsModel.getContactUsModel?.whatsapp ?? '';
        final String lastTenDigits =
            number.isNotEmpty ? number.substring(number.length - 10) : '';
        final String encodedMessage = (message != null && message.isNotEmpty)
            ? Uri.encodeComponent(message)
            : '';
        final String url = encodedMessage.isNotEmpty
            ? "https://wa.me/91$lastTenDigits?text=$encodedMessage"
            : "https://wa.me/91$lastTenDigits";
        var whatsappAndroid = Uri.parse(url);

        if (await canLaunchUrl(whatsappAndroid)) {
          await launchUrl(whatsappAndroid);
        } else {
          EasyLoading.dismiss();
          EasyLoading.showError('Something went wrong');
        }
      }
    } on Exception {
      EasyLoading.dismiss();
      EasyLoading.showError('Something went wrong');
    }
  }

  void callUs() async {
    EasyLoading.show(status: 'Loading...');

    try {
      _getContactUsModel.getContactUsModel =
          await ApiService().getNeedHelpUser();
      if (_getContactUsModel.getContactUsModel?.status == "success") {
        EasyLoading.dismiss();
        String url = 'tel:${_getContactUsModel.getContactUsModel?.mobile}';
        if (!await launchUrl(Uri.parse(url),
            mode: LaunchMode.platformDefault)) {}
      }
    } on Exception {
      EasyLoading.dismiss();
      EasyLoading.showError('Something went wrong');
    }
  }

  @override
  build() {
    return _getContactUsModel;
  }
}
