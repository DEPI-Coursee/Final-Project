import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class NotificationService {
  Future<void> initialize() async {
    await AwesomeNotifications().initialize(null, [ //null = no default icon
      //momken a3ml aktar mn channel kol chanel le no3 mo3yan mn el notification
      NotificationChannel(
          channelKey: 'visitList',
          channelName: 'visitList',
          channelDescription: 'visitList',
          enableVibration: true,
          playSound: true)
    ]);

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationService._onNotificationAction,
    );
  }

  Future<void> takePermission() async {
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> createNotificationForVisitList(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content:
        NotificationContent(
          id: 1, //رقم الإشعار (لو جه إشعار تاني بنفس الرقم → هيتبدل مش هيتكرر).
          channelKey: 'visitList',
          title: title,
          body: body,
          duration: Duration(seconds: 10)), //يعني notification يقعد قد إيه visible قبل ما يختفي
      actionButtons: [ //by3ml button gwa el notification
            NotificationActionButton(
              key: 'visitList', //button id => identifies which button the user has pressed
              label: 'Visit List',
              autoDismissible: true, //لما تدوسي عليه الإشعار يختفي.//////
            ),
          ],
    );
  }

  static Future<void> _onNotificationAction(ReceivedAction action) async {
    if (action.buttonKeyPressed == 'visitList') { //the button id
      Get.toNamed('/visit-list');
    }
  }
}
