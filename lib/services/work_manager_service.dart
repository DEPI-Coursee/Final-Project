import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import 'notification_service.dart';

//ده annotation بيقول للـ Flutter إن الفانكشن دي مهمة ومش لازم يتم حذفها أثناء الـ tree shaking.
// WorkManager بيشتغل في background isolate، فلازم يكون عنده entry point ثابت.
@pragma('vm:entry-point') 
void tasks() {
  Workmanager().executeTask((task, data) async { // executes any background registered service at the specified period
    if (task == 'visitListTask') {
      await NotificationService().createNotificationForVisitList( "Daily Reminder",
        "you have places that needs to be explored.. check your visit list",);
      print('visit list bg task running');
      return Future.value(true);
    }
    return Future.value(false);
  });
}

class WorkManagerService {
  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }
    await Workmanager().initialize(
      tasks,
    );
  }
  void registerVisitListTask() {
    if (kIsWeb) {
      return;
    }
    // Workmanager().registerOneOffTask( //bt7sal mara wahda bs
    //   'offer',
    //   'offerTask',
    // );
    Workmanager()
        .registerPeriodicTask('visitList', 'visitListTask', frequency: 15.minutes);
  }
}
