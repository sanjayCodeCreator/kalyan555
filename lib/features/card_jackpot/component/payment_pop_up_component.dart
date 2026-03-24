// import 'dart:developer';
//
// import 'package:flutter/services.dart';
// import 'package:sm_project/controller/local/user_particular_player.dart';
// import 'package:sm_project/controller/model/get_particular_player_model.dart';
// import 'package:sm_project/controller/model/get_setting_model.dart' as setting;
// import 'package:sm_project/features/card_jackpot/jackpot_payment_notifier.dart';
// import 'package:sm_project/utils/filecollection.dart';
// import 'package:upi_india/upi_india.dart';
//
// void showPaymentPopUp({required BuildContext context, required String title}) {
//   showModalBottomSheet(
//     context: context,
//     builder: (context) {
//       return PaymentPopUp(
//         title: title,
//       );
//     },
//   );
// }
//
// class PaymentPopUp extends StatefulWidget {
//   final String title;
//   const PaymentPopUp({required this.title, super.key});
//
//   @override
//   State<PaymentPopUp> createState() => _PaymentPopUpState();
// }
//
// class _PaymentPopUpState extends State<PaymentPopUp> {
//   final UpiIndia _upiIndia = UpiIndia();
//   List<UpiApp>? apps;
//   // ignore: unused_field
//   Future<UpiResponse>? _transaction;
//   setting.GetSettingModel? getSettingModel = setting.GetSettingModel();
//   final Data? userDgetParticularUserData =
//       UserParticularPlayer.getParticularUserData();
//
//   @override
//   void initState() {
//     super.initState();
//     EasyLoading.show(status: 'loading...');
//     _upiIndia.getAllUpiApps(mandatoryTransactionId: true).then((value) {
//       setState(() {
//         apps = value;
//       });
//     }).catchError((e) {
//       apps = [];
//     });
//     getSetting();
//     EasyLoading.dismiss();
//   }
//
//   Future<void> getSetting() async {
//     EasyLoading.show(status: 'loading...');
//     getSettingModel = await ApiService().getSettingModel();
//     EasyLoading.dismiss();
//   }
//
//   Future<String> getTransactionReferenceId() async {
//     var id = userDgetParticularUserData?.sId;
//     if (id != null && id.isNotEmpty) {
//       var transRefId = id + DateTime.now().microsecondsSinceEpoch.toString();
//       log('transRefId: $transRefId');
//       return transRefId;
//     } else {
//       log('UserNotLoggedIn');
//       return "UserNotLoggedIn";
//     }
//   }
//
//   Future<UpiResponse> initiateTransaction(
//       {required UpiApp app, required double amount}) async {
//     return _upiIndia.startTransaction(
//       app: app,
//       receiverUpiId: getSettingModel?.data?.merchantUpi ?? '',
//       receiverName: getSettingModel?.data?.merchantName ?? '',
//       transactionRefId: await getTransactionReferenceId(),
//       transactionNote: 'deposit funds',
//       amount: amount,
//     );
//   }
//
//   Widget displayUpiApps() {
//     if (apps == null) {
//       return const Center(
//         child: Text(
//           "No apps found to handle transaction.",
//           style: TextStyle(
//             fontSize: 20,
//             color: Colors.black,
//           ),
//         ),
//       );
//     } else if (apps!.isEmpty) {
//       return const Center(
//         child: Text(
//           "No apps found to handle transaction.",
//           style: TextStyle(
//             fontSize: 20,
//             color: Colors.black,
//           ),
//         ),
//       );
//     } else {
//       return Consumer(builder: (context, ref, child) {
//         final jackpotPaymentData =
//             ref.watch(jackpotPaymentNotifierProvider).value;
//         final refRead = ref.read(jackpotPaymentNotifierProvider.notifier);
//         return Padding(
//           padding: const EdgeInsets.only(left: 8.0),
//           child: GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 4,
//               crossAxisSpacing: 8.0,
//               mainAxisSpacing: 8.0,
//             ),
//             itemCount: apps!.length,
//             itemBuilder: (context, index) {
//               UpiApp app = apps![index];
//               return GestureDetector(
//                   onTap: () {
//                     refRead.updateUpiApp(app);
//                   },
//                   child: Card(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(60)),
//                     child: Container(
//                         height: 100,
//                         decoration: BoxDecoration(
//                           color: jackpotPaymentData?.app?.name == app.name
//                               ? darkBlue
//                               : Colors.white,
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             width: 1,
//                             color: const Color(0xffE6E6E6),
//                           ),
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.memory(app.icon, width: 40, height: 40),
//                           ],
//                         )),
//                   ));
//             },
//           ),
//         );
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.max,
//       children: [
//         Container(
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: darkBlue,
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(16),
//               topRight: Radius.circular(16),
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Center(
//               child: Text(
//                 "SELECTED ${widget.title}",
//                 style: const TextStyle(
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(
//           height: 16,
//         ),
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Balance",
//                     style: TextStyle(fontSize: 18),
//                   ),
//                   Consumer(builder: (context, ref, child) {
//                     final jackpotPaymentData =
//                         ref.watch(jackpotPaymentNotifierProvider).value;
//                     final refRead =
//                         ref.read(jackpotPaymentNotifierProvider.notifier);
//                     return SizedBox(
//                       height: 40,
//                       child: ListView.builder(
//                         itemCount: jackpotPaymentData?.balanceFields.length,
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         scrollDirection: Axis.horizontal,
//                         itemBuilder: (context, index) {
//                           final balance =
//                               jackpotPaymentData?.balanceFields[index];
//                           return Padding(
//                             padding: const EdgeInsets.only(right: 8.0),
//                             child: InkWell(
//                               onTap: () {
//                                 refRead.updateBalanceField(balance ?? 0);
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: balance ==
//                                           jackpotPaymentData
//                                               ?.selectedBalanceField
//                                       ? darkBlue
//                                       : const Color(0xfff7f8f9),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                     left: 8.0,
//                                     right: 8,
//                                     top: 5,
//                                     bottom: 5,
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       "${balance?.toString()}",
//                                       style: const TextStyle(fontSize: 18),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Quantity",
//                     style: TextStyle(fontSize: 18),
//                   ),
//                   Consumer(builder: (context, ref, child) {
//                     final refWatch =
//                         ref.watch(jackpotPaymentNotifierProvider).value;
//                     final refRead =
//                         ref.read(jackpotPaymentNotifierProvider.notifier);
//                     return Row(
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             HapticFeedback.selectionClick();
//                             refRead.quantityDecrement();
//                           },
//                           child: Container(
//                             color: darkBlue,
//                             width: 42,
//                             height: 40,
//                             child: const Icon(Icons.remove),
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 6,
//                         ),
//                         SizedBox(
//                           width: 90,
//                           height: 40,
//                           child: TextFormField(
//                             controller: refWatch?.quantity,
//                             textAlign: TextAlign.center,
//                             textAlignVertical: TextAlignVertical.center,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               contentPadding: const EdgeInsets.only(
//                                 top: 10,
//                                 bottom: 10,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(0),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade100,
//                                   width: 0.2,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 6,
//                         ),
//                         InkWell(
//                           onTap: () {
//                             HapticFeedback.selectionClick();
//                             refRead.quantityIncrement();
//                           },
//                           child: Container(
//                             color: darkBlue,
//                             width: 42,
//                             height: 40,
//                             child: const Icon(Icons.add),
//                           ),
//                         ),
//                       ],
//                     );
//                   }),
//                 ],
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Consumer(builder: (context, ref, child) {
//                 final jackpotPaymentData =
//                     ref.watch(jackpotPaymentNotifierProvider).value;
//                 final refRead =
//                     ref.read(jackpotPaymentNotifierProvider.notifier);
//                 return SizedBox(
//                   height: 40,
//                   child: ListView.builder(
//                     itemCount: jackpotPaymentData?.quantityMultiplier.length,
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     scrollDirection: Axis.horizontal,
//                     itemBuilder: (context, index) {
//                       final quantityMultiplier =
//                           jackpotPaymentData?.quantityMultiplier[index];
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 10.0),
//                         child: InkWell(
//                           onTap: () {
//                             refRead.updateQuanityMultiplier(
//                                 quantityMultiplier ?? 0);
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: quantityMultiplier ==
//                                       jackpotPaymentData
//                                           ?.selectedQuantityMutliplier
//                                   ? darkBlue
//                                   : const Color(0xfff7f8f9),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(6.0),
//                               child: Center(
//                                 child: Text(
//                                   "X${quantityMultiplier?.toString()}",
//                                   style: const TextStyle(fontSize: 18),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               }),
//             ],
//           ),
//         ),
//         displayUpiApps(),
//         const Spacer(),
//         Row(
//           children: [
//             Expanded(
//               flex: 2,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.zero,
//                   ),
//                   fixedSize: const Size.fromHeight(50),
//                 ),
//                 onPressed: () {
//                   context.pop();
//                 },
//                 child: const Text("Back"),
//               ),
//             ),
//             Expanded(
//               flex: 3,
//               child: Consumer(builder: (context, ref, child) {
//                 final jackpotPaymentData =
//                     ref.watch(jackpotPaymentNotifierProvider).value;
//                 return ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     shape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.zero,
//                     ),
//                     fixedSize: const Size.fromHeight(50),
//                   ),
//                   onPressed: () {
//                     if (jackpotPaymentData?.app != null) {
//                       _transaction = initiateTransaction(
//                         app: jackpotPaymentData!.app!,
//                         amount: jackpotPaymentData.totalAmount.toDouble(),
//                       );
//                     } else {
//                       toast('Please select payment app');
//                     }
//                   },
//                   child: Text(
//                       "TOTAL AMOUNT: ${jackpotPaymentData?.totalAmount ?? ""}"),
//                 );
//               }),
//             )
//           ],
//         ),
//       ],
//     );
//   }
// }
// import 'dart:developer';
//
// import 'package:flutter/services.dart';
// import 'package:sm_project/controller/local/user_particular_player.dart';
// import 'package:sm_project/controller/model/get_particular_player_model.dart';
// import 'package:sm_project/controller/model/get_setting_model.dart' as setting;
// import 'package:sm_project/features/card_jackpot/jackpot_payment_notifier.dart';
// import 'package:sm_project/utils/filecollection.dart';
// import 'package:upi_india/upi_india.dart';
//
// void showPaymentPopUp({required BuildContext context, required String title}) {
//   showModalBottomSheet(
//     context: context,
//     builder: (context) {
//       return PaymentPopUp(
//         title: title,
//       );
//     },
//   );
// }
//
// class PaymentPopUp extends StatefulWidget {
//   final String title;
//   const PaymentPopUp({required this.title, super.key});
//
//   @override
//   State<PaymentPopUp> createState() => _PaymentPopUpState();
// }
//
// class _PaymentPopUpState extends State<PaymentPopUp> {
//   final UpiIndia _upiIndia = UpiIndia();
//   List<UpiApp>? apps;
//   // ignore: unused_field
//   Future<UpiResponse>? _transaction;
//   setting.GetSettingModel? getSettingModel = setting.GetSettingModel();
//   final Data? userDgetParticularUserData =
//       UserParticularPlayer.getParticularUserData();
//
//   @override
//   void initState() {
//     super.initState();
//     EasyLoading.show(status: 'loading...');
//     _upiIndia.getAllUpiApps(mandatoryTransactionId: true).then((value) {
//       setState(() {
//         apps = value;
//       });
//     }).catchError((e) {
//       apps = [];
//     });
//     getSetting();
//     EasyLoading.dismiss();
//   }
//
//   Future<void> getSetting() async {
//     EasyLoading.show(status: 'loading...');
//     getSettingModel = await ApiService().getSettingModel();
//     EasyLoading.dismiss();
//   }
//
//   Future<String> getTransactionReferenceId() async {
//     var id = userDgetParticularUserData?.sId;
//     if (id != null && id.isNotEmpty) {
//       var transRefId = id + DateTime.now().microsecondsSinceEpoch.toString();
//       log('transRefId: $transRefId');
//       return transRefId;
//     } else {
//       log('UserNotLoggedIn');
//       return "UserNotLoggedIn";
//     }
//   }
//
//   Future<UpiResponse> initiateTransaction(
//       {required UpiApp app, required double amount}) async {
//     return _upiIndia.startTransaction(
//       app: app,
//       receiverUpiId: getSettingModel?.data?.merchantUpi ?? '',
//       receiverName: getSettingModel?.data?.merchantName ?? '',
//       transactionRefId: await getTransactionReferenceId(),
//       transactionNote: 'deposit funds',
//       amount: amount,
//     );
//   }
//
//   Widget displayUpiApps() {
//     if (apps == null) {
//       return const Center(
//         child: Text(
//           "No apps found to handle transaction.",
//           style: TextStyle(
//             fontSize: 20,
//             color: Colors.black,
//           ),
//         ),
//       );
//     } else if (apps!.isEmpty) {
//       return const Center(
//         child: Text(
//           "No apps found to handle transaction.",
//           style: TextStyle(
//             fontSize: 20,
//             color: Colors.black,
//           ),
//         ),
//       );
//     } else {
//       return Consumer(builder: (context, ref, child) {
//         final jackpotPaymentData =
//             ref.watch(jackpotPaymentNotifierProvider).value;
//         final refRead = ref.read(jackpotPaymentNotifierProvider.notifier);
//         return Padding(
//           padding: const EdgeInsets.only(left: 8.0),
//           child: GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 4,
//               crossAxisSpacing: 8.0,
//               mainAxisSpacing: 8.0,
//             ),
//             itemCount: apps!.length,
//             itemBuilder: (context, index) {
//               UpiApp app = apps![index];
//               return GestureDetector(
//                   onTap: () {
//                     refRead.updateUpiApp(app);
//                   },
//                   child: Card(
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(60)),
//                     child: Container(
//                         height: 100,
//                         decoration: BoxDecoration(
//                           color: jackpotPaymentData?.app?.name == app.name
//                               ? darkBlue
//                               : Colors.white,
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             width: 1,
//                             color: const Color(0xffE6E6E6),
//                           ),
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.memory(app.icon, width: 40, height: 40),
//                           ],
//                         )),
//                   ));
//             },
//           ),
//         );
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.max,
//       children: [
//         Container(
//           width: double.infinity,
//           decoration: const BoxDecoration(
//             color: darkBlue,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(16),
//               topRight: Radius.circular(16),
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Center(
//               child: Text(
//                 "SELECTED ${widget.title}",
//                 style: const TextStyle(
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(
//           height: 16,
//         ),
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Balance",
//                     style: TextStyle(fontSize: 18),
//                   ),
//                   Consumer(builder: (context, ref, child) {
//                     final jackpotPaymentData =
//                         ref.watch(jackpotPaymentNotifierProvider).value;
//                     final refRead =
//                         ref.read(jackpotPaymentNotifierProvider.notifier);
//                     return SizedBox(
//                       height: 40,
//                       child: ListView.builder(
//                         itemCount: jackpotPaymentData?.balanceFields.length,
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         scrollDirection: Axis.horizontal,
//                         itemBuilder: (context, index) {
//                           final balance =
//                               jackpotPaymentData?.balanceFields[index];
//                           return Padding(
//                             padding: const EdgeInsets.only(right: 8.0),
//                             child: InkWell(
//                               onTap: () {
//                                 refRead.updateBalanceField(balance ?? 0);
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: balance ==
//                                           jackpotPaymentData
//                                               ?.selectedBalanceField
//                                       ? darkBlue
//                                       : const Color(0xfff7f8f9),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                     left: 8.0,
//                                     right: 8,
//                                     top: 5,
//                                     bottom: 5,
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       "${balance?.toString()}",
//                                       style: const TextStyle(fontSize: 18),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Quantity",
//                     style: TextStyle(fontSize: 18),
//                   ),
//                   Consumer(builder: (context, ref, child) {
//                     final refWatch =
//                         ref.watch(jackpotPaymentNotifierProvider).value;
//                     final refRead =
//                         ref.read(jackpotPaymentNotifierProvider.notifier);
//                     return Row(
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             HapticFeedback.selectionClick();
//                             refRead.quantityDecrement();
//                           },
//                           child: Container(
//                             color: darkBlue,
//                             width: 42,
//                             height: 40,
//                             child: const Icon(Icons.remove),
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 6,
//                         ),
//                         SizedBox(
//                           width: 90,
//                           height: 40,
//                           child: TextFormField(
//                             controller: refWatch?.quantity,
//                             textAlign: TextAlign.center,
//                             textAlignVertical: TextAlignVertical.center,
//                             decoration: InputDecoration(
//                               isDense: true,
//                               contentPadding: const EdgeInsets.only(
//                                 top: 10,
//                                 bottom: 10,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(0),
//                                 borderSide: BorderSide(
//                                   color: Colors.grey.shade100,
//                                   width: 0.2,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 6,
//                         ),
//                         InkWell(
//                           onTap: () {
//                             HapticFeedback.selectionClick();
//                             refRead.quantityIncrement();
//                           },
//                           child: Container(
//                             color: darkBlue,
//                             width: 42,
//                             height: 40,
//                             child: const Icon(Icons.add),
//                           ),
//                         ),
//                       ],
//                     );
//                   }),
//                 ],
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Consumer(builder: (context, ref, child) {
//                 final jackpotPaymentData =
//                     ref.watch(jackpotPaymentNotifierProvider).value;
//                 final refRead =
//                     ref.read(jackpotPaymentNotifierProvider.notifier);
//                 return SizedBox(
//                   height: 40,
//                   child: ListView.builder(
//                     itemCount: jackpotPaymentData?.quantityMultiplier.length,
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     scrollDirection: Axis.horizontal,
//                     itemBuilder: (context, index) {
//                       final quantityMultiplier =
//                           jackpotPaymentData?.quantityMultiplier[index];
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 10.0),
//                         child: InkWell(
//                           onTap: () {
//                             refRead.updateQuanityMultiplier(
//                                 quantityMultiplier ?? 0);
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: quantityMultiplier ==
//                                       jackpotPaymentData
//                                           ?.selectedQuantityMutliplier
//                                   ? darkBlue
//                                   : const Color(0xfff7f8f9),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(6.0),
//                               child: Center(
//                                 child: Text(
//                                   "X${quantityMultiplier?.toString()}",
//                                   style: const TextStyle(fontSize: 18),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               }),
//             ],
//           ),
//         ),
//         displayUpiApps(),
//         const Spacer(),
//         Row(
//           children: [
//             Expanded(
//               flex: 2,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.zero,
//                   ),
//                   fixedSize: const Size.fromHeight(50),
//                 ),
//                 onPressed: () {
//                   context.pop();
//                 },
//                 child: const Text("Back"),
//               ),
//             ),
//             Expanded(
//               flex: 3,
//               child: Consumer(builder: (context, ref, child) {
//                 final jackpotPaymentData =
//                     ref.watch(jackpotPaymentNotifierProvider).value;
//                 return ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     shape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.zero,
//                     ),
//                     fixedSize: const Size.fromHeight(50),
//                   ),
//                   onPressed: () {
//                     if (jackpotPaymentData?.app != null) {
//                       _transaction = initiateTransaction(
//                         app: jackpotPaymentData!.app!,
//                         amount: jackpotPaymentData.totalAmount.toDouble(),
//                       );
//                     } else {
//                       toast('Please select payment app');
//                     }
//                   },
//                   child: Text(
//                       "TOTAL AMOUNT: ${jackpotPaymentData?.totalAmount ?? ""}"),
//                 );
//               }),
//             )
//           ],
//         ),
//       ],
//     );
//   }
// }
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart'; // Updated
import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_particular_player_model.dart';
import 'package:sm_project/controller/model/get_setting_model.dart' as setting;
import 'package:sm_project/features/card_jackpot/jackpot_payment_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

void showPaymentPopUp({required BuildContext context, required String title}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: PaymentPopUp(title: title),
      );
    },
  );
}

class PaymentPopUp extends StatefulWidget {
  final String title;
  const PaymentPopUp({required this.title, super.key});

  @override
  State<PaymentPopUp> createState() => _PaymentPopUpState();
}

class _PaymentPopUpState extends State<PaymentPopUp> {
  List<ApplicationMeta>? apps;
  setting.GetSettingModel? getSettingModel = setting.GetSettingModel();
  final Data? userDgetParticularUserData = UserParticularPlayer.getParticularUserData();

  @override
  void initState() {
    super.initState();
    _fetchApps();
    getSetting();
  }

  Future<void> _fetchApps() async {
    try {
      final value = await UpiPay.getInstalledUpiApplications();
      setState(() {
        apps = value;
      });
    } catch (e) {
      log("Error fetching apps: $e");
      setState(() => apps = []);
    }
  }

  Future<void> getSetting() async {
    getSettingModel = await ApiService().getSettingModel();
    if (mounted) setState(() {});
  }

  Future<String> getTransactionReferenceId() async {
    var id = userDgetParticularUserData?.sId;
    if (id != null && id.isNotEmpty) {
      return id + DateTime.now().microsecondsSinceEpoch.toString();
    }
    return "UserNotLoggedIn";
  }

  Future<void> handleTransaction({required ApplicationMeta appMeta, required double amount}) async {
    try {
      EasyLoading.show(status: 'Opening ${appMeta.upiApplication.getAppName()}...');

      final response = await UpiPay.initiateTransaction(
        app: appMeta.upiApplication,
        receiverUpiAddress: getSettingModel?.data?.merchantUpi ?? '',
        receiverName: getSettingModel?.data?.merchantName ?? '',
        transactionRef: await getTransactionReferenceId(),
        transactionNote: 'Jackpot Entry',
        amount: amount.toStringAsFixed(2),
      );

      EasyLoading.dismiss();
      _processResponse(response);
    } catch (e) {
      EasyLoading.dismiss();
      toast("Error launching UPI app");
    }
  }

  void _processResponse(UpiTransactionResponse response) {
    if (response.status == UpiTransactionStatus.success) {
      toast("Payment Successful");
      if (mounted) Navigator.pop(context);
    } else if (response.status == UpiTransactionStatus.failure) {
      toast("Payment Failed");
    } else {
      toast("Payment Cancelled/Pending");
    }
  }

  Widget displayUpiApps() {
    if (apps == null) return const Center(child: CircularProgressIndicator());
    if (apps!.isEmpty) return const Center(child: Text("No UPI apps found"));

    return Consumer(builder: (context, ref, child) {
      final jackpotPaymentData = ref.watch(jackpotPaymentNotifierProvider).value;
      final refRead = ref.read(jackpotPaymentNotifierProvider.notifier);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: apps!.length,
          itemBuilder: (context, index) {
            ApplicationMeta app = apps![index];

            final String currentAppName = app.upiApplication.getAppName();
            final String? selectedAppName = jackpotPaymentData?.app?.upiApplication.getAppName();

            // FIX: Explicitly declared the bool
            final bool isSelected = currentAppName == selectedAppName;

            return GestureDetector(
              onTap: () => refRead.updateUpiApp(app),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? darkBlue : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(width: 1, color: const Color(0xffE6E6E6)),
                ),
                child: Center(
                  child: app.iconImage(40),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: darkBlue,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "SELECTED ${widget.title}",
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Balance", style: TextStyle(fontSize: 18)),
                  Consumer(builder: (context, ref, child) {
                    final jackpotPaymentData = ref.watch(jackpotPaymentNotifierProvider).value;
                    final refRead = ref.read(jackpotPaymentNotifierProvider.notifier);
                    return SizedBox(
                      height: 40,
                      child: ListView.builder(
                        itemCount: jackpotPaymentData?.balanceFields.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final balance = jackpotPaymentData?.balanceFields[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () => refRead.updateBalanceField(balance ?? 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: balance == jackpotPaymentData?.selectedBalanceField
                                      ? darkBlue
                                      : const Color(0xfff7f8f9),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                                  child: Center(
                                    child: Text("${balance?.toString()}", style: const TextStyle(fontSize: 18)),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Quantity", style: TextStyle(fontSize: 18)),
                  Consumer(builder: (context, ref, child) {
                    final refWatch = ref.watch(jackpotPaymentNotifierProvider).value;
                    final refRead = ref.read(jackpotPaymentNotifierProvider.notifier);
                    return Row(
                      children: [
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            refRead.quantityDecrement();
                          },
                          child: Container(color: darkBlue, width: 42, height: 40, child: const Icon(Icons.remove)),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 90,
                          height: 40,
                          child: TextFormField(
                            controller: refWatch?.quantity,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide: BorderSide(color: Colors.grey.shade100, width: 0.2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            refRead.quantityIncrement();
                          },
                          child: Container(color: darkBlue, width: 42, height: 40, child: const Icon(Icons.add)),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
              Consumer(builder: (context, ref, child) {
                final jackpotPaymentData = ref.watch(jackpotPaymentNotifierProvider).value;
                final refRead = ref.read(jackpotPaymentNotifierProvider.notifier);
                return SizedBox(
                  height: 40,
                  child: ListView.builder(
                    itemCount: jackpotPaymentData?.quantityMultiplier.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final quantityMultiplier = jackpotPaymentData?.quantityMultiplier[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: InkWell(
                          onTap: () => refRead.updateQuanityMultiplier(quantityMultiplier ?? 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: quantityMultiplier == jackpotPaymentData?.selectedQuantityMutliplier
                                  ? darkBlue
                                  : const Color(0xfff7f8f9),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Center(
                                child: Text("X${quantityMultiplier?.toString()}", style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        displayUpiApps(),
        const Spacer(),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  fixedSize: const Size.fromHeight(50),
                ),
                onPressed: () => context.pop(),
                child: const Text("Back"),
              ),
            ),
            Expanded(
              flex: 3,
              child: Consumer(builder: (context, ref, child) {
                final jackpotPaymentData = ref.watch(jackpotPaymentNotifierProvider).value;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    fixedSize: const Size.fromHeight(50),
                  ),
                  onPressed: () {
                    if (jackpotPaymentData?.app != null) {
                      handleTransaction(
                        appMeta: jackpotPaymentData!.app!,
                        amount: jackpotPaymentData.totalAmount.toDouble(),
                      );
                    } else {
                      toast('Please select payment app');
                    }
                  },
                  child: Text("PAY: ${jackpotPaymentData?.totalAmount ?? ""}"),
                );
              }),
            )
          ],
        ),
      ],
    );
  }
}