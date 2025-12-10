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

  /// Prevent showing snackbars on initial app launch
  bool isInitial = true;

  @override
  void onInit() {
    super.onInit();
    print('🌐 ConnectionController initializing...');

    // First real test (no snackbar because isInitial = true)
    checkConnectionWithRealTest();

    // Connectivity listener
    _connectivity.onConnectivityChanged.listen((result) async {
      print('📡 Connectivity changed: $result');

      if (isInitial) return;

      if (result == ConnectivityResult.none) {
        isConnected.value = false;
        _showOfflineSnackbar();
      } else {
        final actuallyConnected = await _testRealInternet();
        isConnected.value = actuallyConnected;

        if (actuallyConnected) {
          _showOnlineSnackbar();
        } else {
          _showOfflineSnackbar();
        }
      }
    });

    // Periodic check
    _startPeriodicCheck();

    // Wait until all listeners finish, then allow snackbars
    Future.delayed(Duration(seconds: 1), () {
      isInitial = false;
      print("🔓 Snackbars are now enabled.");
    });

    isInitialized.value = true;
  }

  @override
  void onClose() {
    _periodicCheckTimer?.cancel();
    super.onClose();
  }

  void _startPeriodicCheck() {
    _periodicCheckTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) async {
      if (!_isCheckingInternet) {
        await checkConnectionWithRealTest();
      }
    });
  }

  Future<void> checkConnection() async {
    try {
      print('🔍 Checking connection...');
      final result = await _connectivity.checkConnectivity();

      if (result == ConnectivityResult.none) {
        print('❌ No network adapter connected');
        isConnected.value = false;
      } else {
        final actuallyConnected = await _testRealInternet();
        isConnected.value = actuallyConnected;
      }

      print('✅ Connection check complete: ${isConnected.value}');
    } catch (e) {
      print('❌ Error checking connection: $e');
      isConnected.value = false;
    }
  }

  Future<void> checkConnectionWithRealTest() async {
    if (_isCheckingInternet) return;

    try {
      _isCheckingInternet = true;
      print('🌐 Testing real internet connection...');

      final actuallyConnected = await _testRealInternet();

      final wasConnected = isConnected.value;
      isConnected.value = actuallyConnected;

      if (!isInitial && wasConnected != actuallyConnected) {
        if (actuallyConnected) {
          _showOnlineSnackbar();
        } else {
          _showOfflineSnackbar();
        }
      }

      print('✅ Real internet test complete: ${isConnected.value}');
    } catch (e) {
      print('❌ Error during real internet test: $e');
      isConnected.value = false;
    } finally {
      _isCheckingInternet = false;
    }
  }

  Future<bool> _testRealInternet() async {
    if (kIsWeb) {
      try {
        final result = await _connectivity.checkConnectivity();
        final hasNetwork = result != ConnectivityResult.none;
        print('🌐 Web connectivity check: $hasNetwork');
        return hasNetwork;
      } catch (e) {
        print('⚠️ Web connectivity check failed: $e');
        return true;
      }
    }

    try {
      print('🔎 Making test HTTP request to Google...');

      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('⏱️ HTTP request timed out');
              throw TimeoutException('Connection timeout');
            },
          );

      final success = response.statusCode == 200;
      print('${success ? "✅" : "❌"} HTTP test: ${response.statusCode}');
      return success;
    } catch (e) {
      print('❌ HTTP test failed: $e');
      return false;
    }
  }

  Future<bool> hasInternet() async {
    print('🌐 hasInternet() called...');

    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      print('❌ No network adapter');
      isConnected.value = false;
      return false;
    }

    final actuallyConnected = await _testRealInternet();
    isConnected.value = actuallyConnected;

    print('✅ hasInternet() result: $actuallyConnected');
    return actuallyConnected;
  }

  void _showOnlineSnackbar() {
    if (isInitial) return;

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
    if (isInitial) return;

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
