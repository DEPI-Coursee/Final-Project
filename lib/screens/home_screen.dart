import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tour_guide/screens/favorits_screen.dart';
import 'package:tour_guide/screens/visit_list_screen.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // ✅ Use the globally registered HomeController
  final HomeController controller = Get.find<HomeController>();

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
                if (controller.authService.isLoggedIn()) {
                  Get.to(FavoritesScreen());
                } else {
                  Get.snackbar(
                    'Login Required',
                    'Please login to view your favorites',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  Get.toNamed('/login');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Visit List'),
              onTap: () {
                if (controller.authService.isLoggedIn()) {
                  Get.to(VisitListScreen());
                } else {
                  Get.snackbar(
                    'Login Required',
                    'Please login to view your visit list',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  Get.toNamed('/login');
                }
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
                      hintText: 'Search: museum, restaurant, park...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                      ),
                      suffixIcon: IconButton(
                        onPressed: controller.clearSearch,
                        icon: Icon(
                          Icons.clear,
                          color: Theme.of(context).primaryColor,
                        ),
                        tooltip: 'Clear search',
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      // Debounce is handled in controller
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: Obx(() {
                      // Access the observable at the start to establish proper reactivity
                      final selectedIndex = controller.selected.value;
                      final categories = controller.placeType;

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              controller.selected.value = index;
                              controller.filterPlacesByType(controller.placeType[index]);
                              for (var value1 in controller.CopyPlaces) {
                                print(value1.imageUrl);

                                    }

                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: selectedIndex == index
                                    ? Theme.of(context).primaryColor
                                    : const Color(0xFF273E65),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 20,
                              ),
                              child: Center(
                                child: Text(
                                  categories[index],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: selectedIndex == index
                                        ? Colors.white
                                        : Colors.white60,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  )

                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                // Show loading indicator
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show error message (only for non-network errors)
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
<<<<<<< HEAD
=======
                        // Navigate to place details with the place as argument
>>>>>>> f4c16511503e607d031ff38cab2837afc1e92efb
                        Get.toNamed('/place-details', arguments: place);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
<<<<<<< HEAD
                                width: 120,
                                height: 100,
=======
                                width: 120, // Adjusted width
                                height: 100, // Adjusted height
>>>>>>> f4c16511503e607d031ff38cab2837afc1e92efb
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 1,
                                  ),
                                ),
<<<<<<< HEAD
                                child: place.imageUrl != null &&
=======

                                // 🖼️ CACHED IMAGE DISPLAY (Lazy Loading)
                                child:
                                    place.imageUrl != null &&
>>>>>>> f4c16511503e607d031ff38cab2837afc1e92efb
                                        place.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: CachedNetworkImage(
                                          imageUrl: place.imageUrl!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
<<<<<<< HEAD
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey.shade800,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<Color>(
=======
                                          placeholder: (context, url) => Container(
                                            color: Colors.grey.shade800,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
>>>>>>> f4c16511503e607d031ff38cab2837afc1e92efb
                                                  Colors.white54,
                                                ),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Center(
<<<<<<< HEAD
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 48,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey.shade800,
                                        child: const Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 48,
                                            color: Colors.white38,
                                          ),
                                        ),
=======
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 48,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey.shade800,
                                        child: const Center(
                                          // 📍 Placeholder while image loads
                                          child: Icon(
                                            Icons.image,
                                            size: 48,
                                            color: Colors.white38,
                                          ),
                                        ),
>>>>>>> f4c16511503e607d031ff38cab2837afc1e92efb
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
<<<<<<< HEAD
=======

                                    // DYNAMIC DESCRIPTION: Display the enriched description
>>>>>>> f4c16511503e607d031ff38cab2837afc1e92efb
                                    Text(
                                      place.description ??
                                          place.addressLine2 ??
                                          'No description available.',
<<<<<<< HEAD
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
=======
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

>>>>>>> f4c16511503e607d031ff38cab2837afc1e92efb
                                    const SizedBox(height: 6),
                                    if (place.country != null ||
                                        place.category != null)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 14,
<<<<<<< HEAD
                                            color:
                                                Theme.of(context).primaryColor,
=======
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
>>>>>>> f4c16511503e607d031ff38cab2837afc1e92efb
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            place.country ?? 'Egypt',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
<<<<<<< HEAD
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            Icons.category,
                                            size: 14,
                                            color:
                                                Theme.of(context).primaryColor,
=======
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
>>>>>>> f4c16511503e607d031ff38cab2837afc1e92efb
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            place.category ?? 'Place',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
<<<<<<< HEAD
                                                  color: Theme.of(context)
                                                      .primaryColor,
=======
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
>>>>>>> f4c16511503e607d031ff38cab2837afc1e92efb
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