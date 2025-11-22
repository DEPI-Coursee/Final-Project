import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tour_guide/services/Authservice.dart';
import 'package:tour_guide/models/place_model.dart';
import 'home_controller.dart';
 
class AuthController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

 


   final RxBool isPasswordVisible = false.obs;
  final RxBool isSubmitting = false.obs;
  late final Authservice authService;



@override
  
  void onInit() {
    super.onInit();
   authService = Get.find<Authservice>();   
   
  }

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

    final signedIn = await authService.signIn(email, password);
    if (signedIn) {
      // Check if there's a return route from arguments
      final arguments = Get.arguments as Map<String, dynamic>?;
      if (arguments != null && arguments.containsKey('returnRoute')) {
        final returnRoute = arguments['returnRoute'] as String;
        final place = arguments['place'] as PlaceModel?;
        final action = arguments['action'] as String?;
        
        // Navigate back to the return route with the place
        if (place != null) {
          // Store pending action in HomeController before navigating
          try {
            final homeController = Get.find<HomeController>();
            if (action != null) {
              homeController.pendingActionType = action;
              homeController.pendingPlaceId = homeController.getPlaceId(place);
            }
          } catch (e) {
            print('⚠️ Could not store pending action: $e');
          }
          
          // Navigate back to place details
          Get.offAllNamed(returnRoute, arguments: place);
        } else {
          Get.offAllNamed(returnRoute);
        }
      } else {
        // No return route, go to home
        Get.offAllNamed('/home');
      }
    } else {
      Get.snackbar('error signing in', 'enter a valid email and password', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty) {
      Get.snackbar('Missing name', 'Please enter your full name', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar('Invalid email', 'Please enter a valid email', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (password.length < 6) {
      Get.snackbar('Weak password', 'Password must be at least 6 characters', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSubmitting.value = true;
    try {
      final success = await authService.signUp(name, email, password);
      isSubmitting.value = false;

      if (success != null) {
        // Check if there's a return route from arguments (for registration)
        final arguments = Get.arguments as Map<String, dynamic>?;
        if (arguments != null && arguments.containsKey('returnRoute')) {
          final returnRoute = arguments['returnRoute'] as String;
          final place = arguments['place'] as PlaceModel?;
          final action = arguments['action'] as String?;
          
          // Navigate back to the return route with the place
          if (place != null) {
            // Store pending action in HomeController before navigating
            try {
              final homeController = Get.find<HomeController>();
              if (action != null) {
                homeController.pendingActionType = action;
                homeController.pendingPlaceId = homeController.getPlaceId(place);
              }
            } catch (e) {
              print('⚠️ Could not store pending action: $e');
            }
            
            // Navigate back to place details
            Get.offAllNamed(returnRoute, arguments: place);
          } else {
            Get.offAllNamed(returnRoute);
          }
        } else {
          // No return route, go to home
          Get.offAllNamed('/home');
        }
      } else {
        Get.snackbar('Registration failed', 'Something went wrong. Please try again.', snackPosition: SnackPosition.BOTTOM);
      }
    } on FirebaseAuthException catch (e) {
      isSubmitting.value = false;
      String errorMessage = 'Registration failed';
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email is already registered';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Registration is not allowed';
          break;
        default:
          errorMessage = e.message ?? 'Something went wrong';
      }
      Get.snackbar('Registration failed', errorMessage, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      isSubmitting.value = false;
      Get.snackbar('Registration failed', 'Error: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}



