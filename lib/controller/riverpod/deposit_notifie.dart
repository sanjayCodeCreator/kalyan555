
// import 'package:sm_project/utils/filecollection.dart';

// final depositNotifierProvider =
//     AsyncNotifierProvider.autoDispose<DepositNotifier, DepositMode>(() {
//   return DepositNotifier();
// });

// class DepositMode {
//   final GlobalKey<FormState> formDepositKey = GlobalKey<FormState>();

//   // bool isSelected = false;
  
// }

// class DepositNotifier extends AutoDisposeAsyncNotifier<DepositMode> {
//   final DepositMode _outputMode = DepositMode();

//   // Api Submit

//   //  Future<void> getProfileData(BuildContext context) async {
//   //   try {
//   //     EasyLoading.show(status: 'Loading...');

//   //     // Map<String, dynamic> body = {
//   //     //   'user_name': _editProfileMode.nameController.text,
//   //     //   'email': _editProfileMode.emailController.text
//   //     // };

//   //     log(body.toString());
//   //     ProfileUpdateModel? response = await ApiService().postCreateTransaction(body);
//   //     if (response?.status == 'success') {
//   //       _editProfileMode.userDgetParticularUserData?.userName =
//   //           _editProfileMode.nameController.text;
//   //       _editProfileMode.userDgetParticularUserData?.email =
//   //           _editProfileMode.emailController.text;
//   //       EasyLoading.dismiss();
//   //       toast(response?.message ?? '');
//   //       context.pushNamed(RouteNames.homeScreen);
//   //     } else {
//   //       EasyLoading.dismiss();
//   //       toast(response?.message ?? '');
//   //     }
//   //   } catch (e) {
//   //     EasyLoading.dismiss();
//   //     log(e.toString(), name: 'editProfileApi');
//   //   }
//   //   state = AsyncData(_editProfileMode);
//   // }


//   @override
//   build() {
//     return _outputMode;
//   }
// }
