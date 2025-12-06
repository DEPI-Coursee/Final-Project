import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tour_guide/bindings/AppBinding.dart';
import 'package:tour_guide/controllers/connection_controller.dart';
import 'package:tour_guide/controllers/theme_controller.dart';
import 'package:tour_guide/controllers/language_controller.dart';
import 'package:tour_guide/internet_middleware.dart';
import 'package:tour_guide/screens/getStrated_screen.dart';
import 'package:tour_guide/screens/home_screen.dart';
import 'package:tour_guide/controllers/home_controller.dart';
import 'package:tour_guide/screens/offline_page.dart';
import 'package:tour_guide/screens/splash_screen.dart';
import 'package:tour_guide/screens/login_screen.dart';
import 'package:tour_guide/screens/register_screen.dart';
import 'package:tour_guide/screens/place_details_screen.dart';
import 'package:tour_guide/screens/favorits_screen.dart';
import 'package:tour_guide/screens/visit_list_screen.dart';
import 'package:tour_guide/firebaseoptions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tour_guide/controllers/auth_controller.dart';
import 'package:tour_guide/services/app_translations.dart';
import 'package:tour_guide/services/notification_service.dart';
import 'package:tour_guide/services/work_manager_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  print('🚀 App starting...');
  
  // ✅ Initialize ConnectionController FIRST as permanent
  print('🌐 Initializing ConnectionController...');
  Get.put(ConnectionController(), permanent: true);
  
  // Initialize notifications
  print('🔔 Initializing notifications...');
  await NotificationService().initialize();
  
  // Defer notification permission request
  Future.delayed(const Duration(seconds: 50), () {
    NotificationService().takePermission();
  });
  
  // Initialize WorkManager
  print('⏰ Initializing WorkManager...');
  // final workManager = WorkManagerService();
  // await workManager.initialize();
  // workManager.registerVisitListTask();

  // Initialize Firebase
  try {
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
  }

  print('✅ All services initialized');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize binding to ensure ThemeController is available
    if (!Get.isRegistered<ThemeController>()) {
      AppBinding().dependencies();
    }
    
    return Obx(() {
      final ThemeController themeController = Get.find<ThemeController>();
      final LanguageController languageController = Get.find<LanguageController>();
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        locale: languageController.currentLocale.value,
        translations: AppTranslations(),//hyakhod el translations mn elclass elly 3mlnah
        title: 'Tour Guide App',
        initialRoute: '/splash',
        initialBinding: AppBinding(),
        themeMode: themeController.themeMode.value,
      getPages: [
        // ✅ Offline page should have NO middleware
        GetPage(
          name: '/offline-page',
          page: () => const OfflinePlacesScreen(),
        ),
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
        // ✅ Home page WITH middleware and page-level HomeController binding
        GetPage(
          name: '/home',
          page: () => HomeScreen(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<HomeController>()) {
              Get.put(HomeController(), permanent: true);
            }
          }),
          middlewares: [InternetMiddleware()],
        ),
        GetPage(
          name: '/place-details',
          page: () => const PlaceDetails(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<HomeController>()) {
              Get.put(HomeController(), permanent: true);
            }
          }),
          middlewares: [InternetMiddleware()],
        ),
        GetPage(
          name: '/favorites',
          page: () => FavoritesScreen(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<HomeController>()) {
              Get.put(HomeController(), permanent: true);
            }
          }),
        ),
        GetPage(
          name: '/visit-list',
          page: () => VisitListScreen(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<HomeController>()) {
              Get.put(HomeController(), permanent: true);
            }
          }),
        ),
      ],
      // 🌞 Light Theme - Compatible with your blue color palette
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1B3377), // Same primary blue
        scaffoldBackgroundColor: const Color(0xFFF0F4F8), // Light blue-gray background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF84AAF6), // Same light blue app bar
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardColor: Colors.white, // White cards for contrast
        dividerColor: const Color(0xFFD6E4F0), // Light blue-gray divider
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Color(0xFF0C1323)), // Dark blue-black text
          headlineMedium: TextStyle(color: Color(0xFF0C1323)),
          headlineSmall: TextStyle(color: Color(0xFF0C1323)),
          titleLarge: TextStyle(color: Color(0xFF1B3377)), // Primary blue for titles
          titleMedium: TextStyle(color: Color(0xFF1B3377)),
          titleSmall: TextStyle(color: Color(0xFF1B3377)),
          bodyLarge: TextStyle(color: Color(0xFF273E65)), // Medium blue-gray
          bodyMedium: TextStyle(color: Color(0xFF273E65)),
          bodySmall: TextStyle(color: Color(0xFF334155)), // Lighter blue-gray
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFE3EAF3), // Light blue-gray input background
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD6E4F0)), // Light blue border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD6E4F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1B3377), width: 2), // Primary blue focus
          ),
          labelStyle: const TextStyle(color: Color(0xFF273E65)), // Medium blue-gray
          hintStyle: const TextStyle(color: Color(0xFF5A7BA8)), // Lighter blue-gray
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF84AAF6), // Same light blue button
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF1B3377)), // Primary blue
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFFF8FAFC), // Very light blue-white
        ),
        listTileTheme: const ListTileThemeData(
          textColor: Color(0xFF1B3377), // Primary blue text
          iconColor: Color(0xFF5A7BA8), // Medium blue-gray icons
        ),
      ),
      // 🌙 Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1B3377),
        scaffoldBackgroundColor: const Color(0xFF0C1323),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF84AAF6),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardColor: const Color(0xFF1E293B),
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
    });
  }
}