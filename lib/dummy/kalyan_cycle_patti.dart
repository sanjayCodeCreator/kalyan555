// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sm_project/controller/riverpod/kalyan_open_bulk_notifier.dart';
// import 'package:sm_project/utils/all_images.dart';
// import 'package:sm_project/utils/colors.dart';
// import 'package:sm_project/reusubility_widget/textformfield_widget.dart';

// class KalyanCyclePatti extends StatelessWidget {
//   const KalyanCyclePatti({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: backgroundColor,
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
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     Text(
//                       'KALYAN - Open - Cycle Patti',
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
//                       color: whiteBackgroundColor,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Text('Select First Number:',
//                         overflow: TextOverflow.ellipsis,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: textColor)),
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
//                         Consumer(builder: (context, ref, child) {
//                           final refWatch =
//                               ref.watch(kalyanOpenBulkJodiNotifierProvider);
//                           return Text(
//                               refWatch.value?.formattedDate.toString() ?? '',
//                               style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                   color: textColor));
//                         })
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 15),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   for (int i = 1; i <= 10; i++)
//                     SizedBox(
//                       height: 36,
//                       child: Container(
//                         margin: const EdgeInsets.only(right: 7),
//                         height: MediaQuery.of(context).size.height * 0.05,
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: whiteBackgroundColor,
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                         child: Text(i.toString(),
//                             textAlign: TextAlign.center,
//                             style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: textColor)),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 15),
//             Container(
//               height: MediaQuery.of(context).size.height * 0.05,
//               width: MediaQuery.of(context).size.width * 0.52,
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: whiteBackgroundColor,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Text('Select Second Number:',
//                   overflow: TextOverflow.ellipsis,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: textColor)),
//             ),
//             const SizedBox(height: 15),
//             SizedBox(
//               height: 36,
//               child: ListView.builder(
//                   itemCount: 10,
//                   shrinkWrap: true,
//                   scrollDirection: Axis.horizontal,
//                   itemBuilder: (context, index) {
//                     // if (index == 0) {
//                     //   index = 0 + 1;
//                     // }
//                     return Container(
//                       margin: const EdgeInsets.only(right: 7),
//                       height: MediaQuery.of(context).size.height * 0.05,
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: whiteBackgroundColor,
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                       child: Text(index.toString(),
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: textColor)),
//                     );
//                   }),
//             ),
//             const SizedBox(height: 15),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   height: MediaQuery.of(context).size.height * 0.05,
//                   width: MediaQuery.of(context).size.width * 0.4,
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: whiteBackgroundColor,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Row(
//                     children: [
//                       Text('Selected Cycle: ',
//                           overflow: TextOverflow.ellipsis,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: textColor)),
//                       Text('11',
//                           overflow: TextOverflow.ellipsis,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: redColor)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 15),
//             Container(
//                 padding: const EdgeInsets.fromLTRB(20, 2, 6, 12),
//                 decoration: BoxDecoration(
//                   color: whiteBackgroundColor,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Row(children: [
//                   const Padding(
//                     padding: EdgeInsets.only(top: 10.0),
//                     child: Text('Enter Points:',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.black)),
//                   ),
//                   const SizedBox(width: 25),
//                   SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.3,
//                       child: const CustomTextFormField(

//                           // controller: refWatch.value?.emailController,

//                           ))
//                 ])),
//             const SizedBox(height: 15),
//             Container(
//                 padding: const EdgeInsets.all(6),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: whiteBackgroundColor,
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: const Text('ADD',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 20,
//                         fontWeight: FontWeight.w900))),
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
//                               Container(
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
//                                           color: Colors.red)))
//                             ]),
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
//                     child: const Column(children: [
//                       Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(children: [
//                               Text('Numbers',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: buttonColor)),
//                               SizedBox(height: 2),
//                               Text('0',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: buttonColor))
//                             ]),
//                             Column(children: [
//                               Text('Points',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: buttonColor)),
//                               SizedBox(height: 2),
//                               Text('0',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: buttonColor))
//                             ]),
//                             Column(children: [
//                               Text('Left Points',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: buttonColor)),
//                               SizedBox(height: 2),
//                               Text('0',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: buttonColor))
//                             ]),
//                           ]),
//                     ]),
//                   ),
//                 ])),
//             const SizedBox(height: 15),
//             Container(
//               padding: const EdgeInsets.all(6),
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: whiteBackgroundColor,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: const Text(
//                 'Confirm',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//             ),
//           ]),
//         )));
//   }
// }
