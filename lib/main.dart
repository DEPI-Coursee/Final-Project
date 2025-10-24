import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/screens/getStrated_screen.dart';
import 'package:tour_guide/screens/home_screen.dart';
import 'package:tour_guide/screens/splash_screen.dart';
import 'package:tour_guide/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tour Guide App',
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
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF84AAF6),
          ),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF1E293B),
        ),
        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          iconColor: Colors.white70,
        ),
      ),
      home: HomeScreen(),
    );
  }
}
