import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Offline Places",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75, // ✅ FIXED: Increased from 0.65 to make cards shorter
        ),
        itemCount: offlinePlaces.length,
        itemBuilder: (context, index) {
          final place = offlinePlaces[index];

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).cardColor,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.black26,
                )
              ],
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OfflinePlaceDetailScreen(place: place),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // IMAGE
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Image.asset(
                      place.imagePath,
                      height: 100, // Reduced from 120 to give more space for text
                      fit: BoxFit.cover,
                    ),
                  ),

                  // INFO
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          maxLines: 1, // Changed from 2 to 1 to save space
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14, // Reduced from 15
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          place.country,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          place.shortdescription ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                             fontWeight: FontWeight.w500,
                            color: Colors.white, // Light color for dark background
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}