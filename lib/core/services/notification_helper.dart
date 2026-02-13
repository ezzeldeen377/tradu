import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:crypto_app/core/di/di.dart';
import 'package:crypto_app/core/routes/app_routes.dart';
import 'package:crypto_app/core/routes/app_router.dart';
import 'package:crypto_app/features/admin/data/repositories/chat_repository.dart';
import 'package:crypto_app/features/admin/presentation/cubits/chats_cubit/chats_cubit.dart';
import 'package:crypto_app/features/auth/presentation/cubit/auth_cubit.dart';

// This must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need to do any initialization here
  // await Firebase.initializeApp();

  // Print the message for debugging
  debugPrint('Handling a background message: ${message.messageId}');
  // The system will automatically show the notification from FCM
}

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static Future<void> init() async {
    // Register background handler first
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Set foreground notification presentation options
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true, // Allow system alert in foreground
          badge: true, // Update the app badge
          sound: true, // Allow sound
        );

    // Initialize local notifications
    await _initLocalNotifications();

    // Initialize FCM handlers
    await _initFCM();
  }

  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('notification');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        final payload = details.payload;
        if (payload != null) {
          final data = json.decode(payload);
          handleNotificationTap(data);
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  static Future<void> _initFCM() async {
    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) async {
      debugPrint('FCM Token Refreshed: $token');
      final context = AppRouter.navigatorKey.currentState?.context;
      if (context != null) {
        context.read<AuthCubit>().updateFCMToken(token);
      }
    });

    // Handle FCM messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Show a custom notification when in foreground
      if (message.notification != null) {
        log(message.data.toString());
        handleNewMessage(message.data);
        _showNotification(
          title: message.notification?.title ?? 'New Message',
          body: message.notification?.body ?? '',
          payload: json.encode(message.data),
        );
      }
    });

    // Handle FCM messages when app is in background and user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(message.data);
    });
  }

  static Future<void> _showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/notification',
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Generate a more unique notification ID
    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
      100000,
    );

    await _localNotifications.show(
      notificationId,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Function(int)? navigateToIndex;

  static void handleNotificationTap(Map<String, dynamic> data) async {
    debugPrint('Notification tapped with data: $data');

    // Navigate to specific tab if needed
    if (data['index'] != null) {
      final index = int.tryParse(data['index'].toString());
      if (index != null) {
        AppRouter.router.go('${AppRoutes.dashboard}?index=$index');
        return;
      }
    }

    if (data['action'] == 'new_message' && data['chat_id'] != null) {
      final chatId = int.tryParse(data['chat_id'].toString()) ?? -1;
      if (chatId != -1) {
        final chatRepository = getIt<ChatRepository>();
        final chatsResponse = await chatRepository.getAllChats();
        final context = AppRouter.navigatorKey.currentState?.context;

        if (context != null) {
          try {
            final chat = chatsResponse.chats.firstWhere((c) => c.id == chatId);
            final userRole = context.read<AuthCubit>().state.user?.user?.role;

            AppRouter.router.push(
              AppRoutes.chatDetail,
              extra: {
                'chat': chat,
                'isAdmin': userRole?.toLowerCase() == 'admin',
              },
            );
          } catch (e) {
            debugPrint('Chat not found or navigation failed: $e');
          }
        }
      }
    }
  }

  static void handleNewMessage(Map<String, dynamic> data) async {
    debugPrint('Notification received with data: $data');
    final context = AppRouter.navigatorKey.currentState?.context;
    if (context == null) return;

    final authCubit = context.read<AuthCubit>();
    final userRole = authCubit.state.user?.user?.role;

    if (data['action'] == 'new_message' && data['chat_id'] != null) {
      if (userRole?.toLowerCase() == 'user') {
        // Refresh support chat for user
        await authCubit.createSupportChat();
      } else if (userRole?.toLowerCase() == 'admin') {
        // Refresh chat list for admin
        final chatsCubit = getIt<ChatsCubit>();
        chatsCubit.fetchChatsWithoutLoading();
      }
    }
  }

  // Public method to show local notification
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    await _showNotification(
      title: title,
      body: body,
      payload: payload != null ? json.encode(payload) : null,
    );
  }

  // Get FCM token
  static Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
