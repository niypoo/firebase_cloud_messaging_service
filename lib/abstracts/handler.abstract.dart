import 'package:firebase_messaging/firebase_messaging.dart';

abstract class FirebaseCloudMessagingServiceHandler {
  Future<void> onNotificationReceived(RemoteMessage payload);
  void onNotificationTap(RemoteMessage? notification);
  
}
