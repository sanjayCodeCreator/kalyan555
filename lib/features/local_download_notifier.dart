// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:developer';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:install_plugin/install_plugin.dart';

// final localDownloadNotifierProvider =
//     StateNotifierProvider<LocalDownloadNotifier, LocalDownloadState>((ref) {
//   return LocalDownloadNotifier();
// });

// class LocalDownloadState {
//   final bool isDownloading;
//   final double downloadProgress;
//   final String downloadStatus;
//   final String? downloadPath;
//   final String? errorMessage;
//   final bool isInstalling;

//   LocalDownloadState({
//     this.isDownloading = false,
//     this.downloadProgress = 0.0,
//     this.downloadStatus = '',
//     this.downloadPath,
//     this.errorMessage,
//     this.isInstalling = false,
//   });

//   LocalDownloadState copyWith({
//     bool? isDownloading,
//     double? downloadProgress,
//     String? downloadStatus,
//     String? downloadPath,
//     String? errorMessage,
//     bool? isInstalling,
//   }) {
//     return LocalDownloadState(
//       isDownloading: isDownloading ?? this.isDownloading,
//       downloadProgress: downloadProgress ?? this.downloadProgress,
//       downloadStatus: downloadStatus ?? this.downloadStatus,
//       downloadPath: downloadPath ?? this.downloadPath,
//       errorMessage: errorMessage ?? this.errorMessage,
//       isInstalling: isInstalling ?? this.isInstalling,
//     );
//   }
// }

// class LocalDownloadNotifier extends StateNotifier<LocalDownloadState> {
//   LocalDownloadNotifier() : super(LocalDownloadState());

//   final Dio _dio = Dio();

//   Future<void> downloadApp(String appLink, String appVersion) async {
//     log(appLink, name: 'Download');
//     try {
//       state = state.copyWith(
//         isDownloading: true,
//         downloadProgress: 0.0,
//         downloadStatus: 'Starting download...',
//         errorMessage: null,
//       );

//       // Request storage permission
//       var status = await Permission.storage.request();
//       if (!status.isGranted) {
//         // For Android 11+, try manage external storage
//         if (Platform.isAndroid) {
//           status = await Permission.manageExternalStorage.request();
//         }
//         if (!status.isGranted) {
//           state = state.copyWith(
//             isDownloading: false,
//             errorMessage: 'Storage permission is required to download the app',
//           );
//           return;
//         }
//       }

//       // Get download directory
//       Directory? downloadDir;
//       if (Platform.isAndroid) {
//         downloadDir = Directory('/storage/emulated/0/Download');
//         if (!await downloadDir.exists()) {
//           downloadDir = await getExternalStorageDirectory();
//         }
//       } else {
//         downloadDir = await getApplicationDocumentsDirectory();
//       }

//       if (downloadDir == null) {
//         state = state.copyWith(
//           isDownloading: false,
//           errorMessage: 'Could not access download directory',
//         );
//         return;
//       }

//       // Create filename
//       String fileName = 'app_update_$appVersion.apk';
//       String filePath = '${downloadDir.path}/$fileName';

//       state = state.copyWith(downloadStatus: 'Downloading app...');

//       // Download file with progress
//       await _dio.download(
//         appLink,
//         filePath,
//         onReceiveProgress: (received, total) {
//           if (total != -1) {
//             double progress = received / total;
//             state = state.copyWith(
//               downloadProgress: progress,
//               downloadStatus:
//                   'Downloading... ${(progress * 100).toStringAsFixed(1)}%',
//             );
//           }
//         },
//         options: Options(
//           responseType: ResponseType.bytes,
//           followRedirects: true,
//           validateStatus: (status) {
//             return status! < 500;
//           },
//         ),
//       );

//       state = state.copyWith(
//         isDownloading: false,
//         downloadProgress: 1.0,
//         downloadStatus: 'Download completed!',
//         downloadPath: filePath,
//       );

//       log('App downloaded successfully to: $filePath', name: 'Download');

//       // Auto install on Android
//       if (Platform.isAndroid) {
//         await _installApp(filePath);
//       }
//     } catch (e) {
//       log('Download error: $e', name: 'Download');

//       state = state.copyWith(
//         isDownloading: false,
//         errorMessage: 'Download failed',
//         //   errorMessage: 'Download failed: ${e.toString()}',
//       );
//     }
//   }

//   Future<void> _installApp(String filePath) async {
//     try {
//       state = state.copyWith(
//         isInstalling: true,
//         downloadStatus: 'Installing app...',
//       );

//       File file = File(filePath);
//       if (!await file.exists()) {
//         state = state.copyWith(
//           isInstalling: false,
//           errorMessage: 'Downloaded file not found',
//         );
//         return;
//       }

//       // Check install permission status
//       var status = await Permission.requestInstallPackages.status;
//       if (status.isDenied) {
//         status = await Permission.requestInstallPackages.request();
//       }
//       if (status.isPermanentlyDenied) {
//         state = state.copyWith(
//           isInstalling: false,
//           errorMessage:
//               'Install permission is permanently denied. Please enable it in Settings > Apps > DhaanRaj > Install unknown apps.',
//         );
//         return;
//       }
//       if (!status.isGranted) {
//         state = state.copyWith(
//           isInstalling: false,
//           errorMessage:
//               'Install permission is required. Please grant the permission when prompted.',
//         );
//         return;
//       }

//       // Use install_plugin for APK installation (correct API for v2.1.0)
//       await InstallPlugin.install(filePath);

//       state = state.copyWith(
//         isInstalling: false,
//         downloadStatus: 'Installation started!',
//       );

//       // Close the app after starting installation (Android only)
//       if (Platform.isAndroid) {
//         Future.delayed(const Duration(seconds: 2), () {
//           SystemNavigator.pop();
//         });
//       }
//     } catch (e) {
//       log('Installation error: $e', name: 'Install');
//       state = state.copyWith(
//         isInstalling: false,
//         errorMessage: 'Installation failed:  [31m${e.toString()} [0m',
//       );
//     }
//   }

//   Future<void> openAppLink(String appLink) async {
//     try {
//       Uri uri = Uri.parse(appLink);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//       } else {
//         state = state.copyWith(
//           errorMessage: 'Could not open app link',
//         );
//       }
//     } catch (e) {
//       log('Error opening app link: $e', name: 'App Link');

//       state = state.copyWith(
//         errorMessage: 'Failed to open app link',
//         // errorMessage: 'Failed to open app link: ${e.toString()}',
//       );
//     }
//   }

//   void resetState() {
//     state = LocalDownloadState();
//   }

//   void showError(String message) {
//     EasyLoading.showError(message);
//   }

//   void showSuccess(String message) {
//     EasyLoading.showSuccess(message);
//   }
// }
