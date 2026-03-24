import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sm_project/controller/local/pref.dart';
import 'package:sm_project/controller/local/pref_names.dart';
import 'package:sm_project/screen/push_notification.dart/push_notification_api.dart';

// Provider for the Firebase Messaging Service
final firebaseMessagingServiceProvider =
    Provider<FirebaseMessagingService>((ref) {
  return FirebaseMessagingService();
});

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Channel ID for Android notifications
  static const String _androidChannelId = 'com.flashmatka.app.notifications';
  static const String _androidChannelName = 'FlashMatka Notifications';
  static const String _androidChannelDescription =
      'Notifications from FlashMatka app';

  // Initialize the messaging service
  Future<void> initialize() async {
    try {
      if (kIsWeb || kIsWasm) {
        return;
      }
      // Check for Google Play Services on Android
      if (Platform.isAndroid) {
        final bool playServicesAvailable =
            await _checkPlayServicesAvailability();
        if (!playServicesAvailable) {
          log('Google Play Services not available. Push notifications will not work.');
          return; // Skip FCM initialization if Play Services are not available
        }

        // Request notification permission for Android 13+ (API level 33+)
        try {
          // Check Android version using _flutterLocalNotificationsPlugin
          final AndroidFlutterLocalNotificationsPlugin?
              androidNotificationsPlugin = _flutterLocalNotificationsPlugin
                  .resolvePlatformSpecificImplementation<
                      AndroidFlutterLocalNotificationsPlugin>();

          if (androidNotificationsPlugin != null) {
            final bool? permissionGranted = await androidNotificationsPlugin
                .requestNotificationsPermission();
            log('Android notification permission ${permissionGranted == true ? 'granted' : 'denied'}');
          }
        } catch (e) {
          log('Error requesting Android notification permission: $e');
        }
      }

      // Request permission for iOS
      if (Platform.isIOS || Platform.isMacOS) {
        await _requestIOSPermission();
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Configure FCM handlers
      _configureFCM();

      // Get the FCM token with retry mechanism
      await _getAndHandleFCMToken();

      // Listen for token refreshes with error handling
      _firebaseMessaging.onTokenRefresh.listen(
        (newToken) async {
          await storeToken(newToken);
          log('FCM Token refreshed: $newToken');

        },
        onError: (error) {
          log('FCM token refresh error: $error');
          // Continue app execution despite token refresh errors
        },
      );
    } catch (e) {
      // Log the error but don't crash the app
      log('Error initializing Firebase Messaging: $e');
      // The app can continue without push notification capability
    }
  }

  // Check if Google Play Services are available on Android
  Future<bool> _checkPlayServicesAvailability() async {
    try {
      // Simple check - if we can get a token without errors, Play Services are likely available
      // We use a short timeout to avoid hanging
      bool tokenRetrieved = false;

      final timeoutFuture = Future.delayed(const Duration(seconds: 2), () {
        if (!tokenRetrieved) {
          throw TimeoutException('Play Services check timed out');
        }
        return false;
      });

      final checkFuture = _firebaseMessaging.getToken().then((token) {
        tokenRetrieved = true;
        return token != null;
      }).catchError((e) {
        log('Error checking Play Services: $e');
        return false;
      });

      final result = await Future.any([checkFuture, timeoutFuture]);
      return result ? result : false;
    } catch (e) {
      log('Error checking Play Services availability: $e');
      return false;
    }
  }

  // Get FCM token with retry mechanism
  Future<void> _getAndHandleFCMToken() async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelaySeconds = 2; // Reduced from 5 to 2 seconds
    const tokenTimeoutSeconds = 3; // Timeout for token retrieval

    while (retryCount < maxRetries) {
      try {
        // Create a timeout for token retrieval
        String? token;
        bool tokenRetrieved = false;

        // Create a timeout future
        final timeoutFuture =
            Future.delayed(const Duration(seconds: tokenTimeoutSeconds), () {
          if (!tokenRetrieved) {
            log('FCM token retrieval timed out after $tokenTimeoutSeconds seconds');
            throw TimeoutException('FCM token retrieval timed out');
          }
          return null;
        });

        // Create the token retrieval future
        final tokenFuture = _firebaseMessaging.getToken().then((value) {
          tokenRetrieved = true;
          token = value;
          return value;
        });

        // Wait for either the token retrieval to complete or the timeout to occur
        await Future.any([tokenFuture, timeoutFuture]);

        if (token != null && token!.isNotEmpty) {
          log('FCM Token: $token');

          try {
            await storeToken(token);

            log('FCM token saved to API');
          } catch (e) {
            log('Error saving FCM token to API: $e');
          }

          return;
        }
        log('Empty FCM token received, retrying...');
      } catch (e) {
        log('Error getting FCM token (attempt ${retryCount + 1}/$maxRetries): $e');
        if (e.toString().contains('SERVICE_NOT_AVAILABLE')) {
          log('FCM service not available. This could be due to network issues or missing Google Play Services.');
        } else if (e is TimeoutException) {
          log('FCM token retrieval timed out. Continuing without token.');
          // If we timeout, we should just continue without a token
          return;
        }
      }

      retryCount++;
      if (retryCount < maxRetries) {
        // Wait before retrying
        await Future.delayed(const Duration(seconds: retryDelaySeconds));
      }
    }

    log('Failed to get FCM token after $maxRetries attempts. Push notifications may not work.');
  }

  // Request permission for iOS devices
  Future<void> _requestIOSPermission() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      log('User granted permission: ${settings.authorizationStatus}');
    } catch (e) {
      log('Error requesting iOS notification permissions: $e');
    }
  }

  // Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    try {
      // Android initialization - use correct icon
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      // Initialize settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap
          if (response.payload != null) {
            try {
              final dynamic data = json.decode(response.payload!);
              log('Notification tapped with data: $data');
            } catch (e) {
              log('Error parsing notification payload: $e');
            }
          }
        },
      );

      // Create notification channel for Android
      if (Platform.isAndroid) {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(
              const AndroidNotificationChannel(
                _androidChannelId,
                _androidChannelName,
                description: _androidChannelDescription,
                importance: Importance.high,
                playSound: true,
                enableVibration: true,
                enableLights: true,
              ),
            );
      }
    } catch (e) {
      log('Error initializing local notifications: $e');
    }
  }

  // Configure Firebase Cloud Messaging
  void _configureFCM() {
    // Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        log('Got a message whilst in the foreground!');
        log('Message data: ${message.data}');

        if (message.notification != null) {
          log('Message also contained a notification: ${message.notification}');
          _showLocalNotification(message);
        }
      },
      onError: (error) {
        log('Error in FCM onMessage stream: $error');
      },
    );

    // Handle when the app is opened from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage? message) {
        if (message != null) {
          log('App opened from terminated state with message: ${message.data}');
        }
      },
      onError: (error) {
        log('Error getting initial message: $error');
      },
    );

    // Handle when the app is opened from the background
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        log('App opened from background state with message: ${message.data}');
      },
      onError: (error) {
        log('Error in FCM onMessageOpenedApp stream: $error');
      },
    );
  }

  // Show a local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final RemoteNotification? notification = message.notification;
      final AndroidNotification? android = message.notification?.android;

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      print("_showLocalNotification --->");
      if (notification != null && !kIsWeb) {
        await _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannelId,
              _androidChannelName,
              channelDescription: _androidChannelDescription,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              largeIcon:
                  const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              priority: Priority.high,
              importance: Importance.high,
              playSound: true,
              enableVibration: true,
              visibility: NotificationVisibility.public,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: json.encode(message.data),
        );
      }
    } catch (e) {
      log('Error showing local notification: $e');
    }
  }

  // Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic $topic: $e');
    }
  }

  // Get the current FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }
}

Future<void> storeToken(String? deviceToken) async {
  if (deviceToken == null || deviceToken.isEmpty) return;

  log(deviceToken, name: "Device Token");

  // ✅ STEP 1: Always save to local memory immediately
  // This ensures your login body won't be {fcm: -} anymore
  await Prefs.setString(PrefNames.fcmToken, deviceToken);

  // ✅ STEP 2: Only call the API if we are already logged in
  final token = Prefs.getString(PrefNames.accessToken);
  if (token != null && token.isNotEmpty) {
    PushNotificationApi.updateFCMToken(deviceToken);
  }
}
