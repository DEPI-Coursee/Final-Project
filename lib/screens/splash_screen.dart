import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'getStrated_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State <SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const GetStartedScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
          Size size = MediaQuery.of(context).size;
   return Scaffold(
  body: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFFEC9E60), // Bright gold
          Color(0xFFF5F1E6), // Darker goldenrod
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Image.asset(
        "assets/logo.png",
        width: size.width / 2,
      ),
    ),
  ),
);

    
  } 
}