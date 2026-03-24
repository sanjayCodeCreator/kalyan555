// import 'package:flutter/material.dart';
// import 'package:matka/common/color.dart';
// import 'package:matka/common/font_style.dart';
// import 'package:matka/provider/auth_provider.dart';
// import 'package:matka/provider/funds_provider.dart';
// import 'package:matka/provider/get_bank_details.dart';
// import 'package:matka/screens/widgets/custom_appbar.dart';
// import 'package:matka/screens/widgets/custom_button.dart';
// import 'package:matka/services/funds/deposit_funds_api.dart';
// import 'package:matka/services/funds/get_admin_merchant_account_details_api.dart';
// import 'package:provider/provider.dart';
// import 'package:upi_india/upi_india.dart';

// class AddfundsScreen extends StatefulWidget {
//   const AddfundsScreen({super.key});

//   @override
//   State<AddfundsScreen> createState() => _AddfundsScreenState();
// }

// class _AddfundsScreenState extends State<AddfundsScreen> {
//   final _amountController = TextEditingController();
//   Future<UpiResponse>? _transaction;
//   final UpiIndia _upiIndia = UpiIndia();
//   List<UpiApp>? apps;
//   double amount = 0;

//   TextStyle header = const TextStyle(
//     fontSize: 18,
//     fontWeight: FontWeight.bold,
//   );

//   TextStyle value = const TextStyle(
//     fontWeight: FontWeight.w400,
//     fontSize: 14,
//   );

//   @override
//   void initState() {
//     _upiIndia.getAllUpiApps(mandatoryTransactionId: true).then((value) {
//       setState(() {
//         apps = value;
//       });
//     }).catchError((e) {
//       apps = [];
//     });
//     getMerchantDetailsApi(context);
//     super.initState();
//   }

//   Future<String> getTransactionReferenceId() async {
//     var id =
//         await Provider.of<AuthProvider>(context, listen: false).loadUserId();
//     if (id != null && id.isEmpty) {
//       var transRefId = id + DateTime.now().microsecondsSinceEpoch.toString();
//       return transRefId;
//     } else {
//       return "UserNotLoggedIn";
//     }
//   }

//   Future<UpiResponse> initiateTransaction(UpiApp app) async {
//     final funds = Provider.of<FundsProvider>(context, listen: false);
//     debugPrint(
//         "Merchant upi id is ${funds.merchantPaymentDetailsModel.data.merchantUpi}");
//     debugPrint(
//         "Merchant upi name is ${funds.merchantPaymentDetailsModel.data.merchantName}");
//     amount = double.parse(_amountController.text.trim());

//     return _upiIndia.startTransaction(
//       app: app,
//       receiverUpiId: funds.merchantPaymentDetailsModel.data.merchantUpi,
//       receiverName: funds.merchantPaymentDetailsModel.data.merchantName,
//       transactionRefId: await getTransactionReferenceId(),
//       transactionNote: 'deposit funds',
//       amount: amount,
//     );
//   }

//   Widget displayUpiApps() {
//     if (apps == null) {
//       return Center(
//         child: Text(
//           "No apps found to handle transaction.",
//           style: header,
//         ),
//       );
//     } else if (apps!.isEmpty) {
//       return Center(
//         child: Text(
//           "No apps found to handle transaction.",
//           style: header,
//         ),
//       );
//     } else {
//       return GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           crossAxisSpacing: 8.0,
//           mainAxisSpacing: 8.0,
//         ),
//         itemCount: apps!.length,
//         itemBuilder: (context, index) {
//           UpiApp app = apps![index];
//           return GestureDetector(
//             onTap: () {
//               if (_formKey.currentState!.validate()) {
//                 _formKey.currentState!.save();
//                 _transaction = initiateTransaction(app);
//                 // ScaffoldMessenger.of(context).showSnackBar(
//                 //   SnackBar(
//                 //     content:
//                 //         Text('Value submitted: ${_amountController.value}'),
//                 //   ),
//                 // );
//               }
//               setState(() {});
//             },
//             child: Container(
//               height: 112,
//               //width: 105,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(
//                   width: 1,
//                   color: const Color(0xffE6E6E6),
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.memory(
//                     app.icon,
//                     width: 38,
//                     height: 38,
//                   ),
//                   Text(
//                     app.name,
//                     style: fontStyleSmallBold,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     }
//   }

//   String _upiErrorHandler(error) {
//     switch (error) {
//       case UpiIndiaAppNotInstalledException:
//         return 'Requested app not installed on device';
//       case UpiIndiaUserCancelledException:
//         return 'You cancelled the transaction';
//       case UpiIndiaNullResponseException:
//         return 'Requested app didn\'t return any response';
//       case UpiIndiaInvalidParametersException:
//         return 'Requested app cannot handle the transaction';
//       default:
//         return 'An Unknown error has occurred';
//     }
//   }

//   void _checkTxnStatus(String status) {
//     switch (status) {
//       case UpiPaymentStatus.SUCCESS:
//         debugPrint('Transaction Successful');
//         break;
//       case UpiPaymentStatus.SUBMITTED:
//         debugPrint('Transaction Submitted');
//         break;
//       case UpiPaymentStatus.FAILURE:
//         debugPrint('Transaction Failed');
//         break;
//       default:
//         debugPrint('Received an Unknown transaction status');
//     }
//   }


//   @override
//   void dispose() {
//     _amountController.dispose();
//     super.dispose();
//   }

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(text: "Deposit Funds"),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Consumer<UserProvider>(builder: (context, userProvider, child) {
//           return SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                     height: 180,
//                     width: 335,
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(16),
//                         color: const Color(0xffF3F3F3)),
//                     child: Column(
//                       children: [
//                         const SizedBox(
//                           height: 20,
//                         ),
//                         Image.asset(
//                           "assets/funds_image/wallet.png",
//                           height: 60,
//                           width: 60,
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Available Balance",
//                           style: fontStyleSmall,
//                         ),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               "\u{20B9}${userProvider.userData.wallet.toString()}",
//                               style: fontStyleXLarge,
//                             )
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 20,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 40,
//                   ),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       "Add Fund Request",
//                       style: fontStyleMediumBold,
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   TextFormField(
//                     controller: _amountController,
                    // validator: (value) {
                    //   final funds =
                    //       Provider.of<FundsProvider>(context, listen: false);

                    //   if (value == null || value.isEmpty) {
                    //     return 'Please enter some text';
                    //   } else if (int.parse(value) <
                    //       funds.merchantPaymentDetailsModel.data.deposit.min) {
                    //     return 'minimum deposite value ${funds.merchantPaymentDetailsModel.data.deposit.min}';
                    //   } else if (int.parse(value) >
                    //       funds.merchantPaymentDetailsModel.data.deposit.max) {
                    //     return 'Maximum depopsite value ${funds.merchantPaymentDetailsModel.data.deposit.max}';
                    //   }

                    //   return null;
                    // },
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       hintText: "Enter Amount",
//                     ),
//                     obscureText: false,
//                   ),
//                   // CustomTextField(
//                   //   prefixIcon: const Icon(Icons.currency_rupee_outlined),
//                   //   controller: _amountController,

//                   //   hintText: "Enter Amount",
//                   //   obscureText: false,
//                   //   keyboard: TextInputType.number,
//                   // ),
//                   const SizedBox(
//                     height: 16,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         child: CustomButton(
//                           textcolor: themeColor,
//                           color: whiteColor,
//                           text: "500",
//                           onTap: () {
//                             _amountController.text = 500.toString();
//                           },
//                           borderRadius: 10,
//                           //width: 105,
//                           height: 36,
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 10,
//                       ),
//                       Expanded(
//                         child: CustomButton(
//                           textcolor: themeColor,
//                           color: whiteColor,
//                           text: "1000",
//                           onTap: () {
//                             _amountController.text = 1000.toString();
//                           },
//                           borderRadius: 10,
//                           height: 36,
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 10,
//                       ),
//                       Expanded(
//                         child: CustomButton(
//                           textcolor: themeColor,
//                           color: whiteColor,
//                           text: "2000",
//                           onTap: () {
//                             _amountController.text = 2000.toString();
//                           },
//                           borderRadius: 10,
//                           // width: 105,
//                           height: 36,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 16,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         child: CustomButton(
//                           textcolor: themeColor,
//                           color: whiteColor,
//                           text: "5000",
//                           onTap: () {
//                             _amountController.text = 5000.toString();
//                           },
//                           borderRadius: 10,
//                           //width: 105,
//                           height: 36,
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 10,
//                       ),
//                       Expanded(
//                         child: CustomButton(
//                           textcolor: themeColor,
//                           color: whiteColor,
//                           text: "10000",
//                           onTap: () {
//                             _amountController.text = 10000.toString();
//                           },
//                           borderRadius: 10,
//                           // width: 105,
//                           height: 36,
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 10,
//                       ),
//                       Expanded(
//                         child: CustomButton(
//                           textcolor: themeColor,
//                           color: whiteColor,
//                           text: "20000",
//                           onTap: () {
//                             _amountController.text = 20000.toString();
//                           },
//                           borderRadius: 10,
//                           // width: 105,
//                           height: 36,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 40,
//                   ),
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       "Add Fund Request",
//                       style: fontStyleMediumBold,
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   displayUpiApps(),
//                   FutureBuilder(
//                     future: _transaction,
//                     builder: (BuildContext context,
//                         AsyncSnapshot<UpiResponse> snapshot) {
//                       if (snapshot.connectionState == ConnectionState.done) {
//                         if (snapshot.hasError) {
//                           // showCustomSnackBar(context,
//                           //     _upiErrorHandler(snapshot.error.runtimeType));
//                           debugPrint(
//                               _upiErrorHandler(snapshot.error.runtimeType));

//                           return const SizedBox();
//                         }

//                         UpiResponse upiResponse = snapshot.data!;

//                         //! Data in UpiResponse can be null.
//                         String txnId = upiResponse.transactionId ?? 'N/A';
//                         //String resCode = upiResponse.responseCode ?? 'N/A';
//                         String txnRef = upiResponse.transactionRefId ?? 'N/A';
//                         String status = upiResponse.status ?? 'N/A';
//                         // String approvalRef = upiResponse.approvalRefNo ?? 'N/A';
//                         _checkTxnStatus(status);
//                         debugPrint(
//                             "response after transaction is $txnId $status $txnRef");
//                         //  if (_formKey.currentState!.validate()) {
//                         //     _formKey.currentState!.save();
//                         //     ScaffoldMessenger.of(context).showSnackBar(
//                         //       SnackBar(
//                         //         content: Text('Value submitted: $_textFieldValue'),
//                         //       ),
//                         //     );
//                         //   }
//                         submitDepositApi(context, amount.toString(), txnId,
//                             txnRef, status.toUpperCase());

//                         // if (_amountController.text.isNotEmpty) {
//                         //   _amountController.clear();
//                         // }

//                         //! submiting response to backend through api

//                         return const SizedBox();

//                         // return Padding(
//                         //   padding: const EdgeInsets.all(8.0),
//                         //   child: Column(
//                         //     mainAxisAlignment: MainAxisAlignment.center,
//                         //     children: <Widget>[
//                         //       displayTransactionData('Transaction Id', txnId),
//                         //       displayTransactionData('Response Code', resCode),
//                         //       displayTransactionData('Reference Id', txnRef),
//                         //       displayTransactionData(
//                         //           'Status', status.toUpperCase()),
//                         //       displayTransactionData('Approval No', approvalRef),
//                         //     ],
//                         //   ),
//                         // );
//                       } else {
//                         return const Center(
//                           child: Text(''),
//                         );
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

// // const SizedBox(
//               //   height: 10,
//               // ),
//               // Row(
//               //   mainAxisAlignment: MainAxisAlignment.center,
//               //   children: [
//               //     Expanded(
//               //       child: Container(
//               //         height: 112,
//               //         //width: 105,
//               //         decoration: BoxDecoration(
//               //           borderRadius: BorderRadius.circular(10),
//               //           border: Border.all(
//               //             width: 1,
//               //             color: const Color(0xffE6E6E6),
//               //           ),
//               //         ),
//               //         child: Column(
//               //           mainAxisAlignment: MainAxisAlignment.center,
//               //           children: [
//               //             GestureDetector(
//               //               onTap: () {},
//               //               child: Image.asset(
//               //                 "assets/funds_image/gpay_image.png",
//               //                 width: 38,
//               //                 height: 38,
//               //               ),
//               //             ),
//               //             Text(
//               //               "Google Pay",
//               //               style: fontStyleSmallBold,
//               //             ),
//               //             Text(
//               //               "Auto Approve",
//               //               style: fontStyleVerySmall,
//               //             ),
//               //           ],
//               //         ),
//               //       ),
//               //     ),
//               //     const SizedBox(
//               //       width: 10,
//               //     ),
//               //     Expanded(
//               //       child: Container(
//               //         height: 112,
//               //         decoration: BoxDecoration(
//               //           borderRadius: BorderRadius.circular(10),
//               //           border: Border.all(
//               //             width: 1,
//               //             color: const Color(0xffE6E6E6),
//               //           ),
//               //         ),
//               //         child: Column(
//               //           mainAxisAlignment: MainAxisAlignment.center,
//               //           children: [
//               //             Image.asset(
//               //               "assets/funds_image/phonepe_image.png",
//               //               width: 38,
//               //               height: 38,
//               //             ),
//               //             Text(
//               //               "PhonePe",
//               //               style: fontStyleSmallBold,
//               //             ),
//               //             Text(
//               //               "Manual Approve",
//               //               style: fontStyleVerySmall,
//               //             ),
//               //           ],
//               //         ),
//               //       ),
//               //     ),
//               //     const SizedBox(
//               //       width: 10,
//               //     ),
//               //     Expanded(
//               //       child: Container(
//               //         height: 112,
//               //         decoration: BoxDecoration(
//               //           borderRadius: BorderRadius.circular(10),
//               //           border: Border.all(
//               //             width: 1,
//               //             color: const Color(0xffE6E6E6),
//               //           ),
//               //         ),
//               //         child: Column(
//               //           mainAxisAlignment: MainAxisAlignment.center,
//               //           children: [
//               //             Image.asset(
//               //               "assets/funds_image/paytm_image.png",
//               //               width: 38,
//               //               height: 38,
//               //             ),
//               //             Text(
//               //               "Paytm",
//               //               style: fontStyleSmallBold,
//               //             ),
//               //             Text(
//               //               "Auto Approve",
//               //               style: fontStyleVerySmall,
//               //             ),
//               //           ],
//               //         ),
//               //       ),
//               //     ),
//               //   ],
//               // ),