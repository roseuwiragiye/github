import 'dart:developer';

import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotifHelper{
  NotifHelper._();
  static Future<void> initNotif() async{
    await OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    await OneSignal.shared.setAppId("953920c8-d0f9-4a8c-b225-2752d8b386c8");

    await OneSignal.shared
        .promptUserForPushNotificationPermission()
        .then((pushNotificationPermission) {
          log("Permission granted: $pushNotificationPermission");
        });

        }
    
}
