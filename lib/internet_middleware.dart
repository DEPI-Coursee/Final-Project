import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/connection_controller.dart';

class InternetMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final connectionController = Get.find<ConnectionController>();
    
    // Check connectivity asynchronously
    connectionController.hasInternet().then((hasInternet) {
      if (!hasInternet) {
        // Redirect to offline page
        Get.offAllNamed('/offline-places');
      }
    });
    
    // Return null to allow navigation to continue
    // (will be interrupted by Get.offAllNamed if offline)
    return null;
  }
}