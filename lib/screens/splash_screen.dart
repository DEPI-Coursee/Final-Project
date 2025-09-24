import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State <SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
          Size size = MediaQuery.of(context).size;
   return Scaffold(
  body: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFFFFD700), // Bright gold
          Color(0xFFFFE55C), // Darker goldenrod
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Image.asset(
        "assets/logo.png",
        width: size.width / 2,
      )
          .animate()
          .fadeIn(duration: const Duration(milliseconds: 800))
          .then(delay: const Duration(seconds: 2))
          .fadeOut(duration: const Duration(milliseconds: 800)),
    ),
  ),
);

    
  } 
}