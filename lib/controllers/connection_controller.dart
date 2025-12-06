import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ConnectionController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  final RxBool isInitialized = false.obs;
  
  Timer? _periodicCheckTimer;
  bool _isCheckingInternet = false;

  @override
  void onInit() {
    super.onInit();
    print('🌐 ConnectionController initializing...');
    
    // Check initial connection with real internet test
    checkConnectionWithRealTest();
    
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) async {
      print('📡 Connectivity changed: $result');
      
      // Don't trust connectivity_plus alone - verify with real test
      if (result == ConnectivityResult.none) {
        isConnected.value = false;
        _showOfflineSnackbar();
      } else {
        // Connectivity says we're connected, but let's verify
        final actuallyConnected = await _testRealInternet();
        isConnected.value = actuallyConnected;
        
        if (actuallyConnected) {
          _showOnlineSnackbar();
        } else {
          _showOfflineSnackbar();
        }
      }
    });
    
    // Periodic real internet check every 10 seconds
    _startPeriodicCheck();

    // Mark controller as initialized after setting up listeners and timers
    isInitialized.value = true;
  }

  @override
  void onClose() {
    _periodicCheckTimer?.cancel();
    super.onClose();
  }

  /// Start periodic internet checking
  void _startPeriodicCheck() {
    _periodicCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!_isCheckingInternet) {
        await checkConnectionWithRealTest();
      }
    });
  }

  /// Check connection using connectivity_plus first, then verify with real test
  Future<void> checkConnection() async {
    try {
      print('🔍 Checking connection...');
      final result = await _connectivity.checkConnectivity();
      
      if (result == ConnectivityResult.none) {
        print('❌ No network adapter connected');
        isConnected.value = false;
      } else {
        print('📶 Network adapter connected, verifying real internet...');
        // Don't trust it - verify with real internet test
        final actuallyConnected = await _testRealInternet();
        isConnected.value = actuallyConnected;
      }
      
      print('✅ Connection check complete: ${isConnected.value}');
    } catch (e) {
      print('❌ Error checking connection: $e');
      isConnected.value = false;
    }
  }

  /// Check connection with REAL internet test (makes actual HTTP request)
  Future<void> checkConnectionWithRealTest() async {
    if (_isCheckingInternet) return;
    
    try {
      _isCheckingInternet = true;
      print('🌐 Testing real internet connection...');
      
      final actuallyConnected = await _testRealInternet();
      
      final wasConnected = isConnected.value;
      isConnected.value = actuallyConnected;
      
      // Only show snackbar if connection state changed
      if (wasConnected != actuallyConnected) {
        if (actuallyConnected) {
          _showOnlineSnackbar();
        } else {
          _showOfflineSnackbar();
        }
      }
      
      print('✅ Real internet test complete: ${isConnected.value}');
    } catch (e) {
      print('❌ Error in real internet test: $e');
      isConnected.value = false;
    } finally {
      _isCheckingInternet = false;
    }
  }

  /// Test if there's REAL internet by making an actual HTTP request
  Future<bool> _testRealInternet() async {
    // On web, HTTP requests to arbitrary domains are often blocked by CORS.
    // Rely on connectivity_plus instead to avoid false "offline" results.
    if (kIsWeb) {
      try {
        final result = await _connectivity.checkConnectivity();
        final hasNetwork = result != ConnectivityResult.none;
        print('🌐 Web platform detected - using connectivity_only check: $hasNetwork');
        return hasNetwork;
      } catch (e) {
        print('⚠️ Web connectivity check failed: $e');
        // Fail open on web to avoid locking the app on the offline page
        return true;
      }
    }

    try {
      print('🔎 Making test HTTP request to Google...');
      
      // Try to reach a reliable endpoint with timeout
      final response = await http.get(
        Uri.parse('https://www.google.com'),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⏱️ HTTP request timed out');
          throw TimeoutException('Connection timeout');
        },
      );
      
      final success = response.statusCode == 200;
      print('${success ? "✅" : "❌"} HTTP test result: ${response.statusCode}');
      return success;
    } catch (e) {
      print('❌ HTTP test failed: $e');
      return false;
    }
  }

  /// Public method to check if internet is available (with real test)
  Future<bool> hasInternet() async {
    print('🌐 hasInternet() called - testing real connection...');
    
    // First check connectivity
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      print('❌ No network adapter');
      isConnected.value = false;
      return false;
    }
    
    // Then verify with real internet test
    final actuallyConnected = await _testRealInternet();
    isConnected.value = actuallyConnected;
    
    print('✅ hasInternet() result: $actuallyConnected');
    return actuallyConnected;
  }

  void _showOnlineSnackbar() {
    // Only show if Get context is available
    if (Get.isSnackbarOpen == true) {
      Get.closeAllSnackbars();
    }
    
    Get.snackbar(
      'connected'.tr,
      'youAreBackOnline'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(10),
    );
  }

  void _showOfflineSnackbar() {
    // Only show if Get context is available
    if (Get.isSnackbarOpen == true) {
      Get.closeAllSnackbars();
    }
    
    Get.snackbar(
      'noConnection'.tr,
      'youAreOffline'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(10),
    );
  }
}