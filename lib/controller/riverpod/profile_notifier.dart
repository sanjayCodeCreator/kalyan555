// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_particular_player_model.dart';
import 'package:sm_project/controller/model/profile_update_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

final editProfileNotifierProvider =
    AsyncNotifierProvider.autoDispose<EditProfileNotifier, EditProfileMode>(() {
  return EditProfileNotifier();
});

class EditProfileMode {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  final Data? userDgetParticularUserData =
      UserParticularPlayer.getParticularUserData();
}

class EditProfileNotifier extends AutoDisposeAsyncNotifier<EditProfileMode> {
  final EditProfileMode _editProfileMode = EditProfileMode();

  void setData() {
    EasyLoading.show(status: 'Loading...');
    _editProfileMode.nameController.text =
        _editProfileMode.userDgetParticularUserData?.userName ?? '';
    _editProfileMode.mobileController.text =
        _editProfileMode.userDgetParticularUserData?.mobile ?? '';
    EasyLoading.dismiss();
  }

  Future<void> getProfileData(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Loading...');
      await ref
          .read(getParticularPlayerNotifierProvider.notifier)
          .getParticularPlayerModel();

      Map<String, dynamic> body = {
        "id": ref
                .watch(getParticularPlayerNotifierProvider)
                .value
                ?.getParticularPlayerModel
                ?.data
                ?.sId ??
            "",
        'user_name': _editProfileMode.nameController.text,
        'email': _editProfileMode.emailController.text
      };

      log(body.toString());
      ProfileUpdateModel? response = await ApiService().postProfileUpdate(body);
      if (response?.status == 'success') {
        _editProfileMode.userDgetParticularUserData?.userName =
            _editProfileMode.nameController.text;
        EasyLoading.dismiss();
        toast(response?.message ?? '');
        context.pushNamed(RouteNames.homeScreen);
      } else {
        EasyLoading.dismiss();
        toast(response?.message ?? '');
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'editProfileApi');
    }
    state = AsyncData(_editProfileMode);
  }

  // Future<void> showModal(BuildContext context) {
  //   return showModalBottomSheet(
  //       context: context,
  //       builder: (context) {
  //         return Wrap(
  //           children: [
  //             ListTile(
  //               leading: const Icon(Icons.camera_alt),
  //               title: const Text('Camera'),
  //               onTap: () {
  //                 context.pop();
  //                 getImageFromCamera();
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.photo),
  //               title: const Text('Gallery'),
  //               onTap: () {
  //                 context.pop();
  //                 getImageFromGallery();
  //               },
  //             ),
  //           ],
  //         );
  //       });
  // }

  // //Image Picker function to get image from gallery
  // Future getImageFromGallery() async {
  //   final pickedFile = await _editProfileMode.picker
  //       .pickImage(source: ImageSource.gallery, imageQuality: 20);

  //   if (pickedFile != null) {
  //     _editProfileMode.image = File(pickedFile.path);
  //     log(_editProfileMode.image?.path as String);
  //   }
  //   state = AsyncData(_editProfileMode);
  // }

// //Image Picker function to get image from camera
//   Future getImageFromCamera() async {
//     final pickedFile = await _editProfileMode.picker
//         .pickImage(source: ImageSource.camera, imageQuality: 15);

//     if (pickedFile != null) {
//       _editProfileMode.image = File(pickedFile.path);
//     }
//     state = AsyncData(_editProfileMode);
//   }

  @override
  build() {
    return _editProfileMode;
  }
}
