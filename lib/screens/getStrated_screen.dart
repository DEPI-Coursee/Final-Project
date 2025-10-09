  import 'package:flutter/material.dart';
  import 'package:flutter_animate/flutter_animate.dart';

  class GetStartedScreen extends StatefulWidget {
    const GetStartedScreen({super.key});

    @override
    State <GetStartedScreen> createState() => _GetStartedScreenState();
  }

  class _GetStartedScreenState extends State<GetStartedScreen> {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background_getStarted.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              
              // Spacer to push content down
              Expanded(child: SizedBox()),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Simple way to\ntravel the world",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ).animate().fadeIn(duration: 800.ms),

                    const SizedBox(height: 16),

                    // Description text
                    Text(
                      "We are the best rated travel agency of 2022 in the world, explore our services.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Bottom Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.off(HomeScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Get Started",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_ios, size: 16),
                            Icon(Icons.arrow_forward_ios, size: 16),
                            Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      );
              
    } 
  }
