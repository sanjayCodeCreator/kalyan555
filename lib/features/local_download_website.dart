// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// import 'package:sm_project/features/local_download_notifier.dart';
// import 'package:sm_project/utils/colors.dart';

// class LocalDownloadWebsite extends ConsumerStatefulWidget {
//   final String appVersion;
//   final String appLink;

//   const LocalDownloadWebsite({
//     super.key,
//     required this.appVersion,
//     required this.appLink,
//   });

//   @override
//   ConsumerState<LocalDownloadWebsite> createState() =>
//       _LocalDownloadWebsiteState();
// }

// class _LocalDownloadWebsiteState extends ConsumerState<LocalDownloadWebsite>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _fadeController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize animations
//     _pulseController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _pulseAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.1,
//     ).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.easeInOut,
//     ));

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeIn,
//     ));

//     _fadeController.forward();
//     _pulseController.repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _fadeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final downloadState = ref.watch(localDownloadNotifierProvider);
//     final downloadNotifier = ref.read(localDownloadNotifierProvider.notifier);

//     log(widget.appLink, name: 'App Link');

//     return Scaffold(
//         backgroundColor: darkBlue,
//         appBar: AppBar(
//           backgroundColor: darkBlue,
//           elevation: 0,
//           leading: const SizedBox(),
//           title: const Text(
//             'App Update',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//           centerTitle: true,
//         ),
//         body: Stack(
//           children: [
//             // Gradient background
//             Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Color(0xFF141E60),
//                     Color(0xFF0D47A1),
//                     Color(0xFF013A63),
//                   ],
//                 ),
//               ),
//             ),
//             // Decorative circles
//             Positioned(
//               top: -60,
//               right: -40,
//               child: AnimatedBuilder(
//                 animation: _pulseAnimation,
//                 builder: (context, _) {
//                   return Transform.scale(
//                     scale: _pulseAnimation.value,
//                     child: Container(
//                       width: 180,
//                       height: 180,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white.withOpacity(0.06),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Positioned(
//               bottom: -80,
//               left: -60,
//               child: Container(
//                 width: 220,
//                 height: 220,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white.withOpacity(0.04),
//                 ),
//               ),
//             ),
//             SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(24.0, 10, 24.0, 20.0),
//                 child: Column(
//                   children: [
//                     // App Icon + Title Section
//                     Expanded(
//                       flex: 3,
//                       child: FadeTransition(
//                         opacity: _fadeAnimation,
//                         child: Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               // Icon in a glass card
//                               Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.08),
//                                   borderRadius: BorderRadius.circular(24),
//                                   border: Border.all(
//                                     color: Colors.white.withOpacity(0.15),
//                                     width: 1,
//                                   ),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.25),
//                                       blurRadius: 24,
//                                       offset: const Offset(0, 8),
//                                     ),
//                                   ],
//                                 ),
//                                 child: AnimatedBuilder(
//                                   animation: _pulseAnimation,
//                                   builder: (context, child) {
//                                     return Transform.scale(
//                                       scale: _pulseAnimation.value,
//                                       child: ClipRRect(
//                                         borderRadius: BorderRadius.circular(20),
//                                         child: Image.asset(
//                                           'assets/images/app_icon.png',
//                                           fit: BoxFit.cover,
//                                           width: MediaQuery.of(context)
//                                                   .size
//                                                   .width *
//                                               0.22,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(height: 12),
//                               const Text(
//                                 'A Better Version Awaits',
//                                 style: TextStyle(
//                                   fontSize: 26,
//                                   fontWeight: FontWeight.w800,
//                                   letterSpacing: 0.3,
//                                   color: Colors.white,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                               const SizedBox(height: 10),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 14,
//                                   vertical: 8,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.12),
//                                   borderRadius: BorderRadius.circular(40),
//                                   border: Border.all(
//                                     color: Colors.white.withOpacity(0.2),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     const Icon(
//                                       Icons.system_update_alt_rounded,
//                                       color: Colors.white,
//                                       size: 18,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       'Version ${widget.appVersion}${Platform.isAndroid ? ' · APK' : ''}',
//                                       style: const TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),

//                     // Info + Progress Section
//                     Expanded(
//                       flex: 4,
//                       child: Container(
//                         padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.08),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.18),
//                             width: 1,
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'What\'s new',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w700,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             const Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Icon(Icons.check_circle,
//                                     size: 16, color: Colors.lightGreenAccent),
//                                 SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     'Smoother performance and faster load times',
//                                     style: TextStyle(
//                                         color: Colors.white70, height: 1.35),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 6),
//                             const Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Icon(Icons.check_circle,
//                                     size: 16, color: Colors.lightGreenAccent),
//                                 SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     'Fresh UI with improved readability',
//                                     style: TextStyle(
//                                         color: Colors.white70, height: 1.35),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 6),
//                             const Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Icon(Icons.check_circle,
//                                     size: 16, color: Colors.lightGreenAccent),
//                                 SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     'Bug fixes and under-the-hood stability updates',
//                                     style: TextStyle(
//                                         color: Colors.white70, height: 1.35),
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: 16),
//                             const Divider(color: Colors.white24, height: 1),
//                             const SizedBox(height: 16),

//                             // Download Progress
//                             if (downloadState.isDownloading ||
//                                 downloadState.isInstalling)
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       const Icon(Icons.downloading,
//                                           color: Colors.white70, size: 18),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: Text(
//                                           downloadState.downloadStatus,
//                                           style: const TextStyle(
//                                               color: Colors.white70,
//                                               fontSize: 13),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.circular(12),
//                                     child: LinearProgressIndicator(
//                                       value: downloadState.downloadProgress,
//                                       backgroundColor:
//                                           Colors.white.withOpacity(0.18),
//                                       valueColor:
//                                           const AlwaysStoppedAnimation<Color>(
//                                               Colors.lightGreenAccent),
//                                       minHeight: 10,
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             else
//                               const Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Tap Download & Install to get the latest version.',
//                                     style: TextStyle(
//                                         color: Colors.white70, fontSize: 13),
//                                   ),
//                                   SizedBox(height: 6),
//                                   Text(
//                                     'You may need to allow installation from unknown sources.',
//                                     style: TextStyle(
//                                         color: Colors.white38, fontSize: 12),
//                                   ),
//                                 ],
//                               ),

//                             // Error Message
//                             if (downloadState.errorMessage != null) ...[
//                               const SizedBox(height: 14),
//                               Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red.withOpacity(0.15),
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                       color: Colors.red.withOpacity(0.35)),
//                                 ),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Icon(Icons.error_outline,
//                                         color: Colors.redAccent, size: 18),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Text(
//                                         downloadState.errorMessage!,
//                                         style: const TextStyle(
//                                             color: Colors.redAccent,
//                                             fontSize: 13),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               if (downloadState.errorMessage!
//                                   .contains('permission'))
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 8),
//                                   child: ElevatedButton.icon(
//                                     onPressed: () {
//                                       // Open app settings manually
//                                     },
//                                     icon: const Icon(Icons.settings,
//                                         color: Colors.white),
//                                     label: const Text('Open Settings',
//                                         style: TextStyle(color: Colors.white)),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.orange,
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(10)),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ],
//                         ),
//                       ),
//                     ),

//                     // Action Buttons
//                     const SizedBox(height: 28),
//                     Row(
//                       children: [
//                         // Download Button
//                         Expanded(
//                           child: Container(
//                             height: 56,
//                             decoration: BoxDecoration(
//                               gradient: const LinearGradient(
//                                 colors: [Color(0xFF00C853), Color(0xFF64DD17)],
//                               ),
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.greenAccent.withOpacity(0.35),
//                                   blurRadius: 14,
//                                   offset: const Offset(0, 6),
//                                 ),
//                               ],
//                             ),
//                             child: Material(
//                               color: Colors.transparent,
//                               child: InkWell(
//                                 borderRadius: BorderRadius.circular(16),
//                                 onTap: downloadState.isDownloading ||
//                                         downloadState.isInstalling
//                                     ? null
//                                     : () {
//                                         downloadNotifier.downloadApp(
//                                             widget.appLink, widget.appVersion);
//                                       },
//                                 child: Center(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       if (downloadState.isDownloading ||
//                                           downloadState.isInstalling)
//                                         const SizedBox(
//                                           width: 20,
//                                           height: 20,
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                             valueColor:
//                                                 AlwaysStoppedAnimation<Color>(
//                                                     Colors.white),
//                                           ),
//                                         )
//                                       else
//                                         const Icon(Icons.download_rounded,
//                                             color: Colors.white, size: 24),
//                                       const SizedBox(width: 12),
//                                       Text(
//                                         downloadState.isDownloading ||
//                                                 downloadState.isInstalling
//                                             ? 'Downloading...'
//                                             : 'Download & Install',
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(width: 16),

//                         // External Download Button
//                         Container(
//                           height: 56,
//                           width: 56,
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(
//                               color: Colors.white.withOpacity(0.3),
//                               width: 1,
//                             ),
//                           ),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(16),
//                               onTap: () {
//                                 downloadNotifier.openAppLink(widget.appLink);
//                               },
//                               child: const Icon(
//                                 Icons.open_in_new,
//                                 color: Colors.white,
//                                 size: 24,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ));
//   }
// }
