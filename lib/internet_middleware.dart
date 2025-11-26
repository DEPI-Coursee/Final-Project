import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/connection_controller.dart';

class InternetMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    print('🔍 Middleware checking connection for route: $route');
    
    try {
      final connectionController = Get.find<ConnectionController>();
      
      // ✅ Check current connection status synchronously
      final isConnected = connectionController.isConnected.value;
      
      print('📊 Current connection status: $isConnected');
      
      if (!isConnected) {
        print('❌ No connection - redirecting to offline page');
        return const RouteSettings(name: '/offline-page');
      }
      
      print('✅ Connection OK - allowing navigation to $route');
      return null;
    } catch (e) {
      print('⚠️ Error in middleware: $e');
      // If we can't check connection, assume offline for safety
      return const RouteSettings(name: '/offline-page');
    }
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    print('📄 Page called: ${page?.name}');
    return super.onPageCalled(page);
  }
}