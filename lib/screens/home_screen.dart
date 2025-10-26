import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/screens/place_details_screen.dart';
import 'package:tour_guide/screens/favorits_screen.dart';
import 'package:tour_guide/screens/visit_list_screen.dart';
// import 'package:tour_guide/services/AuthService.dart';
import 'package:tour_guide/services/places_service.dart';
import 'package:tour_guide/models/place_model.dart';
import 'package:tour_guide/services/wikipedia_image_service.dart';
// import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();

  final WikipediaImageService wikiService = WikipediaImageService();

  // final authService = Authservice();
  final placesService = PlacesService();

  // Observable variables
  final RxList<PlaceModel> places = <PlaceModel>[].obs;

  final RxBool isLoading = false.obs;

  final RxString errorMessage = ''.obs;

  // API parameters (configurable)
  final categories = 'tourism.attraction';

  final longitude = 31.2357;

  final latitude = 30.0444;

  final radius = 10000.0;

  final limit = 20;

  // Fetch places from API
  Future<void> fetchPlaces() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final List<PlaceModel> basicList = await placesService.getPlaces(
        categories: categories,
        longitude: longitude,
        latitude: latitude,
        radius: radius,
        limit: limit,
      );

      final List<PlaceModel> enrichedList = [];

      for (var place in basicList) {
        // Only proceed if we have a name to search Wikipedia with
        if (place.name != null && place.name!.isNotEmpty) {
          // Fetch image and description concurrently (saves time)
          final results = await Future.wait([
            wikiService.getBestImageUrl(place.name!),
            wikiService.getSummary(place.name!),
          ]);

          final String? imageUrl = results[0];
          final String? description = results[1];

          print("DEBUG_TOURI: ${place.name} -> URL: $imageUrl");

          final enrichedPlace = place.copyWith(
            imageUrl: imageUrl,
            description: description,
          );

          enrichedList.add(enrichedPlace);
        } else {
          // If no name, add the basic place model as is
          enrichedList.add(place);
        }
      }

      places.value = enrichedList;

      // final result = await placesService.getPlaces(
      //   categories: categories,
      //   longitude: longitude,
      //   latitude: latitude,
      //   radius: radius,
      //   limit: limit,
      // );

      // places.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Call fetchPlaces once the screen is initialized
    fetchPlaces();
  }

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
            // ListTile(
            //   leading: const Icon(Icons.logout, color: Colors.grey),
            //   title: const Text('Logout'),
            //   onTap: () async {
            //     final success = await authService.signOut();
            //     if (success) {
            //       Get.offAll(() => LoginScreen());
            //     } else {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //           content: Text('Logout failed. Try again.'),
            //         ),
            //       );
            //     }
            //   },
            // ),
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
                    controller: searchController,
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
                if (isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show error message
                if (errorMessage.value.isNotEmpty) {
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
                          errorMessage.value,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchPlaces,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Show empty state
                if (places.isEmpty) {
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
                          onPressed: fetchPlaces,
                          child: const Text('Load Places'),
                        ),
                      ],
                    ),
                  );
                }

                // Show places list
                return ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (ctx, index) {
                    final place = places[index];
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
