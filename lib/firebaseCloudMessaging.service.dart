import 'dart:convert';
import 'dart:io';
import 'package:firebase_cloud_messaging_service/abstracts/handler.abstract.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class FirebaseCloudMessagingService extends GetxService {
  // define
  static FirebaseCloudMessagingService get to => Get.find();

  // Properties
  final FirebaseMessaging instance = FirebaseMessaging.instance;

  final String firebaseFunctionsUrl;
  final FirebaseCloudMessagingServiceHandler handler;
  final Future<void> Function(RemoteMessage payload)
      onBackgroundNotificationReceived;

  FirebaseCloudMessagingService({
    required this.handler,
    required this.firebaseFunctionsUrl,
    required this.onBackgroundNotificationReceived,
  });

  Future<FirebaseCloudMessagingService> init() async {

    // Request getAPNSToken
    if(Platform.isIOS) {
     final String? aPNSToken= await instance.getAPNSToken();
     print('APNSToken: $aPNSToken');
    }

    // Foreground
    // FCM PayLoad Messages listen
    FirebaseMessaging.onMessage.listen(onBackgroundNotificationReceived);

    // Background
    // FCM PayLoad Messages listen
    FirebaseMessaging.onBackgroundMessage(onBackgroundNotificationReceived);

    // Terminated status
    // Notification Tap Listen
    await instance.getInitialMessage().then(handler.onNotificationTap);
    // Background not terminated
    // Notification Tap Listen
    FirebaseMessaging.onMessageOpenedApp.listen(handler.onNotificationTap);

    // return self
    return this;
  }

  // request Permission
  Future<NotificationSettings> requestPermission() async {
    return await instance.requestPermission(
        sound: true, badge: true, alert: true);
  }

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  Future<void> setForegroundNotificationPresentationOptions() async {
    await instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<Response?> pushToTokens({
    required Set<Set<String>> tokens,
    required String title,
    required String body,
    String? url,
    String urlPath = '/pushFCM',
    Set<String> exceptTokens = const {},
    String sound = 'alert',
    Map<String, dynamic>? data,
    String? image,
  }) async {
    //check tokens first
    if (tokens.isNotEmpty) return null;

    // request send
    return await (GetConnect()).post(
      Uri.https(
        url ?? firebaseFunctionsUrl,
        urlPath,
      ).toString(),
      json.encode(
        {
          'tokens': handleTokens(tokens, exceptTokens),
          'title': title,
          'body': body,
          'sound': sound,
          'data': data,
        },
      ),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  Future<String?> getToken() async {
    if(Platform.isIOS) {
      await Future.delayed(const Duration(seconds: 3));
      final String? aPNSToken= await instance.getAPNSToken();
      print('APNSToken: $aPNSToken');
    }
    return await instance.getToken();
  }

  //To init token listen
  Stream<String> onChangeToken() {
    return instance.onTokenRefresh;
  }

  //SUBSCRIBE USER IN TOPIC
  Future<void> subscribeToTopic(topic) async {
    await instance.subscribeToTopic(topic);
  }

  //UNSUBSCRIBE USER FROM TOPIC BY HIM-SELF
  Future<void> unsubscribeToTopic(topic) async {
    await instance.unsubscribeFromTopic(topic);
  }

  // return token
  static Set<String> handleTokens(
      Set<Set<String>> tokens, Set<String> exceptTokens) {
    Set<String> token = {};

    if (tokens.isEmpty) return token;

    for (var user in tokens) {
      token.addAll(user);
    }

    tokens.difference(exceptTokens);

    return token;
  }
}
