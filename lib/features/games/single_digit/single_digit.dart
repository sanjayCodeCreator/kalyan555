// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
// import 'package:sm_project/features/games/everything_okay.dart';
// import 'package:sm_project/features/games/open_close_component.dart';
// import 'package:sm_project/features/games/single_digit/single_digit_notifier.dart';
// import 'package:sm_project/utils/filecollection.dart';

// import '../../../utils/realtime_timer.dart';

// class SingleDigit extends HookConsumerWidget {
//   final String? tag;
//   final String? marketId;
//   final String? marketName;
//   final int? minBet;
//   final int? maxBet;
//   const SingleDigit(
//       {this.marketName,
//       super.key,
//       this.tag,
//       this.marketId,
//       this.minBet,
//       this.maxBet});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final refRead = ref.read(getParticularPlayerNotifierProvider.notifier);
//     useEffect(() {
//       refRead.getParticularPlayerModel(context: context);
//       return;
//     }, []);

//     return Scaffold(
//         backgroundColor: lightGreyColor,
//         bottomNavigationBar: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Consumer(builder: (context, ref, child) {
//             final refRead = ref.read(singleDigitNotifierProvider.notifier);
//             return InkWell(
//               onTap: () {
//                 if (isStopGameExecution(
//                     context: context, ref: ref, marketId: marketId ?? '')) {
//                   return;
//                 }
//                 refRead.onSubmitConfirm(context, tag ?? '', marketId ?? '');
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(6),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: whiteBackgroundColor,
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: const Text(
//                   'Confirm',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 20,
//                       fontWeight: FontWeight.w900),
//                 ),
//               ),
//             );
//           }),
//         ),
//         body: SafeArea(
//             child: SingleChildScrollView(
//           padding: const EdgeInsets.all(15.0),
//           child: Column(children: [
//             Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: whiteBackgroundColor,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     Text(
//                       '$marketName - Single Digit',
//                       style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black),
//                     ),
//                   ],
//                 )),
//             const SizedBox(height: 15),
//             OpenCloseComponent(marketId: marketId ?? ""),
//             Row(
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Container(
//                     height: MediaQuery.of(context).size.height * 0.05,
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: whiteBackgroundColor,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Text('Select start digit of jodi:',
//                         overflow: TextOverflow.ellipsis,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: textColor)),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   flex: 2,
//                   child: Container(
//                       height: MediaQuery.of(context).size.height * 0.05,
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: whiteBackgroundColor,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: const TimerComponent()),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 15),
//             Consumer(builder: (context, ref, child) {
//               final refWatch = ref.watch(singleDigitNotifierProvider);
//               final refRead = ref.read(singleDigitNotifierProvider.notifier);
//               return SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(children: [
//                     for (int i = 0; i <= 9; i++)
//                       InkWell(
//                           onTap: () {
//                             refRead.setStartDigit(i);
//                           },
//                           child: SizedBox(
//                               height: 36,
//                               child: Container(
//                                   margin: const EdgeInsets.only(right: 7),
//                                   height:
//                                       MediaQuery.of(context).size.height * 0.05,
//                                   padding: const EdgeInsets.all(10),
//                                   decoration: BoxDecoration(
//                                     color: refWatch.value?.startDigit == i
//                                         ? buttonColor
//                                         : whiteBackgroundColor,
//                                     borderRadius: BorderRadius.circular(2),
//                                   ),
//                                   child: Text(i.toString(),
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                           color: refWatch.value?.startDigit == i
//                                               ? whiteBackgroundColor
//                                               : textColor))))),
//                   ]));
//             }),
//             const SizedBox(height: 15),
//             Container(
//                 padding: const EdgeInsets.fromLTRB(20, 2, 6, 12),
//                 decoration: BoxDecoration(
//                   color: whiteBackgroundColor,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Row(children: [
//                   const Padding(
//                       padding: EdgeInsets.only(top: 10.0),
//                       child: Text('Enter Points:',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black))),
//                   const SizedBox(width: 25),
//                   Consumer(builder: (context, ref, child) {
//                     final refWatch = ref.watch(singleDigitNotifierProvider);
//                     return SizedBox(
//                         width: MediaQuery.of(context).size.width * 0.3,
//                         child: CustomTextFormField(
//                             controller: refWatch.value?.addPointsController,
//                             keyboardType: TextInputType.number));
//                   })
//                 ])),
//             const SizedBox(height: 15),
//             Consumer(builder: (context, ref, child) {
//               final refRead = ref.read(singleDigitNotifierProvider.notifier);
//               return InkWell(
//                   onTap: () {
//                     refRead.addPoints(context);
//                   },
//                   child: Container(
//                       padding: const EdgeInsets.all(6),
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: whiteBackgroundColor,
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       child: const Text('ADD',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w900))));
//             }),
//             const SizedBox(height: 15),
//             Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: whiteBackgroundColor,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(children: [
//                   Column(
//                     children: [
//                       Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                                 padding:
//                                     const EdgeInsets.fromLTRB(10, 5, 10, 5),
//                                 decoration: BoxDecoration(
//                                     border: Border.all(
//                                         width: 1, color: Colors.grey),
//                                     borderRadius: BorderRadius.circular(10)),
//                                 child: const Text('Session',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.black))),
//                             Container(
//                                 padding:
//                                     const EdgeInsets.fromLTRB(10, 5, 10, 5),
//                                 decoration: BoxDecoration(
//                                     border: Border.all(
//                                         width: 1, color: Colors.grey),
//                                     borderRadius: BorderRadius.circular(10)),
//                                 child: const Text('No.',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.black))),
//                             Container(
//                                 padding:
//                                     const EdgeInsets.fromLTRB(10, 5, 10, 5),
//                                 decoration: BoxDecoration(
//                                     border: Border.all(
//                                         width: 1, color: Colors.grey),
//                                     borderRadius: BorderRadius.circular(10)),
//                                 child: const Text('Points',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.black))),
//                             InkWell(
//                               onTap: () {
//                                 ref
//                                     .read(singleDigitNotifierProvider.notifier)
//                                     .deleteAll(context);
//                               },
//                               child: Container(
//                                   padding:
//                                       const EdgeInsets.fromLTRB(10, 5, 10, 5),
//                                   decoration: BoxDecoration(
//                                       border: Border.all(
//                                           width: 1, color: Colors.grey),
//                                       borderRadius: BorderRadius.circular(10)),
//                                   child: const Text('Delete All',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.red))),
//                             )
//                           ]),

//                       // List of numbers and points
//                       Container(
//                         width: MediaQuery.of(context).size.width,
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: whiteBackgroundColor,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Consumer(builder: (context, ref, child) {
//                           final refWatch =
//                               ref.watch(singleDigitNotifierProvider);
//                           final refRead =
//                               ref.read(singleDigitNotifierProvider.notifier);
//                           return ListView.builder(
//                               shrinkWrap: true,
//                               itemCount:
//                                   refWatch.value?.selectedNumberList.length ??
//                                       0,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemBuilder: (context, index) {
//                                 return Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Container(
//                                                 padding:
//                                                     const EdgeInsets.fromLTRB(
//                                                         10, 5, 10, 5),
//                                                 decoration: BoxDecoration(
//                                                     border: Border.all(
//                                                         width: 1,
//                                                         color: Colors.grey),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10)),
//                                                 child: Text(
//                                                     refWatch.value
//                                                             ?.isClosed[index]
//                                                             .toString() ??
//                                                         '',
//                                                     textAlign: TextAlign.center,
//                                                     style: const TextStyle(
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.black))),
//                                             Container(
//                                                 padding:
//                                                     const EdgeInsets.fromLTRB(
//                                                         10, 5, 10, 5),
//                                                 decoration: BoxDecoration(
//                                                     border: Border.all(
//                                                         width: 1,
//                                                         color: Colors.grey),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10)),
//                                                 child: Text(
//                                                     refWatch.value?.selectedNumberList[index]
//                                                             .toString() ??
//                                                         '',
//                                                     textAlign: TextAlign.center,
//                                                     style: const TextStyle(
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.black))),
//                                             Container(
//                                                 padding:
//                                                     const EdgeInsets.fromLTRB(
//                                                         10, 5, 10, 5),
//                                                 decoration: BoxDecoration(
//                                                     border: Border.all(
//                                                         width: 1,
//                                                         color: Colors.grey),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10)),
//                                                 child: Text(
//                                                     refWatch.value?.singleDigitList[index]
//                                                             .toString() ??
//                                                         '',
//                                                     textAlign: TextAlign.center,
//                                                     style: const TextStyle(
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.black))),
//                                             InkWell(
//                                               onTap: () {
//                                                 refRead.removePoints(
//                                                     context, index);
//                                               },
//                                               child: Container(
//                                                   padding:
//                                                       const EdgeInsets.fromLTRB(
//                                                           10, 5, 10, 5),
//                                                   decoration: BoxDecoration(
//                                                       border: Border.all(
//                                                           width: 1,
//                                                           color: Colors.grey),
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10)),
//                                                   child: const Icon(
//                                                       Icons.delete,
//                                                       color: Colors.red)),
//                                             )
//                                           ]),
//                                       const SizedBox(height: 15),
//                                     ]);
//                               });
//                         }),
//                       )
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: yellowColor,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(children: [
//                       Consumer(builder: (context, ref, child) {
//                         final refWatch = ref.watch(singleDigitNotifierProvider);
//                         return Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(children: [
//                                 const Text(
//                                   'Numbers',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: buttonForegroundColor,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                     refWatch.value?.totalSelectedNumber
//                                             .toString() ??
//                                         '',
//                                     textAlign: TextAlign.center,
//                                     style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: buttonForegroundColor))
//                               ]),
//                               Column(children: [
//                                 const Text('Points',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: buttonForegroundColor)),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                     refWatch.value?.totalPoints.toString() ??
//                                         '',
//                                     textAlign: TextAlign.center,
//                                     style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: buttonForegroundColor))
//                               ]),
//                               Column(children: [
//                                 const Text('Left Points',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: buttonForegroundColor)),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                     refWatch.value?.leftPoints.toString() ??
//                                         '0',
//                                     textAlign: TextAlign.center,
//                                     style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: buttonForegroundColor))
//                               ]),
//                             ]);
//                       })
//                     ]),
//                   )
//                 ])),
//             const SizedBox(height: 15),
//           ]),
//         )));
//   }
// }
