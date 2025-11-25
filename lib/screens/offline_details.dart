import 'package:flutter/material.dart';
import '../models/offline_places_model.dart';

// ✅ Offline places data
final offlinePlaces = [
  OfflinePlace(
    name: "Pyramids of Giza",
    country: "Egypt",
    description: "One of the Seven Wonders of the Ancient World. The Great Pyramid of Giza is the oldest and largest of the pyramids in the Giza pyramid complex.",
    imagePath: "assets/pyramids.jpeg",
  ),
  OfflinePlace(
    name: "Louvre Museum",
    country: "France",
    description: "World's largest art museum and home of the Mona Lisa. The Louvre is a historic monument in Paris and one of the most visited museums in the world.",
    imagePath: "assets/louvre.jpeg",
  ),
  OfflinePlace(
    name: "Great Wall of China",
    country: "China",
    description: "Ancient series of walls and fortifications. Built to protect Chinese states from invasions, it stretches over 13,000 miles.",
    imagePath: "assets/great_wall.jpeg",
  ),
  OfflinePlace(
    name: "Eiffel Tower",
    country: "France",
    description: "An iconic iron tower in Paris visited by millions every year. Built in 1889, it stands 330 meters tall.",
    imagePath: "assets/eiffel.jpeg",
  ),
  OfflinePlace(
    name: "Statue of Liberty",
    country: "USA",
    description: "A symbol of freedom located on Liberty Island in New York. A gift from France, it was dedicated in 1886.",
    imagePath: "assets/liberty.jpeg",
  ),
  OfflinePlace(
    name: "Colosseum",
    country: "Italy",
    description: "Ancient Roman amphitheater in the heart of Rome. Built in 70-80 AD, it could hold up to 80,000 spectators.",
    imagePath: "assets/colosseum.jpeg",
  ),
  OfflinePlace(
    name: "Duomo di Milano",
    country: "Italy",
    description: "A stunning Gothic cathedral and one of Milan's most iconic landmarks. Construction began in 1386 and took nearly six centuries to complete.",
    imagePath: "assets/milan_duomo.jpeg",
  ),
  OfflinePlace(
    name: "The Egyptian Museum",
    country: "Egypt",
    description: "Home to the world's largest collection of ancient Egyptian artifacts. Houses over 120,000 items including treasures from Tutankhamun's tomb.",
    imagePath: "assets/egypt_museum.jpeg",
  ),
];

// ✅ Main Grid Screen
class OfflinePlacesScreen extends StatelessWidget {
  const OfflinePlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Offline Places",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 4,
      ),

      body: GridView.builder(
        padding: const EdgeInsets.all(14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        itemCount: offlinePlaces.length,
        itemBuilder: (context, index) {
          final place = offlinePlaces[index];

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                // ✅ Navigate to detail page
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
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: Image.asset(
                      place.imagePath,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          color: Colors.grey.shade800,
                          child: const Icon(
                            Icons.broken_image,
                            size: 32,
                            color: Colors.white54,
                          ),
                        );
                      },
                    ),
                  ),

                  // Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  place.country,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // Offline banner
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        color: Theme.of(context).primaryColor.withOpacity(0.15),
        child: Text(
          "You're offline — showing saved places",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

// ✅ Detail Screen (in the same file)
class OfflinePlaceDetailScreen extends StatelessWidget {
  final OfflinePlace place;

  const OfflinePlaceDetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Large Image
            Image.asset(
              place.imagePath,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey.shade800,
                  child: const Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.white54,
                  ),
                );
              },
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    place.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Country with icon
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        place.country,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // "About" Section Header
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    place.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: 28),

                  // Offline indicator banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.offline_bolt,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'This place is available offline\nNo internet connection required',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}