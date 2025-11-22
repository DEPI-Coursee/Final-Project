import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tour_guide/services/Authservice.dart';

import '../models/place_model.dart';
import '../services/places_service.dart';
import '../services/wikipedia_image_service.dart';
import 'location_controller.dart';
import '../services/user_service.dart';

class HomeController extends GetxController {
  final searchController = TextEditingController();

  final WikipediaImageService wikiService = WikipediaImageService();
  final LocationController locationController = Get.find<LocationController>();

  final authService = Get.find<Authservice>();
  final placesService = PlacesService();
  final userService = Get.find<UserService>();

  late List<PlaceModel> myplaces;
  Position? location;

  final RxList<PlaceModel> favoritePlaces = <PlaceModel>[].obs;
  final RxBool isFavoritesLoading = false.obs;

  final RxList<PlaceModel> visitListPlaces = <PlaceModel>[].obs;
  final RxBool isVisitListLoading = false.obs;

  // Observable variables
  final RxList<PlaceModel> places = <PlaceModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // API parameters (configurable)
  final categories = 'tourism.attraction';
  final radius = 10000.0;
  final limit = 20;

  String? pendingPlaceId;
  String? pendingActionType;

  Future<void> getlocation() async {
    try {
      final currentLocation = await locationController.determinePosition();
      location = currentLocation;
      await fetchPlaces(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      );
      print(
      "📍 Current device location: ${location.latitude}, ${location.longitude}",
    );
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error getting location: $e');
    }
  }

  void startTimer() {
    Timer.periodic(50.seconds, (timer) async {
      print("hello");
      try {
        final currentLocation = location;
        final newLocation = await locationController.determinePosition();

        if (currentLocation == null) {
          location = newLocation;
          await fetchPlaces(
            latitude: newLocation.latitude,
            longitude: newLocation.longitude,
          );
          return;
        }

        final distance = locationController.calculateDistance(
          currentLocation.latitude, 
          currentLocation.longitude, 
          newLocation.latitude, 
          newLocation.longitude,
        );
        if(distance >= 200){
          location = newLocation;
          await fetchPlaces(
            latitude: newLocation.latitude,
            longitude: newLocation.longitude,
          );
        }
      } catch (e) {
        print('Error while updating location in timer: $e');
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    getlocation();
    startTimer();

    // ✅ Load favorites when controller initializes
    if (authService.isLoggedIn()) {
      fetchFavoritePlaces();
    }
  }

  Future<void> fetchPlaces({
    required double longitude,
    required double latitude,
  }) async {
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
        final String? queryId = place.wikidataId ?? place.name;

        if (queryId == null || queryId.isEmpty) {
          print('⚠️ Skipping place with no name or Wikidata ID');
          continue; // Skip this place safely
        }

        try {
          final results = await Future.wait([
            wikiService.getBestImageUrl(queryId),
            wikiService.getSummary(queryId),
          ]);

          final String? imageUrl = results[0];
          final String? description = results[1];

          final enrichedPlace = place.copyWith(
            imageUrl: imageUrl,
            description: description,
          );

          enrichedList.add(enrichedPlace);
          print("✅ Loaded place: ${place.name ?? place.wikidataId}");
        } catch (e) {
          print(
            '❌ Failed to enrich place: ${place.name ?? place.wikidataId}, error: $e',
          );
          enrichedList.add(place); // Add at least the basic place
        }
      }

      places.value = enrichedList;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  String generateplaceid(PlaceModel place) {
    if (place.wikidataId != null && place.wikidataId!.isNotEmpty) {
      return place.wikidataId!;
    }
    return '${place.name}-${place.latitude}-${place.longitude}';
  }

  // ✅ FIXED: Fetch favorites from Firebase
  Future<void> fetchFavoritePlaces() async {
    try {
      isFavoritesLoading.value = true;
      errorMessage.value = '';

      print('🔍 Starting fetchFavoritePlaces...');

      final uid = authService.getCurrentUserId();
      if (uid == null) {
        print('❌ No user logged in');
        errorMessage.value = 'Please login to view favorites';
        isFavoritesLoading.value = false;
        return;
      }

      print('✅ User ID: $uid');

      final user = await userService.getUser(uid);

      if (user == null) {
        print('❌ User data not found');
        favoritePlaces.value = [];
        isFavoritesLoading.value = false;
        return;
      }

      print('✅ User data loaded');
      print('📋 Favorite place IDs: ${user.favoritePlaces}');

      if (user.favoritePlaces == null || user.favoritePlaces!.isEmpty) {
        print('ℹ️ No favorite places found');
        favoritePlaces.value = [];
        isFavoritesLoading.value = false;
        return;
      }

      final List<PlaceModel> loadedPlaces = [];

      for (String placeId in user.favoritePlaces!) {
        print('🔄 Parsing place: $placeId');
        PlaceModel place = await _parsePlaceFromId(placeId);
        loadedPlaces.add(place);
        print('✅ Place parsed: ${place.name}');
      }

      favoritePlaces.value = loadedPlaces;
      print('🎉 Loaded ${loadedPlaces.length} favorite places');
    } catch (e) {
      errorMessage.value = 'Error loading favorites: $e';
      print('❌ Error in fetchFavoritePlaces: $e');
    } finally {
      isFavoritesLoading.value = false;
    }
  }

  // ✅ FIXED: Add to favorites (was calling itself before!)
  Future<void> addToFavorites(PlaceModel place) async {
    try {
      print('➕ Adding to favorites: ${place.name}');

      final uid = authService.getCurrentUserId();
      if (uid == null) {
        print('❌ User not logged in');
        Get.snackbar('Login Required', 'Please login to add favorites');
        Get.toNamed('/login');
        return;
      }

      final placeId = generateplaceid(place);
      print('📝 Generated place ID: $placeId');

      await userService.addToFavorites(uid, placeId);
      print('✅ Added to Firebase');

      // Refresh favorites list to show the new addition
      await fetchFavoritePlaces();

      Get.snackbar(
        'Success',
        'Added "${place.name}" to favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ Error adding to favorites: $e');
      Get.snackbar(
        'Error',
        'Failed to add to favorites: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ✅ Remove from favorites
  Future<void> removeFromFavorites(PlaceModel place) async {
    try {
      print('➖ Removing from favorites: ${place.name}');

      final uid = authService.getCurrentUserId();
      if (uid == null) return;

      final placeId = generateplaceid(place);
      await userService.removeFromFavorites(uid, placeId);

      // Remove from local list immediately for better UX
      favoritePlaces.removeWhere((p) => generateplaceid(p) == placeId);

      print('✅ Removed from favorites');

      Get.snackbar(
        'Removed',
        'Place removed from favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ Error removing from favorites: $e');
      Get.snackbar(
        'Error',
        'Failed to remove from favorites: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ✅ Check if place is in favorites
  bool isFavorite(PlaceModel place) {
    final placeId = generateplaceid(place);
    return favoritePlaces.any((p) => generateplaceid(p) == placeId);
  }

  // ✅ Parse PlaceModel from stored placeId
  Future<PlaceModel> _parsePlaceFromId(String placeId) async {
    if (placeId.isEmpty) {
      throw Exception('Invalid placeId');
    }

    // Check if it's a custom format: "name-lat-lng"
    if (placeId.contains('-') && placeId.split('-').length >= 3) {
      final parts = placeId.split('-');
      final lastPart = parts.last;
      final secondLastPart = parts[parts.length - 2];

      final lng = double.tryParse(lastPart);
      final lat = double.tryParse(secondLastPart);

      if (lat != null && lng != null) {
        final name = parts.sublist(0, parts.length - 2).join('-');
        print('📍 Parsed as coordinates: $name ($lat, $lng)');

        String? imageUrl;
        String? description;
        try {
          imageUrl = await wikiService.getBestImageUrl(name);
          description = await wikiService.getSummary(name);
        } catch (_) {}

        return PlaceModel(
          name: name,
          latitude: lat,
          longitude: lng,
          imageUrl: imageUrl,
          description: description,
        );
      }
    }

    // Wikidata ID fallback
    print('🆔 Parsed as Wikidata ID: $placeId');

    String? imageUrl;
    String? description;
    try {
      imageUrl = await wikiService.getBestImageUrl(placeId);
      description = await wikiService.getSummary(placeId);
    } catch (_) {}

    return PlaceModel(
      name: placeId,
      wikidataId: placeId,
      imageUrl: imageUrl,
      description: description,
    );
  }
}
