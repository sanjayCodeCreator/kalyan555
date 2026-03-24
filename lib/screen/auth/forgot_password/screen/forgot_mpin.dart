import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:sm_project/utils/filecollection.dart';
import '../forgot_notifier/forgot_mpin_notifier.dart';

class ForgotMpin extends StatelessWidget {
  final GlobalKey<FormState> _forgotMPINPassword = GlobalKey<FormState>();
  ForgotMpin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        bottomSheet: Container(
            color: Colors.white,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: RichText(
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.end,
                          textDirection: TextDirection.rtl,
                          softWrap: true,
                          maxLines: 1,
                          text: TextSpan(
                              text: 'Remember Password? ',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: whiteBackgroundColor,
                                  fontWeight: FontWeight.w400),
                              children: <TextSpan>[
                                TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => context
                                          .pushNamed(RouteNames.logInScreen),
                                    text: 'Login',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: whiteBackgroundColor,
                                        fontWeight: FontWeight.w700))
                              ]))),
                  const SizedBox(height: 20)
                ])),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 20, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppBackICon(),
                        const Text('Forgot Security PIN',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            )),
                        const SizedBox(height: 10),
                        const Text(
                            "Don't worry! It occurs. Please enter the mobile number that linked with your account.",
                            style: TextStyle(color: Color(0xff9E9E9E))),
                        Consumer(builder: (context, ref, child) {
                          final refWatch =
                              ref.watch(forgotMPINNotifierProvider);
                          final refRead =
                              ref.read(forgotMPINNotifierProvider.notifier);

                          return Form(
                              key: _forgotMPINPassword,
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 30, 0, 20),
                                decoration: BoxDecoration(
                                    color: whiteBackgroundColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Mobile Number"),
                                      CustomTextFormField(
                                        controller: refWatch
                                            .value?.mobileNumbController,
                                        keyboardType: TextInputType.number,
                                        prefixIcon: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(loginMobileLogo,
                                                height: 20, width: 20)),
                                        hintText: 'Enter Mobile Number',
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter mobile number';
                                          } else if (value.length < 10 ||
                                              value.length > 10) {
                                            return 'Mobile number must be 10 digit';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 35),
                                      buttonSizedBox(
                                          color: whiteBackgroundColor,
                                          text: 'Request OTP',
                                          textColor: whiteBackgroundColor,
                                          onTap: () {
                                            if (!_forgotMPINPassword
                                                .currentState!
                                                .validate()) {
                                              log('Form is not valid');
                                            } else {
                                              refRead.postForgotMpIn(context);
                                            }
                                          }),
                                    ]),
                              ));
                        })
                      ],
                    )))));
  }
}
