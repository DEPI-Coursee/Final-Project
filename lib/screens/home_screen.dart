import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tour_guide/screens/place_details_screen.dart';
import 'package:tour_guide/screens/favorits_screen.dart';
import 'package:tour_guide/screens/visit_list_screen.dart';
import '../controllers/home_controller.dart';
import 'package:tour_guide/services/AuthService.dart';
import 'login_screen.dart';

class HomeScreen extends GetView<HomeController> {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10,
        title: Text(
          'Tourio',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                'Menu',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favorites'),
              onTap: () {
                Get.to(FavoritesScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Visit List'),
              onTap: () {
                Get.to(VisitListScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey),
              title: const Text('Logout'),
              onTap: () async {
                final success = await controller.authService.signOut();
                if (success) {
                  Get.offNamed('/login');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logout failed. Try again.')),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Let\'s find the perfect place for you',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontFamily: 'Caveat',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search a place',
                      suffixIcon: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.search,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                // Show loading indicator
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show error message
                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error loading places',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.errorMessage.value,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.getlocation,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Show empty state
                if (controller.places.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 64,
                          color: Colors.white38,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No places found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: controller.getlocation,
                          child: const Text('Load Places'),
                        ),
                      ],
                    ),
                  );
                }

                // Show places list
                return ListView.builder(
                  itemCount: controller.places.length,
                  itemBuilder: (ctx, index) {
                    final place = controller.places[index];
                    return InkWell(
                      onTap: () {
                        // Ensure the enriched place model is passed to details
                        Get.to(() => PlaceDetails(place: place));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 120, // Adjusted width
                                height: 100, // Adjusted height
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 1,
                                  ),
                                ),

                                // DYNAMIC IMAGE DISPLAY LOGIC
                                child:
                                    place.imageUrl != null &&
                                        place.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          place
                                              .imageUrl!, // Use the fetched image URL
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder:
                                              (ctx, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    size: 48,
                                                    color: Colors.white70,
                                                  ),
                                        ),
                                      )
                                    : Center(
                                        // Fallback if no image URL was found/fetched
                                        child: Icon(
                                          Icons.place,
                                          size: 48,
                                          color: Colors.white70,
                                        ),
                                      ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      place.name ?? 'Unknown Place',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),

                                    // DYNAMIC DESCRIPTION: Display the enriched description
                                    Text(
                                      place.description ??
                                          place.addressLine2 ??
                                          'No description available.',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 6),
                                    if (place.country != null ||
                                        place.category != null)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            place.country!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                          ),
                                          SizedBox(width: 10),
                                          Icon(
                                            Icons.category,
                                            size: 14,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            place.category!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
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
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
