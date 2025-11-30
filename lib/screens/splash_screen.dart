// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:async';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State <SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Timer(const Duration(seconds: 4), () {
//       Get.offNamed('/get-started');
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       body: Container(
//         height: size.height,
//         width: size.width,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Theme.of(context).primaryColor,
//               Theme.of(context).scaffoldBackgroundColor,
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(height: size.height * 0.3),
//               Image.asset(
//                 "assets/logo5.png",
//                 width: size.width * 0.85,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 "Tourio",
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   fontFamily: 'Caveat',
//                   fontSize: 40,
//                   color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
//                 ),
//               ),
//               SizedBox(height: size.height * 0.3),
//             ],
//           ),
//         ),
//       ),
//     );


//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {

  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    // Progress animation duration = 3 seconds
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Get.offNamed('/get-started');
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).scaffoldBackgroundColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              "assets/logo5.png",
              width: size.width * 0.85,
            ),

            const SizedBox(height: 15),

            // App Name
            Text(
              "Tourio",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'Caveat',
                fontSize: 40,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.85),
              ),
            ),

            const SizedBox(height: 40),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressController.value,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColorDark,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
