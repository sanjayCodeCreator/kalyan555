import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sm_project/controller/local/pref.dart';
import 'package:sm_project/controller/local/pref_names.dart';
import 'package:sm_project/router/routes_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Duration initialDelay = const Duration(seconds: 3);
  bool isUserLogin = Prefs.getBool(PrefNames.isLogin) ?? false;

  @override
  void initState() {
    super.initState();
    Future.delayed(initialDelay).then((value) {
      if (context.mounted) {
        if (isUserLogin) {
          if (mounted) {
            context.go(RouteNames.mainScreen);
          }
        } else {
          if (mounted) {
            context.go(RouteNames.registerScreen);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
        .copyWith(statusBarIconBrightness: Brightness.dark));

    return Image.asset('assets/images/appsplash.png',
        fit: BoxFit.cover, height: double.infinity, width: double.infinity);
  }
}
