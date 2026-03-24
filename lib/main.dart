// story set color for image - 92E3A9

import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sm_project/firebase_options.dart';
import 'package:sm_project/router/app_route.dart';
import 'package:sm_project/screen/push_notification.dart/firebase_messaging.dart';
import 'package:sm_project/utils/app_utils.dart';
import 'package:sm_project/utils/customization.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:sm_project/utils/theme.dart';

import 'Quiz/utils/prefs_service.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  log(message.data.toString(), name: 'main.dart');
  log(message.notification!.title.toString(), name: 'main.dart notifi');
}

// Global variable to store the dominant color from app icon
Color extractedDominantColor = const Color(0xFF172430); // Default fallback

// Global navigator key for navigation from anywhere in the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(name:"Kalyan555 app",options: DefaultFirebaseOptions.currentPlatform);
  await PrefsService.init();

  // Extract dominant color from app icon
  try {
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      const AssetImage('assets/images/app_icon.png'),
      size: const Size(200, 200),
      maximumColorCount: 16,
    );
    extractedDominantColor =
        paletteGenerator.dominantColor?.color ?? const Color(0xFF172430);
    log('Extracted dominant color: ${extractedDominantColor.value.toRadixString(16)}',
        name: 'main.dart');
  } catch (e) {
    log('Failed to extract dominant color: $e', name: 'main.dart');
  }

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: appColor,
    statusBarIconBrightness: Brightness.light,
  ));
  await Prefs.init();
  if (Platform.isAndroid) {
    await AppUtils.handleCameraAndMic(Permission.notification);
    await AppUtils.handleCameraAndMic(Permission.audio);
    await AppUtils.handleCameraAndMic(Permission.mediaLibrary);
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    FirebaseMessagingService().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '${Customization.appname}',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: appRoute,
      builder: EasyLoading.init(),
    );
  }
}
