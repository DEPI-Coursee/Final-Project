import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/controllers/connection_controller.dart';
import 'package:tour_guide/screens/offline_details.dart';
import '../models/offline_places_model.dart';

final offlinePlaces = [
  OfflinePlace(
    name: "Pyramids of Giza",
    country: "Egypt",
    description: "One of the Seven Wonders of the Ancient World.",
    imagePath: "assets/pyramids.jpeg",
    shortdescription: "Ancient Egyptian wonder",
  ),
  OfflinePlace(
    name: "Louvre Museum",
    country: "France",
    description: "World's largest art museum and home of the Mona Lisa.",
    imagePath: "assets/louvre.jpeg",
    shortdescription: "World's largest art museum",
  ),
  OfflinePlace(
    name: "Great Wall of China",
    country: "China",
    description: "Ancient series of walls and fortifications.",
    imagePath: "assets/great_wall.jpeg",
    shortdescription: "Ancient fortifications",
  ),
  OfflinePlace(
    name: "Eiffel Tower",
    country: "France",
    description: "An iconic iron tower in Paris visited by millions every year.",
    imagePath: "assets/eiffel.jpeg",
    shortdescription: "Iconic Parisian landmark",
  ),
  OfflinePlace(
    name: "Statue of Liberty",
    country: "USA",
    description: "A symbol of freedom located on Liberty Island in New York.",
    imagePath: "assets/liberty.jpeg",
    shortdescription: "Symbol of freedom",
  ),
  OfflinePlace(
    name: "Colosseum",
    country: "Italy",
    description: "Ancient Roman amphitheater in the heart of Rome.",
    imagePath: "assets/colosseum.jpeg",
    shortdescription: "Ancient Roman amphitheater",
  ),
  OfflinePlace(
    name: "Duomo di Milano",
    country: "Italy",
    description: "A stunning Gothic cathedral and one of Milan's most iconic landmarks.",
    imagePath: "assets/milan_duomo.jpeg",
    shortdescription: "Gothic cathedral in Milan",
  ),
  OfflinePlace(
    name: "The Egyptian Museum",
    country: "Egypt",
    description: "Home to the world's largest collection of ancient Egyptian artifacts.",
    imagePath: "assets/egypt_museum.jpeg",
    shortdescription: "Ancient Egyptian artifacts",
  ),
];

class OfflinePlacesScreen extends StatelessWidget {
  const OfflinePlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Check for internet connection restoration (only on native platforms)
    if (!GetPlatform.isWeb) {
      final connectionController = Get.find<ConnectionController>();

      Future.microtask(() async {
        try {
          final hasInternet = await connectionController.hasInternet();
          if (hasInternet && Get.currentRoute == '/offline-page') {
            print('🌐 Connection restored on offline page - going back to /home');
            Get.offAllNamed('/home');
          }
        } catch (_) {
          // If anything goes wrong here, just stay on offline page.
        }
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Offline Places".tr,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate card width for 2 columns with spacing
          final cardWidth = (constraints.maxWidth - 36) / 2; // 12 padding on each side + 12 spacing between
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: offlinePlaces.map((place) {
                return SizedBox(
                  width: cardWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 6,
                          color: Colors.black.withOpacity(0.08),
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        // ✅ Use GetX navigation instead of Navigator
                        Get.to(() => OfflinePlaceDetailScreen(place: place));
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // IMAGE - Fixed height for consistency
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                            child: Image.asset(
                              place.imagePath,
                              width: cardWidth,
                              height: cardWidth * 0.75, // Maintain aspect ratio
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: cardWidth,
                                  height: cardWidth * 0.75,
                                  color: Colors.grey.shade300,
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 32,
                                    color: Colors.grey.shade600,
                                  ),
                                );
                              },
                            ),
                          ),

                          // INFO - Sizes to content
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  place.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  place.country,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  place.shortdescription ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
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
              }).toList(),
            ),
          );
        },
      ),

      // Offline banner + manual "Retry" button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "You're offline — showing saved places".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final connectionController = Get.find<ConnectionController>();
                  final hasInternet = await connectionController.hasInternet();
                  if (hasInternet) {
                    print('🌐 Retry from offline page: internet available, going to /home');
                    Get.offAllNamed('/home');
                  } else {
                    Get.snackbar(
                      'stillOffline'.tr,
                      'checkInternetConnection'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                child: Text('retryOnline'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}