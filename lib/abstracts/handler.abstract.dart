import 'package:firebase_messaging/firebase_messaging.dart';

abstract class FirebaseCloudMessagingServiceHandler {
  void onNotificationReceived(RemoteMessage payload);
  void onNotificationTap(RemoteMessage? notification);
}
