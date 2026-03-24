import 'dart:developer';

import 'package:sm_project/features/drawer/notifier/change_password_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class ChangePassword extends StatelessWidget {
  final GlobalKey<FormState> _formCreatePasswordKey = GlobalKey<FormState>();
  ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteBackgroundColor,
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: appColor,
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 13, 0, 0),
              child: InkWell(
                  onTap: () {
                    context.pop();
                  },
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: whiteBackgroundColor, width: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Padding(
                            padding: EdgeInsets.fromLTRB(10.0, 5, 5, 5),
                            child: Icon(Icons.arrow_back_ios,
                                size: 15, color: whiteBackgroundColor)))
                  ])),
            ),
            title: const Text(
              "Change Password",
              style: TextStyle(color: whiteBackgroundColor, fontSize: 18),
            ),
            iconTheme: const IconThemeData(color: Colors.black)),
        body: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formCreatePasswordKey,
                child: Consumer(builder: (context, ref, child) {
                  final refWatch = ref.watch(changePasswordNotifierProvider);
                  final refRead =
                      ref.read(changePasswordNotifierProvider.notifier);
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Old Password"),
                        CustomTextFormField(
                            obscureText: !refWatch.value!.obsecureText,
                            controller: refWatch.value?.oldPasswordController,
                            keyboardType: TextInputType.text,
                            prefixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(lockLogo,
                                    height: 20, width: 20)),
                            hintText: 'Enter Old Password',
                            suffixIcon: InkWell(
                                onTap: () {
                                  refRead.changeObsecureText();
                                },
                                child: Icon(
                                    refWatch.value?.obsecureText ?? false
                                        ? Icons.remove_red_eye
                                        : Icons.visibility_off)),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter Password';
                              } else if (value.length < 6 || value.length > 6) {
                                return 'Password must be 6 digit';
                              }
                              return null;
                            }),
                        const SizedBox(height: 20),
                        const Text("New Password"),
                        CustomTextFormField(
                            // obscureText: !refWatch.value!.obsecureText,
                            controller: refWatch.value?.newPasswordController,
                            keyboardType: TextInputType.text,
                            prefixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(lockLogo,
                                    height: 20, width: 20)),
                            hintText: 'Enter Confirm Password',
                            // suffixIcon: InkWell(
                            //     onTap: () {
                            //       refRead.changeObsecureText();
                            //     },
                            //     child: Icon(
                            //         refWatch.value?.obsecureText ?? false
                            //             ? Icons.remove_red_eye
                            //             : Icons.visibility_off)),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter Password';
                              } else if (value.length < 6 || value.length > 6) {
                                return 'Password must be 6 digit';
                              }
                              return null;
                            }),
                        const SizedBox(height: 35),
                        buttonSizedBox(
                            color: whiteBackgroundColor,
                            text: 'Change Password',
                            textColor: whiteBackgroundColor,
                            onTap: () {
                              if (!_formCreatePasswordKey.currentState!
                                  .validate()) {
                                log('Form is not valid');
                              } else {
                                refRead.changePassword(context);
                              }
                            }),
                      ]);
                }),
              )),
        ));
  }
}
