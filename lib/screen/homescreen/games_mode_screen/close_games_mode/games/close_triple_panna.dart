// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
// import 'package:sm_project/utils/filecollection.dart';

// import '../close_games_notifier.dart/close_triple_panna_notifier.dart';

// class CloseTriplePanna extends HookConsumerWidget {
//   final String? tag;
//   final String? marketId;
//   final String? marketName;
//   const CloseTriplePanna({super.key, this.tag, this.marketId, this.marketName});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final refParticularWatch = ref.watch(getParticularPlayerNotifierProvider);
//     useEffect(() {
//       ref
//           .read(getParticularPlayerNotifierProvider.notifier)
//           .getParticularPlayerModel(context:  context);
//       return;
//     }, []);
//     return Scaffold(
//         backgroundColor: lightGreyColor,
//         body: SafeArea(
//             child: SingleChildScrollView(
//           padding: const EdgeInsets.all(15.0),
//           child:
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
//                       '$marketName - Close - Triple Panna',
//                       style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black),
//                     ),
//                   ],
//                 )),
//             const SizedBox(height: 15),
//             Row(
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Container(
//                     height: MediaQuery.of(context).size.height * 0.05,
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: redColor,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Text('Fixed Number Mode',
//                         overflow: TextOverflow.ellipsis,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: whiteBackgroundColor)),
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 Expanded(
//                   flex: 2,
//                   child: Container(
//                     height: MediaQuery.of(context).size.height * 0.05,
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: whiteBackgroundColor,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image.asset(clockLogo),
//                         const SizedBox(width: 5),
//                         refParticularWatch.value?.getParticularPlayerModel
//                                     ?.currentTime !=
//                                 null
//                             ? Text(
//                                 refParticularWatch.value
//                                         ?.getParticularPlayerModel?.currentTime
//                                         .toString() ??
//                                     '',
//                                 style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: textColor))
//                             : Text('Getting time'),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Consumer(builder: (context, ref, child) {
//               final refWatch = ref.watch(closetriplePannaNotifierProvider);
//               return GridView.builder(
//                   padding: EdgeInsets.zero,
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       childAspectRatio: 2 / 0.85,
//                       crossAxisCount: 2,
//                       mainAxisSpacing: 2.0,
//                       crossAxisSpacing: 2),
//                   itemCount: refWatch.value?.numbers.length,
//                   itemBuilder: (context, index) {
//                     final triplePanna = refWatch.value?.numbers[index];

//                     return chooseNumber(
//                         context, triplePanna?.points.toString(), triplePanna);
//                   });
//             }),
//             const SizedBox(height: 20),
//             InkWell(
//               onTap: () {
//                 ref.read(closetriplePannaNotifierProvider.notifier).addPoints();
//               },
//               child: Container(
//                   padding: const EdgeInsets.all(6),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: whiteBackgroundColor,
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: const Text('ADD',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 20,
//                           fontWeight: FontWeight.w900))),
//             ),
//             const SizedBox(height: 15),
//             Container(
//                 padding: const EdgeInsets.all(10),
//                 height: MediaQuery.of(context).size.height * 0.5,
//                 decoration: BoxDecoration(
//                   color: whiteBackgroundColor,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(children: [
//                   Expanded(
//                     child: Column(
//                       children: [
//                         Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Container(
//                                   padding:
//                                       const EdgeInsets.fromLTRB(10, 5, 10, 5),
//                                   decoration: BoxDecoration(
//                                       border: Border.all(
//                                           width: 1, color: Colors.grey),
//                                       borderRadius: BorderRadius.circular(10)),
//                                   child: const Text('Numbers',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black))),
//                               Container(
//                                   padding:
//                                       const EdgeInsets.fromLTRB(10, 5, 10, 5),
//                                   decoration: BoxDecoration(
//                                       border: Border.all(
//                                           width: 1, color: Colors.grey),
//                                       borderRadius: BorderRadius.circular(10)),
//                                   child: const Text('Points',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black))),
//                               InkWell(
//                                 onTap: () {
//                                   ref
//                                       .read(
//                                           closetriplePannaNotifierProvider.notifier)
//                                       .deleteAll();
//                                 },
//                                 child: Container(
//                                     padding:
//                                         const EdgeInsets.fromLTRB(10, 5, 10, 5),
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             width: 1, color: Colors.grey),
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     child: const Text('Delete All',
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.red))),
//                               )
//                             ]),

//                         // List of numbers and points
//                         Row(children: [
//                           Expanded(
//                               child: Container(
//                             height: MediaQuery.of(context).size.height * 0.3,
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                                 color: whiteBackgroundColor,
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: Consumer(builder: (context, ref, child) {
//                               final refWatch =
//                                   ref.watch(closetriplePannaNotifierProvider);
//                               final refRead = ref
//                                   .read(closetriplePannaNotifierProvider.notifier);
//                               return ListView.builder(
//                                   itemCount: refWatch
//                                           .value?.SelectedNumberList.length ??
//                                       0,
//                                   itemBuilder: (context, index) {
//                                     return Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Container(
//                                                     padding:
//                                                         const EdgeInsets.fromLTRB(
//                                                             10, 5, 10, 5),
//                                                     decoration: BoxDecoration(
//                                                         border: Border.all(
//                                                             width: 1,
//                                                             color: Colors.grey),
//                                                         borderRadius:
//                                                             BorderRadius.circular(
//                                                                 10)),
//                                                     child: Text(
//                                                         refWatch.value?.SelectedNumberList[index].points
//                                                                 .toString() ??
//                                                             '',
//                                                         textAlign:
//                                                             TextAlign.center,
//                                                         style: const TextStyle(
//                                                             fontSize: 16,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black))),
//                                                 Container(
//                                                     padding:
//                                                         const EdgeInsets.fromLTRB(
//                                                             10, 5, 10, 5),
//                                                     decoration: BoxDecoration(
//                                                         border: Border.all(
//                                                             width: 1,
//                                                             color: Colors.grey),
//                                                         borderRadius:
//                                                             BorderRadius.circular(
//                                                                 10)),
//                                                     child: Text(
//                                                         refWatch.value?.SelectedNumberList[index].value
//                                                                 .toString() ??
//                                                             '',
//                                                         textAlign:
//                                                             TextAlign.center,
//                                                         style: const TextStyle(
//                                                             fontSize: 16,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: Colors.black))),
//                                                 InkWell(
//                                                     onTap: () {
//                                                       refRead
//                                                           .removePoints(index);
//                                                     },
//                                                     child: Container(
//                                                         padding:
//                                                             const EdgeInsets.fromLTRB(
//                                                                 10, 5, 10, 5),
//                                                         decoration: BoxDecoration(
//                                                             border: Border.all(
//                                                                 width: 1,
//                                                                 color: Colors
//                                                                     .grey),
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         10)),
//                                                         child: const Icon(
//                                                             Icons.delete,
//                                                             color: Colors.red)))
//                                               ]),
//                                           const SizedBox(height: 15),
//                                         ]);
//                                   });
//                             }),
//                           ))
//                         ]),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: const Color(0xffeeeeee),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Column(children: [
//                       Consumer(builder: (context, ref, child) {
//                         final refWatch = ref.watch(closetriplePannaNotifierProvider);
//                         return Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(children: [
//                                 Text('Numbers',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: buttonColor)),
//                                 SizedBox(height: 2),
//                                 Text(
//                                     refWatch.value?.totalSelectedNumber
//                                             .toString() ??
//                                         '',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: buttonColor))
//                               ]),
//                               Column(children: [
//                                 Text('Points',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: buttonColor)),
//                                 SizedBox(height: 2),
//                                 Text(
//                                     refWatch.value?.totalPoints.toString() ??
//                                         '',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: buttonColor))
//                               ]),
//                               Column(children: [
//                                 Text('Left Points',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: buttonColor)),
//                                 SizedBox(height: 2),
//                                 Text(
//                                     refWatch.value?.leftPoints.toString() ?? '',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: buttonColor))
//                               ]),
//                             ]);
//                       }),
//                     ]),
//                   ),
//                 ])),
//             const SizedBox(height: 15),
//             InkWell(
//               onTap: () {
//                 ref
//                     .read(closetriplePannaNotifierProvider.notifier)
//                     .onSubmitConfirm(context, tag ?? '', marketId ?? '');
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
//                     color: Colors.black,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//               ),
//             ),
//           ]),
//         )));
//   }

//   Widget chooseNumber(
//       BuildContext context, String? number, TriplePannaModel? onChangedValue) {
//     return Row(
//       children: [
//         Container(
//           height: MediaQuery.of(context).size.height * 0.07,
//           width: 50,
//           decoration: const BoxDecoration(
//             color: buttonColor,
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.only(top: 17.0),
//             child: Text(number.toString(),
//                 overflow: TextOverflow.ellipsis,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: whiteBackgroundColor)),
//           ),
//         ),
//         Container(
//             height: MediaQuery.of(context).size.height * 0.07,
//             decoration: const BoxDecoration(
//               color: whiteBackgroundColor,
//               borderRadius: BorderRadius.only(
//                   topRight: Radius.circular(10),
//                   bottomRight: Radius.circular(10)),
//             ),
//             width: MediaQuery.of(context).size.width * 0.3,
//             child: TextFormField(
//               textAlignVertical: TextAlignVertical.center,
//               textAlign: TextAlign.center,
//               controller: onChangedValue?.value,
//               cursorColor: darkBlue,
//               maxLines: 1,
//               style: const TextStyle(
//                   fontSize: 20, color: textColor, fontWeight: FontWeight.bold),
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                   contentPadding: const EdgeInsets.only(top: 11),
//                   isDense: true,
//                   hintStyle: Theme.of(context)
//                       .textTheme
//                       .titleMedium
//                       ?.copyWith(color: Colors.grey),
//                   border: InputBorder.none,
//                   focusedBorder: InputBorder.none,
//                   errorBorder: InputBorder.none,
//                   focusedErrorBorder: InputBorder.none),
//               onChanged: (value) {
//                 onChangedValue?.value?.text = value;
//                 onChangedValue?.points = number.toString();
//               },
//             ))
//       ],
//     );
//   }
// }
