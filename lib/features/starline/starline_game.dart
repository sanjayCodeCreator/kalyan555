// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
// import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
// import 'package:sm_project/features/games/double_panna/double_panna.dart';
// import 'package:sm_project/features/games/full_sangam/full_sangam.dart';
// import 'package:sm_project/features/games/half_sangam/half_sangam.dart';
// import 'package:sm_project/features/games/jodi_digit/jodi_digit.dart';
// import 'package:sm_project/features/games/kalyan_morning_notifier.dart';
// import 'package:sm_project/features/games/single_digit/single_digit.dart';
// import 'package:sm_project/features/games/single_panna/single_panna.dart';
// import 'package:sm_project/features/games/triple_panna/triple_panna.dart';
// import 'package:sm_project/features/home/home_router.dart';
// import 'package:sm_project/features/starline/starline_notifier.dart';
// import 'package:sm_project/utils/filecollection.dart';

// class StarLineGame extends HookConsumerWidget {
//   final String? tag;
//   final String? marketId;
//   final String? marketName;
//   final String? gameName;
//   final String? currentTime;
//   const StarLineGame(
//       {super.key,
//       this.tag,
//       this.marketId,
//       this.marketName,
//       this.gameName,
//       this.currentTime});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final refRead = ref.read(kalyanMorningNotifierProvider.notifier);
//     final refParticularWatch = ref.watch(getParticularPlayerNotifierProvider);

//     useEffect(() {
//       ref
//           .read(getParticularPlayerNotifierProvider.notifier)
//           .getParticularPlayerModel(context: context);
//       refRead.getPermission();
//       return;
//     }, []);

//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         ref.read(starlineNotifierProvider.notifier).changeStarlineStatus(false);
//         context.pushReplacement(HomePath.homeScreen);
//       },
//       child: Scaffold(
//         backgroundColor: backgroundColor,
//         body: SafeArea(
//             child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: Column(
//               children: [
//                 Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
//                     decoration: BoxDecoration(
//                       // color: const Color(0xFF8A25FE),
//                       gradient: const LinearGradient(
//                         colors: [
//                           Color(0xFF8A25FE),
//                           Color(0xFF4389FE),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(children: [
//                           InkWell(
//                             onTap: () {
//                               ref
//                                   .read(starlineNotifierProvider.notifier)
//                                   .changeStarlineStatus(false);
//                               context.pushReplacement(HomePath.homeScreen);
//                             },
//                             child: const Icon(Icons.arrow_back_ios,
//                                 size: 20, color: whiteBackgroundColor),
//                           ),
//                           const SizedBox(width: 10),
//                           Text(
//                             '$marketName',
//                             style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: whiteBackgroundColor),
//                           ),
//                         ]),
//                         Row(
//                           children: [
//                             Image.asset(clockLogo, width: 30),
//                             const SizedBox(width: 5),
//                             refParticularWatch.value?.getParticularPlayerModel
//                                         ?.currentTime !=
//                                     null
//                                 ? Text(
//                                     refParticularWatch
//                                             .value
//                                             ?.getParticularPlayerModel
//                                             ?.currentTime
//                                             .toString() ??
//                                         '',
//                                     style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                         color: whiteBackgroundColor))
//                                 : Text(currentTime ?? '',
//                                     style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                         color: whiteBackgroundColor)),
//                           ],
//                         ),
//                       ],
//                     )),
//                 const SizedBox(height: 15),
//                 Consumer(builder: (context, ref, child) {
//                   return gameGridView(
//                     context,
//                     ref,
//                   );
//                 })
//               ],
//             ),
//           ),
//         )),
//       ),
//     );
//   }

//   // Close Games Mode
//   Widget gameGridView(BuildContext context, WidgetRef ref) {
//     return GridView.builder(
//         itemCount: _gamelist(context, ref).length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             // childAspectRatio: 1.25,
//             crossAxisSpacing: 0.0,
//             mainAxisSpacing: 10.0),
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemBuilder: (BuildContext context, int index) {
//           return InkWell(
//             onTap: () {
//               _gamelist(context, ref)[index]['click']();
//             },
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: whiteBackgroundColor,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Stack(
//                     children: [
//                       Image.asset(
//                         _gamelist(context, ref)[index]['image'],
//                         width: MediaQuery.of(context).size.width * 0.6,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//   }

//   // game list with image and text
//   List _gamelist(BuildContext context, WidgetRef ref) => [
//         {
//           'image': singleDigitLogo,
//           // 'text': 'Single Digit',
//           'number': '0,1,2,3,...',
//           'click': () {
//             Navigator.of(context).push(MaterialPageRoute(
//                 builder: (context) => SingleDigit(
//                       tag: tag ?? '',
//                       marketId: marketId ?? '',
//                       marketName: marketName ?? '',
//                     )));
//           }
//         },
//         {
//           'image': jodiDigitLogo,
//           // 'text': 'Jodi Digit',
//           'number': '00,12,15,55,98,...',
//           'click': () {
//             final refReadHome = ref.read(homeNotifierProvider.notifier);
//             final refWatchHome = ref.watch(homeNotifierProvider);
//             final myMarketData = refWatchHome.value?.getAllMarketModel?.data
//                 ?.where((element) => element.sId == marketId)
//                 .toList()
//                 .first;
//             if (refReadHome.isTimePassed(myMarketData?.openTime ?? '')) {
//               toast('Game is only available before open time.');
//               return;
//             }
//             Navigator.of(context).push(MaterialPageRoute(
//                 builder: (context) => JodiDigit(
//                       tag: tag ?? '',
//                       marketId: marketId ?? '',
//                       marketName: marketName ?? '',
//                     )));
//           }
//         },
//         {
//           'image': kalyanSinglePanelLogo,
//           // 'text': 'Single Panna',
//           'number': '123,478,150,...',
//           'click': () {
//             Navigator.of(context).push(MaterialPageRoute(
//                 builder: (context) => SinglePanna(
//                       tag: tag ?? '',
//                       marketId: marketId ?? '',
//                       marketName: marketName ?? '',
//                     )));
//           }
//         },
//         {
//           'image': kalyanDoublePanelLogo,
//           // 'text': 'Double Panna',
//           'number': '112,223,445,556,....',
//           'click': () {
//             Navigator.of(context).push(MaterialPageRoute(
//                 builder: (context) => DoublePanna(
//                       tag: tag ?? '',
//                       marketId: marketId ?? '',
//                       marketName: marketName ?? '',
//                     )));
//           }
//         },
//         {
//           'image': kalyanTriplePanelLogo,
//           // 'text': 'Triple Panna',
//           'number': '000,111,555,....',
//           'click': () {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => TriplePanna(
//                   tag: tag ?? '',
//                   marketId: marketId ?? '',
//                   marketName: marketName ?? '',
//                 ),
//               ),
//             );
//           }
//         },
//         {
//           'image': sangamLogo,
//           // 'text': 'Half Sangam',
//           'number': '000,111,555,...',
//           'click': () {
//             final refReadHome = ref.read(homeNotifierProvider.notifier);
//             final refWatchHome = ref.watch(homeNotifierProvider);
//             final myMarketData = refWatchHome.value?.getAllMarketModel?.data
//                 ?.where((element) => element.sId == marketId)
//                 .toList()
//                 .first;
//             if (refReadHome.isTimePassed(myMarketData?.openTime ?? '')) {
//               toast('Game is only available before open time.');
//               return;
//             }
//             Navigator.of(context).push(MaterialPageRoute(
//                 builder: (context) => HalfSangam(
//                       tag: tag ?? '',
//                       marketId: marketId ?? '',
//                       marketName: marketName ?? '',
//                     )));
//           }
//         },
//         {
//           'image': fullsangamLogo,
//           // 'text': 'Full Sangam',
//           'number': '128,137,146,...',
//           'click': () {
//             final refReadHome = ref.read(homeNotifierProvider.notifier);
//             final refWatchHome = ref.watch(homeNotifierProvider);
//             final myMarketData = refWatchHome.value?.getAllMarketModel?.data
//                 ?.where((element) => element.sId == marketId)
//                 .toList()
//                 .first;
//             if (refReadHome.isTimePassed(myMarketData?.openTime ?? '')) {
//               toast('Game is only available before open time.');
//               return;
//             }

//             Navigator.of(context).push(MaterialPageRoute(
//                 builder: (context) => FullSangam(
//                       tag: tag ?? '',
//                       marketId: marketId ?? '',
//                       marketName: marketName ?? '',
//                     )));
//           }
//         },
//       ];
// }
