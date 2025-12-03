import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/offline_places_model.dart';

// ✅ Detail Screen (in the same file)
class OfflinePlaceDetailScreen extends StatelessWidget {
  final OfflinePlace place;

  const OfflinePlaceDetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(place.name),
        elevation: 0,
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
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  child: Icon(
                    Icons.broken_image,
                    size: 64,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
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