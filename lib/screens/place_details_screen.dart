import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/screens/login_screen.dart';
import 'package:tour_guide/services/AuthService.dart';

class PlaceDetails extends StatelessWidget {
  PlaceDetails({super.key});

  final authservice = Authservice();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        titleSpacing: 10,
        title: Text(
          'Place Details',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🖼 Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  'https://cdn-imgix.headout.com/media/images/c4a520a45f9aea6fbcaab0eee5089a5a-Louvre%20Paris%20Pyramids.jpg?auto=format&w=1069.6000000000001&h=687.6&q=90&ar=14%3A9&crop=faces&fit=crop',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'louvre museum',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      'With its 146.59m in height, Kheops\' pyramid, has indeed deserved its modern-day nickname of The Great Pyramid. Khefren\'s adjacent pyramid appears to be somewhat higher, but this is only because it was built on a higher part of the Giza platform. It is, in fact, slightly over 3m "smaller".',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(content: Text("Added to Favorites")),
                          // );
                         authservice.isLoggedIn()? Get.snackbar('added', 'static mess'): Get.to(LoginScreen()) ;
                        },
                        icon: const Icon(Icons.favorite_border),
                        label: const Text("Add to Favorite"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text("Added to Visit List"),
                          //   ),
                          // );
                          authservice.isLoggedIn()? Get.snackbar('added', 'static mess'): Get.to(LoginScreen()) ;
                        },
                        icon: const Icon(Icons.list_alt),
                        label: const Text("Add to Visit List"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
