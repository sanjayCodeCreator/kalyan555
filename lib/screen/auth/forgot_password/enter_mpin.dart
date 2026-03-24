// import 'package:flutter/gestures.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:sm_project/controller/riverpod/auth_notifier/mpin_notifier.dart';
// import 'package:sm_project/utils/filecollection.dart';

// class EnterMPin extends StatelessWidget {
//   const EnterMPin({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       bottomSheet: Container(
//           color: Colors.white,
//           child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Center(
//                     child: RichText(
//                         overflow: TextOverflow.clip,
//                         textAlign: TextAlign.end,
//                         textDirection: TextDirection.rtl,
//                         softWrap: true,
//                         maxLines: 1,
//                         text: TextSpan(
//                             recognizer: TapGestureRecognizer()
//                               ..onTap = () =>
//                                   context.pushNamed(RouteNames.forgotMpinPassword),
//                             text: '?Forgot Pin',
//                             style: const TextStyle(
//                                 fontSize: 14,
//                                 color: darkBlue,
//                                 fontWeight: FontWeight.bold)))),
//                 const SizedBox(height: 20)
//               ])),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
//           child: Consumer(builder: (context, ref, child) {
//             final refWatch = ref.watch(mpinNotifierProvider);
//             final refRead = ref.read(mpinNotifierProvider.notifier);
//             return Column(children: [
//               const Row(children: [AppBackICon()]),
//               const Text('Enter Security PIN',
//                   textAlign: TextAlign.start,
//                   style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       color: textColor)),
//               const Padding(
//                   padding: EdgeInsets.fromLTRB(20.0, 10, 20, 30),
//                   child: Text(
//                       "Your new password must be unique from those previously used.",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Color(0xff9E9E9E)))),
//               Image.asset(appIcon, height: 100, fit: BoxFit.scaleDown),
//               const SizedBox(height: 40),
//               Card(
//                 elevation: 4,
//                 child: Container(
//                     decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(10),
//                         border:
//                             Border.all(color: Colors.grey.withOpacity(0.5))),
//                     child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Padding(
//                               padding:
//                                   const EdgeInsets.fromLTRB(50.0, 30, 50, 30),
//                               child: PinCodeTextField(
//                                 controller: refWatch.value!.mpinController,
//                                 autoFocus: true,
//                                 enablePinAutofill: false,
//                                 appContext: context,
//                                 textStyle: const TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                                 // pastedTextStyle: TextStyle(
//                                 //   color: Colors.green.shade600,
//                                 //   fontWeight: FontWeight.bold,
//                                 // ),
//                                 length: 4,
//                                 obscureText: false,
//                                 animationType: AnimationType.fade,
//                                 pinTheme: PinTheme(
//                                   shape: PinCodeFieldShape.box,
//                                   borderRadius: BorderRadius.circular(10),
//                                   fieldHeight: 50,
//                                   fieldWidth: 50,
//                                   inactiveFillColor: backgroundColor,
//                                   inactiveColor: Colors.grey.withOpacity(0.5),
//                                   selectedColor: const Color(0xff98CD5C),
//                                   selectedFillColor: whiteBackgroundColor,
//                                   activeFillColor: backgroundColor,
//                                   activeColor: const Color(0xff98CD5C),
//                                 ),
//                                 cursorColor: colorBlack,
//                                 animationDuration:
//                                     const Duration(milliseconds: 300),
//                                 enableActiveFill: true,

//                                 // controller: otpController,
//                                 keyboardType: TextInputType.number,
//                                 // boxShadows: const [],
//                                 onCompleted: (v) {
//                                   //do something or move to next screen when code complete
//                                 },
//                                 onChanged: (value) {
//                                   // if (mounted) {
//                                   //   setState(() {
//                                   //     log(value);
//                                   //   });
//                                   // }
//                                 },
//                               )),
//                           buttonSizedBox(
//                               color: darkBlue,
//                               width: 250,
//                               text: "Proceed Securely",
//                               textColor: whiteBackgroundColor,
//                               onTap: () {
//                                 if (refWatch.value!.mpinController.text.length <
//                                     4) {
//                                   toast('Please enter 4 digit MPIN');
//                                 } else {
//                                   refRead.getMpinLogin(context);
//                                 }
//                               }),
//                           const SizedBox(height: 15),
//                           RichText(
//                             // ignore: deprecated_member_use
//                             textScaleFactor: 1,
//                             text: TextSpan(
//                                 text: 'By clicking, I accept the ',
//                                 style: const TextStyle(
//                                     fontSize: 14, color: textColor),
//                                 children: <TextSpan>[
//                                   // TextSpan(
//                                   //     text: 'T&C',
//                                   //     style: TextStyle(
//                                   //         fontSize: 14,
//                                   //         color: buttonColor,
//                                   //         fontWeight: FontWeight.bold)),
//                                   // TextSpan(
//                                   //     text: ' and ',
//                                   //     style: TextStyle(
//                                   //         fontSize: 14, color: colorBlack)),
//                                   TextSpan(
//                                       recognizer: TapGestureRecognizer()
//                                         ..onTap = () {
//                                           refRead.launchPrivacyPolicy();
//                                         },
//                                       text: 'Privacy Policy',
//                                       style: const TextStyle(
//                                           fontSize: 14,
//                                           color: darkBlue,
//                                           fontWeight: FontWeight.bold)),
//                                 ]),
//                           ),
//                           const SizedBox(height: 20),
//                         ])),
//               )
//             ]);
//           }),
//         ),
//       ),
//     );
//   }
// }
