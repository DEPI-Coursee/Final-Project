import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/screens/home_screen.dart';

class AuthController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool isSubmitting = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> submit() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    if (email.isEmpty) {
      Get.snackbar('Missing email', 'Please enter your email', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      Get.snackbar('Invalid email', 'Enter a valid email address', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (password.isEmpty || password.length < 6) {
      Get.snackbar('Invalid password', 'Password must be at least 6 characters', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    isSubmitting.value = false;

    Get.offAll(HomeScreen());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}


