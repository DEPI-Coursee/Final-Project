import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class NotificationService {
  Future<void> initialize() async {
    await AwesomeNotifications().initialize(null, [ //null = no default icon
      //momken a3ml aktar mn channel kol chanel le no3 mo3yan mn el notification
      NotificationChannel(
          channelKey: 'visitList',
          channelName: 'Visit List Reminders',
          channelDescription: 'Notifications for scheduled place visits',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          enableVibration: true,
          playSound: true,
          importance: NotificationImportance.High, // Important for scheduled notifications
          enableLights: true,
          channelShowBadge: true)
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
          duration: Duration(seconds: 3)), //يعني notification يقعد قد إيه visible قبل ما يختفي
      actionButtons: [ //by3ml button gwa el notification
            NotificationActionButton(
              key: 'visitList', //button id => identifies which button the user has pressed
              label: 'Visit List',
              autoDismissible: true, //لما تدوسي عليه الإشعار يختفي.//////
            ),
          ],
    );
  }

  /// Schedule a notification 30 minutes before the visit time
  /// This uses Awesome Notifications' scheduled notification feature which works
  /// reliably even when the app is closed or the phone is in different states
  Future<void> scheduleVisitReminderNotification({
    required String placeId,
    required String placeName,
    required DateTime visitDateTime,
  }) async {
    try {
      // Calculate notification time: 30 minutes before visit time
      final notificationTime = visitDateTime.subtract(const Duration(minutes: 30));
      
      // Check if the notification time is in the past
      if (notificationTime.isBefore(DateTime.now())) {
        print('⚠️ Notification time is in the past. Skipping notification for: $placeName');
        return;
      }

      // Generate a unique notification ID based on placeId hash
      // This ensures each place has a unique notification that can be cancelled/updated
      final notificationId = placeId.hashCode.abs() % 2147483647; // Max int32 value

      // Cancel any existing notification for this place
      await AwesomeNotifications().cancel(notificationId);

      // Schedule the notification
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'visitList',
          title: 'Visit Reminder: $placeName',
          body: 'Your visit to $placeName is in 30 minutes!',
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true, // Wake up screen when notification arrives
          criticalAlert: false,
          // Store placeId in payload for potential use
          payload: {'placeId': placeId, 'placeName': placeName},
        ),
        schedule: NotificationCalendar(
          year: notificationTime.year,
          month: notificationTime.month,
          day: notificationTime.day,
          hour: notificationTime.hour,
          minute: notificationTime.minute,
          second: notificationTime.second,
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
          preciseAlarm: true, // Request precise alarm permission (Android 12+)
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'visitList',
            label: 'View Visit List',
            autoDismissible: true,
          ),
        ],
      );

      print('✅ Scheduled notification for $placeName at ${notificationTime.toString()}');
      print('   Visit time: ${visitDateTime.toString()}');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      // Don't throw - we don't want to break the add-to-visit-list flow if notification fails
    }
  }

  /// Cancel a scheduled notification for a specific place
  Future<void> cancelVisitReminderNotification(String placeId) async {
    try {
      final notificationId = placeId.hashCode.abs() % 2147483647;
      await AwesomeNotifications().cancel(notificationId);
      print('✅ Cancelled notification for place: $placeId');
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  static Future<void> _onNotificationAction(ReceivedAction action) async {
    if (action.buttonKeyPressed == 'visitList') { //the button id
      Get.toNamed('/visit-list');
    }
  }
}
