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

  /// Schedule a notification based on time until visit:
  /// - If time > 30 min: schedule 30 min before visit
  /// - If 5 min < time <= 30 min: schedule 5 min before visit
  /// - If time <= 5 min: show notification immediately
  /// This uses Awesome Notifications' scheduled notification feature which works
  /// reliably even when the app is closed or the phone is in different states
  Future<void> scheduleVisitReminderNotification({
    required String placeId,
    required String placeName,
    required DateTime visitDateTime,
  }) async {
    try {
      final now = DateTime.now();
      final timeUntilVisit = visitDateTime.difference(now);
      
      // Check if visit time is in the past
      if (timeUntilVisit.isNegative) {
        print('⚠️ Visit time is in the past. Skipping notification for: $placeName');
        return;
      }

      // Generate a unique notification ID based on placeId hash
      // This ensures each place has a unique notification that can be cancelled/updated
      final notificationId = placeId.hashCode.abs() % 2147483647; // Max int32 value

      // Cancel any existing notification for this place
      await AwesomeNotifications().cancel(notificationId);

      DateTime? notificationTime;
      String bodyMessage;
      int minutesBefore;

      // Determine notification timing based on time until visit
      if (timeUntilVisit.inMinutes > 30) {
        // Schedule 30 minutes before visit
        minutesBefore = 30;
        notificationTime = visitDateTime.subtract(const Duration(minutes: 30));
        bodyMessage = 'Your visit to $placeName is in 30 minutes!';
      } else if (timeUntilVisit.inMinutes > 5) {
        // Schedule 5 minutes before visit
        minutesBefore = 5;
        notificationTime = visitDateTime.subtract(const Duration(minutes: 5));
        bodyMessage = 'Your visit to $placeName is in 5 minutes!';
      } else {
        // Show notification immediately (time <= 5 minutes)
        minutesBefore = 0;
        notificationTime = null; // Will show immediately
        final remainingMinutes = timeUntilVisit.inMinutes;
        if (remainingMinutes > 0) {
          bodyMessage = 'Your visit to $placeName is in $remainingMinutes minute${remainingMinutes == 1 ? '' : 's'}!';
        } else {
          bodyMessage = 'Your visit to $placeName is starting now!';
        }
      }

      // Create notification content
      final notificationContent = NotificationContent(
        id: notificationId,
        channelKey: 'visitList',
        title: 'Visit Reminder: $placeName',
        body: bodyMessage,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true, // Wake up screen when notification arrives
        criticalAlert: false,
        // Store placeId in payload for potential use
        payload: {'placeId': placeId, 'placeName': placeName},
      );

      // Schedule or show immediately
      if (notificationTime != null) {
        // Schedule the notification
        await AwesomeNotifications().createNotification(
          content: notificationContent,
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
        print('   Notification will appear $minutesBefore minutes before visit');
      } else {
        // Show notification immediately
        await AwesomeNotifications().createNotification(
          content: notificationContent,
          actionButtons: [
            NotificationActionButton(
              key: 'visitList',
              label: 'View Visit List',
              autoDismissible: true,
            ),
          ],
        );
        print('✅ Showing immediate notification for $placeName');
        print('   Visit time: ${visitDateTime.toString()}');
        print('   Time until visit: ${timeUntilVisit.inMinutes} minutes');
      }
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
