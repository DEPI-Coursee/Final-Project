import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/bindings/AppBinding.dart';
import 'package:tour_guide/screens/getStrated_screen.dart';
import 'package:tour_guide/screens/home_screen.dart';
import 'package:tour_guide/screens/splash_screen.dart';
import 'package:tour_guide/screens/login_screen.dart';
import 'package:tour_guide/screens/register_screen.dart';
import 'package:tour_guide/screens/place_details_screen.dart';
import 'package:tour_guide/screens/favorits_screen.dart';
import 'package:tour_guide/screens/visit_list_screen.dart';
import 'package:tour_guide/firebaseoptions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tour_guide/controllers/home_controller.dart';
import 'package:tour_guide/controllers/auth_controller.dart';
import 'package:tour_guide/models/place_model.dart';
import 'package:tour_guide/services/Authservice.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:tour_guide/services/notification_service.dart';
import 'package:tour_guide/services/work_manager_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // NotificationService notificationService = NotificationService();
  // await notificationService.initialize();
  await WorkManagerService().initialize();
  await NotificationService().initialize();


  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully.");
  } catch (e) {
    // Handle initialization error gracefully
    print("Error initializing Firebase: $e");
  }


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tour Guide App',
      // Routes configuration
      initialRoute: '/splash',
      // Register LocationController as app-wide service (permanent)
      initialBinding: AppBinding(),
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: '/get-started',
          page: () => const GetStartedScreen(),
        ),
        GetPage(
          name: '/login',
          page: () => LoginScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => AuthController());
          }),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => AuthController());
          }),
        ),
        GetPage(
          name: '/home',
          page: () => HomeScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => HomeController());
          }),
        ),
        GetPage(
          name: '/place-details',
          page: () {
            final place = Get.arguments as PlaceModel?;
            if (place == null) {
              // Return a fallback screen if no place is provided
              return Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(
                  child: Text('Place details not available'),
                ),
              );
            }
            return PlaceDetails(place: place);
          },
        ),
        GetPage(
          name: '/favorites',
          page: () => FavoritesScreen(),
        ),
        GetPage(
          name: '/visit-list',
          page: () => VisitListScreen(),
        ),
      ],
      theme: ThemeData(
        // Dark blue color scheme
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1B3377), // Dark blue
        scaffoldBackgroundColor: const Color(0xFF0C1323), // Very dark blue
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF84AAF6),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardColor: const Color(0xFF1E293B), // Dark blue-gray
        dividerColor: const Color(0xFF334155),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white60),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF273E65),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF213555)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF213555)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white60),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF84AAF6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF84AAF6)),
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1E293B)),
        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          iconColor: Colors.white70,
        ),
      ),
    );
  }
}
