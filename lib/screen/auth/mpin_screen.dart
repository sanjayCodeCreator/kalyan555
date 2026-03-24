// import 'package:flutter/gestures.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:sm_project/controller/riverpod/auth_notifier/contact_us_notifier.dart';
// import 'package:sm_project/controller/riverpod/auth_notifier/mpin_notifier.dart';
// import 'package:sm_project/utils/filecollection.dart';

// class MPin extends ConsumerStatefulWidget {
//   const MPin({super.key});

//   @override
//   ConsumerState<MPin> createState() => _MPinState();
// }

// class _MPinState extends ConsumerState<MPin> with TickerProviderStateMixin {
//   late final AnimationController _controller;

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final refRead = ref.read(getContactUsNotifierProvider.notifier);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Container(
//           height: double.infinity,
//           color: const Color(0xfff5f5f5),
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 50),
//                 // Top Illustration or Logo
//                 Center(
//                   child: Image.asset(
//                     appIcon,
//                     height: 100,
//                     width: 100,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 const Text(
//                   'Enter MPIN',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "Please enter the 4-digit MPIN to proceed.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 16, color: Colors.black),
//                 ),
//                 const SizedBox(height: 40),
//                 Consumer(builder: (context, ref, child) {
//                   final refWatch = ref.watch(mpinNotifierProvider);
//                   final refRead = ref.read(mpinNotifierProvider.notifier);
//                   return Card(
//                     elevation: 8,
//                     color: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 20),
//                           const Text(
//                             "MPIN",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           PinCodeTextField(
//                             controller: refWatch.value!.mpinController,
//                             autoFocus: false,
//                             enablePinAutofill: false,
//                             appContext: context,
//                             textStyle: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                             length: 4,
//                             obscureText: false,
//                             animationType: AnimationType.fade,
//                             pinTheme: PinTheme(
//                               shape: PinCodeFieldShape.box,
//                               borderRadius: BorderRadius.circular(10),
//                               fieldHeight: 50,
//                               fieldWidth: 50,
//                               inactiveFillColor: backgroundColor,
//                               inactiveColor: Colors.grey.withOpacity(0.5),
//                               selectedColor: const Color(0xff98CD5C),
//                               selectedFillColor: whiteBackgroundColor,
//                               activeFillColor: backgroundColor,
//                               activeColor: buttonColor,
//                             ),
//                             cursorColor: colorBlack,
//                             animationDuration:
//                                 const Duration(milliseconds: 300),
//                             enableActiveFill: true,
//                             keyboardType: TextInputType.number,
//                             onCompleted: (v) {
//                               // handle completed action
//                             },
//                             onChanged: (value) {
//                               // handle changes
//                             },
//                           ),
//                           const SizedBox(height: 20),
//                           Center(
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 if (refWatch.value!.mpinController.text.length <
//                                     4) {
//                                   toast('Please enter 4 digit MPIN');
//                                 } else {
//                                   refRead.getMpinLogin(context);
//                                 }
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: 15, horizontal: 40),
//                                 backgroundColor: Colors.blueAccent,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                               ),
//                               child: const Text(
//                                 'Proceed Securely',
//                                 style: TextStyle(
//                                     fontSize: 18, color: Colors.white),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//                 const SizedBox(height: 30),
//                 Consumer(builder: (context, ref, child) {
//                   final refRead = ref.read(mpinNotifierProvider.notifier);
//                   return RichText(
//                     text: TextSpan(
//                       text: 'By clicking, I accept the ',
//                       style: const TextStyle(fontSize: 14, color: Colors.black),
//                       children: <TextSpan>[
//                         TextSpan(
//                           recognizer: TapGestureRecognizer()
//                             ..onTap = () {
//                               refRead.launchPrivacyPolicy();
//                             },
//                           text: 'Privacy Policy',
//                           style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.black,
//                               fontWeight: FontWeight.w900),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // class MPin extends ConsumerStatefulWidget {
// //   const MPin({super.key});

// //   @override
// //   ConsumerState<MPin> createState() => _MPinState();
// // }

// // class _MPinState extends ConsumerState<MPin> with TickerProviderStateMixin {
// //   final LocalAuthentication auth = LocalAuthentication();
// //   bool isBioMetricAvailable = false;
// //   late final AnimationController _controller;

// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
// //     //   authenticateWithBioMetric();
// //     // });
// //     _controller = AnimationController(vsync: this);
// //   }

// //   authenticateWithBioMetric() async {
// //     final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
// //     final bool canAuthenticate =
// //         canAuthenticateWithBiometrics || await auth.isDeviceSupported();
// //     if (canAuthenticate) {
// //       isBioMetricAvailable = true;
// //       try {
// //         await auth.stopAuthentication();
// //         final bool didAuthenticate = await auth.authenticate(
// //             options: const AuthenticationOptions(biometricOnly: true),
// //             localizedReason: 'Please authenticate to login');
// //         if (didAuthenticate) {
// //           if (mounted) {
// //             context.go(HomePath.homeScreen);
// //           }
// //         }
// //       } catch (e) {
// //         log("$e");
// //       }
// //       if (context.mounted) {
// //         setState(() {});
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final refRead = ref.read(getContactUsNotifierProvider.notifier);
// //     return Scaffold(
// //       backgroundColor: appColor,
// //       bottomSheet: Container(
// //           height: MediaQuery.of(context).size.height * 0.1,
// //           color: appColor,
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               const Text('Need Help?',
// //                   style: TextStyle(fontSize: 16, color: whiteBackgroundColor)),
// //               const SizedBox(height: 10),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   InkWell(
// //                       onTap: () {
// //                         refRead.callUs();
// //                       },
// //                       child: const Icon(Icons.phone,
// //                           color: whiteBackgroundColor, size: 25)),
// //                   const SizedBox(width: 20),
// //                   InkWell(
// //                     onTap: () {
// //                       refRead.launchWhatsapp();
// //                     },
// //                     child: Image.asset(whatsappLogo, width: 25),
// //                   )
// //                 ],
// //               ),
// //             ],
// //           )),
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
// //           child: Consumer(builder: (context, ref, child) {
// //             final refWatch = ref.watch(mpinNotifierProvider);
// //             final refRead = ref.read(mpinNotifierProvider.notifier);
// //             return Column(children: [
// //               ClipRRect(
// //                   borderRadius: BorderRadius.circular(10),
// //                   child:
// //                       Image.asset(appIcon, height: 100, fit: BoxFit.scaleDown)),
// //               const SizedBox(height: 20),
// //               Card(
// //                 elevation: 4,
// //                 child: Container(
// //                     decoration: BoxDecoration(
// //                         color: appColor,
// //                         borderRadius: BorderRadius.circular(10),
// //                         border:
// //                             Border.all(color: Colors.white.withOpacity(0.8)),
// //                         boxShadow: const [
// //                           BoxShadow(
// //                               color: whiteBackgroundColor,
// //                               offset: Offset(-2, 2),
// //                               blurRadius: 5)
// //                         ]),
// //                     child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.center,
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           const SizedBox(height: 10),
// //                           const Text('Enter PIN ',
// //                               textAlign: TextAlign.start,
// //                               style: TextStyle(
// //                                   fontSize: 26,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: whiteBackgroundColor)),
// //                           Padding(
// //                               padding:
// //                                   const EdgeInsets.fromLTRB(50.0, 10, 50, 0),
// //                               child: PinCodeTextField(
// //                                 controller: refWatch.value!.mpinController,
// //                                 autoFocus: false,
// //                                 enablePinAutofill: false,
// //                                 appContext: context,
// //                                 textStyle: const TextStyle(
// //                                   fontSize: 20,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.black,
// //                                 ),
// //                                 // pastedTextStyle: TextStyle(
// //                                 //   color: Colors.green.shade600,
// //                                 //   fontWeight: FontWeight.bold,
// //                                 // ),
// //                                 length: 4,
// //                                 obscureText: false,
// //                                 animationType: AnimationType.fade,
// //                                 pinTheme: PinTheme(
// //                                   shape: PinCodeFieldShape.box,
// //                                   borderRadius: BorderRadius.circular(10),
// //                                   fieldHeight: 50,
// //                                   fieldWidth: 50,
// //                                   inactiveFillColor: backgroundColor,
// //                                   inactiveColor: Colors.grey.withOpacity(0.5),
// //                                   selectedColor: const Color(0xff98CD5C),
// //                                   selectedFillColor: whiteBackgroundColor,
// //                                   activeFillColor: backgroundColor,
// //                                   activeColor: buttonColor,
// //                                 ),
// //                                 cursorColor: colorBlack,
// //                                 animationDuration:
// //                                     const Duration(milliseconds: 300),
// //                                 enableActiveFill: true,

// //                                 // controller: otpController,
// //                                 keyboardType: TextInputType.number,
// //                                 // boxShadows: const [],
// //                                 onCompleted: (v) {
// //                                   //do something or move to next screen when code complete
// //                                 },
// //                                 onChanged: (value) {
// //                                   // if (mounted) {
// //                                   //   setState(() {
// //                                   //     log(value);
// //                                   //   });
// //                                   // }
// //                                 },
// //                               )),
// //                           Padding(
// //                             padding: const EdgeInsets.only(right: 50.0),
// //                             child: Align(
// //                                 alignment: Alignment.topRight,
// //                                 child: RichText(
// //                                     overflow: TextOverflow.clip,
// //                                     textAlign: TextAlign.end,
// //                                     textDirection: TextDirection.rtl,
// //                                     softWrap: true,
// //                                     maxLines: 1,
// //                                     text: TextSpan(
// //                                         recognizer: TapGestureRecognizer()
// //                                           ..onTap = () => context.pushNamed(
// //                                               RouteNames.forgotMpinPassword),
// //                                         text: '?Forgot Pin',
// //                                         style: const TextStyle(
// //                                             fontSize: 14,
// //                                             color: whiteBackgroundColor,
// //                                             fontWeight: FontWeight.bold)))),
// //                           ),
// //                           const SizedBox(height: 20),
// //                           buttonSizedBox(
// //                               color: appColor,
// //                               backgroundColor: whiteBackgroundColor,
// //                               width: 250,
// //                               text: "Proceed Securely",
// //                               textColor: whiteBackgroundColor,
// //                               onTap: () {
// //                                 if (refWatch.value!.mpinController.text.length <
// //                                     4) {
// //                                   toast('Please enter 4 digit MPIN');
// //                                 } else {
// //                                   refRead.getMpinLogin(context);
// //                                 }
// //                               }),
// //                           const SizedBox(height: 20),
// //                           // const Text(
// //                           //   'OR',
// //                           //   style: TextStyle(
// //                           //       fontSize: 16, color: whiteBackgroundColor),
// //                           // ),
// //                           // isBioMetricAvailable
// //                           //     ? Container(
// //                           //         margin: const EdgeInsets.symmetric(
// //                           //             horizontal: 30),
// //                           //         child: Column(
// //                           //           children: [
// //                           //             Container(
// //                           //               margin: const EdgeInsets.symmetric(
// //                           //                   vertical: 15.0),
// //                           //               child: const Text(
// //                           //                 "Authenticate using your fingerprint instead of your password",
// //                           //                 textAlign: TextAlign.center,
// //                           //                 style: TextStyle(
// //                           //                     color: whiteBackgroundColor,
// //                           //                     height: 1.5),
// //                           //               ),
// //                           //             ),
// //                           //             InkWell(
// //                           //               onTap: () {
// //                           //                 HapticFeedback.heavyImpact();
// //                           //                 authenticateWithBioMetric();
// //                           //               },
// //                           //               onLongPress: () {
// //                           //                 HapticFeedback.heavyImpact();
// //                           //                 authenticateWithBioMetric();
// //                           //               },
// //                           //               child: ClipRRect(
// //                           //                 borderRadius:
// //                           //                     BorderRadius.circular(30),
// //                           //                 child: Image.asset(
// //                           //                   'assets/images/fingerprint.gif',
// //                           //                   height: MediaQuery.of(context)
// //                           //                           .size
// //                           //                           .height *
// //                           //                       0.15,
// //                           //                   color: Colors.white,
// //                           //                 ),
// //                           //               ),
// //                           //             )
// //                           //           ],
// //                           //         ),
// //                           //       )
// //                           //     : const SizedBox(),
// //                           // const SizedBox(height: 15),
// //                         ])),
// //               ),
// //               const SizedBox(height: 15),
// //               RichText(
// //                 // ignore: deprecated_member_use
// //                 textScaleFactor: 1,
// //                 text: TextSpan(
// //                     text: 'By clicking, I accept the ',
// //                     style: const TextStyle(
// //                         fontSize: 14, color: whiteBackgroundColor),
// //                     children: <TextSpan>[
// //                       // TextSpan(
// //                       //     text: 'T&C',
// //                       //     style: TextStyle(
// //                       //         fontSize: 14,
// //                       //         color: buttonColor,
// //                       //         fontWeight: FontWeight.bold)),
// //                       // TextSpan(
// //                       //     text: ' and ',
// //                       //     style: TextStyle(
// //                       //         fontSize: 14, color: colorBlack)),
// //                       TextSpan(
// //                           recognizer: TapGestureRecognizer()
// //                             ..onTap = () {
// //                               refRead.launchPrivacyPolicy();
// //                             },
// //                           text: 'Privacy Policy',
// //                           style: const TextStyle(
// //                               fontSize: 14,
// //                               color: whiteBackgroundColor,
// //                               fontWeight: FontWeight.w900)),
// //                     ]),
// //               ),
// //             ]);
// //           }),
// //         ),
// //       ),
// //     );
// //   }
// // }
