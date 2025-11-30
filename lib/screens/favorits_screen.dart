import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../models/place_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh favorites when screen opens
    final controller = Get.find<HomeController>();
    controller.fetchFavoritePlaces();
  }
  @override
  Widget build(BuildContext context) {
    // ✅ Just Get.find since it's in AppBinding
    final homeController = Get.find<HomeController>();

    // ✅ Ensure favorites are fetched when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (homeController.authService.isLoggedIn()) {
        print('📱 FavoritesScreen: Triggering fetchFavoritePlaces');
        homeController.fetchFavoritePlaces();
      } else {
        print('⚠️ FavoritesScreen: User not logged in');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('🔄 Manual refresh triggered');
              homeController.fetchFavoritePlaces();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your Favorite Places',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Discover and manage your saved destinations',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Caveat',
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 20),

              // Cards container with Obx
              Obx(() {
                print('🖼️ UI Update - Loading: ${homeController.isFavoritesLoading.value}, Favorites: ${homeController.favoritePlaces.length}, Error: ${homeController.errorMessage.value}');

                if (homeController.isFavoritesLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading your favorites...'),
                        ],
                      ),
                    ),
                  );
                }

                if (homeController.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            homeController.errorMessage.value,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => homeController.fetchFavoritePlaces(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (homeController.favoritePlaces.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Theme.of(context).primaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No favorites yet',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start adding places to your favorites!',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => Get.toNamed('/home'),
                            icon: const Icon(Icons.explore),
                            label: const Text('Explore Places'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                print('✅ Rendering ${homeController.favoritePlaces.length} favorite places');

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: homeController.favoritePlaces.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      final place = homeController.favoritePlaces[index];
                      return DestinationCard(
                        place: place,
                        onRemove: () => homeController.removeFromFavorites(place),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onRemove;

  const DestinationCard({
    super.key,
    required this.place,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed('/place-details', arguments: place);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: place.imageUrl != null && place.imageUrl!.isNotEmpty
                  ? (place.imageUrl!.startsWith('assets/')
                      ? Image.asset(
                          place.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.broken_image,
                              size: 32,
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : Image.network(
                          place.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.broken_image,
                              size: 32,
                              color: Colors.white54,
                            ),
                          ),
                        ))
                  : Container(
                      color: Colors.grey.shade800,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.place,
                            size: 32,
                            color: Colors.white54,
                          ),
                        ],
                      ),
                    ),
            ),
            // Title and Remove Button
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        place.name ?? 'Unknown Place',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          color: Colors.red.shade400,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Get.defaultDialog(
                              title: 'Remove Favorite',
                              middleText: 'Remove "${place.name}" from favorites?',
                              textConfirm: 'Remove',
                              textCancel: 'Cancel',
                              confirmTextColor: Colors.white,
                              buttonColor: Colors.red,
                              cancelTextColor: Theme.of(context).primaryColor,
                              onConfirm: () {
                                onRemove();
                                Get.back();
                              },
                            );
                          },
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
  }
}