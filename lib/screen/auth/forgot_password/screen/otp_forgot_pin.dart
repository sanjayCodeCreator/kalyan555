import 'dart:developer';

import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sm_project/screen/auth/forgot_password/forgot_notifier/forgot_mpin_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class OTPFogotPin extends StatelessWidget {
  final String? mobile;
  final GlobalKey<FormState> _formOtpVerifyKey = GlobalKey<FormState>();
  OTPFogotPin({super.key, this.mobile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 20, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppBackICon(),
                        const Text('OTP Verification',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            )),
                        const SizedBox(height: 10),
                        Text(
                            "Enter the verification code we just sent on your mobile number +91$mobile",
                            style: const TextStyle(color: Color(0xff9E9E9E))),
                        Consumer(builder: (context, ref, child) {
                          final refWatch =
                              ref.watch(forgotMPINNotifierProvider);
                          final refRead =
                              ref.read(forgotMPINNotifierProvider.notifier);

                          refWatch.value?.stopWatchTimer.onStartTimer();

                          return Form(
                              key: _formOtpVerifyKey,
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 20, 0, 20),
                                decoration: BoxDecoration(
                                    color: whiteBackgroundColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Verify OTP"),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 20, 30, 0),
                                          child: PinCodeTextField(
                                            controller: refWatch
                                                .value!.forgotOTPController,
                                            autoFocus: true,
                                            enablePinAutofill: false,
                                            appContext: context,
                                            textStyle: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: textColor),
                                            // pastedTextStyle: TextStyle(
                                            //   color: Colors.green.shade600,
                                            //   fontWeight: FontWeight.bold,
                                            // ),
                                            length: 6,
                                            obscureText: false,
                                            animationType: AnimationType.fade,
                                            pinTheme: PinTheme(
                                                shape: PinCodeFieldShape.box,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                fieldHeight: 50,
                                                fieldWidth: 50,
                                                inactiveFillColor:
                                                    backgroundColor,
                                                inactiveColor: Colors.grey
                                                    .withOpacity(0.5),
                                                selectedColor:
                                                    const Color(0xff98CD5C),
                                                selectedFillColor:
                                                    whiteBackgroundColor,
                                                activeFillColor:
                                                    backgroundColor,
                                                activeColor: buttonColor),
                                            cursorColor: colorBlack,
                                            animationDuration: const Duration(
                                                milliseconds: 300),
                                            enableActiveFill: true,

                                            keyboardType: TextInputType.number,
                                            // boxShadows: const [],
                                            onCompleted: (v) {
                                              //do something or move to next screen when code complete
                                            },
                                            onChanged: (value) {
                                              // if (mounted) {
                                              //   setState(() {
                                              //     log(value);
                                              //   });
                                              // }
                                            },
                                          )),

                                      StreamBuilder<int>(
                                        stream: refWatch
                                            .value?.stopWatchTimer.rawTime,
                                        initialData: refWatch.value
                                            ?.stopWatchTimer.rawTime.value,
                                        builder: (context, snap) {
                                          final value = snap.data!;
                                          final displayTime =
                                              StopWatchTimer.getDisplayTime(
                                                  value,
                                                  hours: false,
                                                  milliSecond: false);
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              refWatch.value?.stopWatchTimer
                                                          .rawTime.value !=
                                                      0
                                                  ? const Text(
                                                      "Resend code in",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: colorGrey),
                                                    )
                                                  : InkWell(
                                                      onTap: () {
                                                        refWatch.value
                                                            ?.stopWatchTimer
                                                            .setPresetSecondTime(
                                                                120);
                                                        refWatch.value
                                                            ?.stopWatchTimer
                                                            .onStartTimer();
                                                        refRead.resendOTP(
                                                            context,
                                                            mobile ?? '');
                                                      },
                                                      child: const Text(
                                                        "RESEND CODE",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: textColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ),
                                              refWatch.value?.stopWatchTimer
                                                          .rawTime.value !=
                                                      0
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Text(
                                                        displayTime,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            color: colorGrey,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ],
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 30),

                                      Container(
                                        color: Colors.white,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Consumer(
                                                builder: (context, ref, child) {
                                              final refRead = ref.read(
                                                  forgotMPINNotifierProvider
                                                      .notifier);
                                              return InkWell(
                                                  onTap: () {
                                                    if (!_formOtpVerifyKey
                                                        .currentState!
                                                        .validate()) {
                                                      log('Form is not valid');
                                                    } else {
                                                      refRead.verifyOTPSms(
                                                          context,
                                                          mobile ?? '');
                                                    }
                                                  },
                                                  child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                      padding:
                                                          const EdgeInsets.fromLTRB(
                                                              15, 16, 15, 16),
                                                      decoration: BoxDecoration(
                                                          color: darkBlue,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10)),
                                                      child: const Text(
                                                          'Verify OTP',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color: whiteBackgroundColor))));
                                            }),
                                            const SizedBox(height: 30),
                                          ],
                                        ),
                                      ),

                                      // RichText(
                                      //     overflow: TextOverflow.clip,
                                      //     textAlign: TextAlign.end,
                                      //     textDirection: TextDirection.rtl,
                                      //     softWrap: true,
                                      //     maxLines: 1,
                                      //     text: TextSpan(
                                      //         text: 'Didn’t received code? ',
                                      //         style: const TextStyle(
                                      //             fontSize: 16,
                                      //             color: textColor,
                                      //             fontWeight: FontWeight.w400),
                                      //         children: <TextSpan>[
                                      //           TextSpan(
                                      //               recognizer:
                                      //                   TapGestureRecognizer()
                                      //                     ..onTap = () =>
                                      //                         log('Click Here'),
                                      //               // context.pushNamed(RouteNames.facingloginScreen),
                                      //               text: 'Resend',
                                      //               style: const TextStyle(
                                      //                   color: redColor,
                                      //                   fontWeight:
                                      //                       FontWeight.w500)),
                                      //         ]))
                                    ]),
                              ));
                        })
                      ],
                    )))));
  }
}
