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
import '../services/notification_service.dart';

class HomeController extends GetxController {
  final searchController = TextEditingController();

  final WikipediaImageService wikiService = WikipediaImageService();
  final LocationController locationController = Get.find<LocationController>();

  final authService = Get.find<Authservice>();
  final placesService = PlacesService();
  final userService = Get.find<UserService>();
  final notificationService = NotificationService();

  late List<PlaceModel> myplaces;
  Position? location;

  final RxList<PlaceModel> favoritePlaces = <PlaceModel>[].obs;
  final RxBool isFavoritesLoading = false.obs;

  final RxList<PlaceModel> visitListPlaces = <PlaceModel>[].obs;
  final RxMap<String, DateTime> visitListItemsWithDates = <String, DateTime>{}.obs;
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
      "📍 Current device location: ${currentLocation.latitude}, ${currentLocation.longitude}",
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

    // ✅ Load favorites and visit list when controller initializes
    // if (authService.isLoggedIn()) {
    //   fetchFavoritePlaces();
    //   fetchVisitListPlaces();
    // }
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

          // Generate placeId once and store it
          final placeId = place.placeId ?? generateplaceid(place);
          
          final enrichedPlace = place.copyWith(
            imageUrl: imageUrl,
            description: description,
            placeId: placeId,
          );

          enrichedList.add(enrichedPlace);
          print("✅ Loaded place: ${place.name ?? place.wikidataId}");
        } catch (e) {
          print(
            '❌ Failed to enrich place: ${place.name ?? place.wikidataId}, error: $e',
          );
          // Generate placeId for basic place too
          final placeId = place.placeId ?? generateplaceid(place);
          enrichedList.add(place.copyWith(placeId: placeId)); // Add at least the basic place
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

  // Generate placeId - used when placeId is not already set
  String generateplaceid(PlaceModel place) {
    if (place.wikidataId != null && place.wikidataId!.isNotEmpty) {
      return place.wikidataId!;
    }
    return '${place.name}-${place.latitude}-${place.longitude}';
  }

  // Get placeId from place, generate if not set
  String getPlaceId(PlaceModel place) {
    return place.placeId ?? generateplaceid(place);
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

      final placeId = getPlaceId(place);
      print('📝 Using place ID: $placeId');

      await userService.addToFavorites(uid, placeId);
      print('✅ Added to Firebase');

      // Update local list immediately instead of re-fetching
      if (!favoritePlaces.any((p) => getPlaceId(p) == placeId)) {
        favoritePlaces.add(place);
      }

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

      final placeId = getPlaceId(place);
      await userService.removeFromFavorites(uid, placeId);

      // Remove from local list immediately for better UX
      favoritePlaces.removeWhere((p) => getPlaceId(p) == placeId);

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
    final placeId = getPlaceId(place);
    return favoritePlaces.any((p) => getPlaceId(p) == placeId);
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

        // Generate placeId for parsed place
        final placeId = '$name-$lat-$lng';
        
        return PlaceModel(
          name: name,
          latitude: lat,
          longitude: lng,
          imageUrl: imageUrl,
          description: description,
          placeId: placeId,
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
      placeId: placeId, // Use wikidataId as placeId
    );
  }

  // ✅ Add place to visit list with date/time and schedule notification
  Future<void> addToVisitListWithDateTime(PlaceModel place, DateTime visitDateTime) async {
    try {
      print('➕ Adding to visit list: ${place.name} at $visitDateTime');

      final uid = authService.getCurrentUserId();
      if (uid == null) {
        print('❌ User not logged in');
        Get.snackbar('Login Required', 'Please login to add to visit list');
        Get.toNamed('/login');
        return;
      }

      final placeId = getPlaceId(place);
      print('📝 Using place ID: $placeId');

      // Add to visit list in Firebase
      await userService.addToVisitListWithDateTime(uid, placeId, visitDateTime);
      print('✅ Added to Firebase');

      // Schedule notification 30 minutes before visit time
      await notificationService.scheduleVisitReminderNotification(
        placeId: placeId,
        placeName: place.name ?? 'Unknown Place',
        visitDateTime: visitDateTime,
      );

      // Update local list immediately instead of re-fetching
      if (!visitListPlaces.any((p) => getPlaceId(p) == placeId)) {
        visitListPlaces.add(place);
        visitListItemsWithDates[placeId] = visitDateTime;
      } else {
        // Update existing entry
        visitListItemsWithDates[placeId] = visitDateTime;
      }

      Get.snackbar(
        'Success',
        'Added "${place.name}" to visit list\nNotification scheduled for 30 minutes before visit',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('❌ Error adding to visit list: $e');
      Get.snackbar(
        'Error',
        'Failed to add to visit list: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ✅ Fetch visit list places from Firebase
  Future<void> fetchVisitListPlaces() async {
    try {
      isVisitListLoading.value = true;
      errorMessage.value = '';

      print('🔍 Starting fetchVisitListPlaces...');

      final uid = authService.getCurrentUserId();
      if (uid == null) {
        print('❌ No user logged in');
        errorMessage.value = 'Please login to view visit list';
        visitListPlaces.value = [];
        visitListItemsWithDates.value = {};
        isVisitListLoading.value = false;
        return;
      }

      print('✅ User ID: $uid');

      final user = await userService.getUser(uid);

      if (user == null) {
        print('❌ User data not found');
        visitListPlaces.value = [];
        visitListItemsWithDates.value = {};
        isVisitListLoading.value = false;
        return;
      }

      print('✅ User data loaded');
      print('📋 Visit list items: ${user.visitListItems}');

      if (user.visitListItems == null || user.visitListItems!.isEmpty) {
        print('ℹ️ No visit list items found');
        visitListPlaces.value = [];
        visitListItemsWithDates.value = {};
        isVisitListLoading.value = false;
        return;
      }

      final List<PlaceModel> loadedPlaces = [];
      final Map<String, DateTime> datesMap = {};

      for (var entry in user.visitListItems!.entries) {
        final placeId = entry.key;
        final visitDateTime = entry.value;
        
        print('🔄 Parsing place: $placeId');
        PlaceModel place = await _parsePlaceFromId(placeId);
        loadedPlaces.add(place);
        datesMap[placeId] = visitDateTime;
        print('✅ Place parsed: ${place.name}');
      }

      visitListPlaces.value = loadedPlaces;
      visitListItemsWithDates.value = datesMap;
      print('🎉 Loaded ${loadedPlaces.length} visit list places');
    } catch (e) {
      errorMessage.value = 'Error loading visit list: $e';
      print('❌ Error in fetchVisitListPlaces: $e');
    } finally {
      isVisitListLoading.value = false;
    }
  }

  // ✅ Get visit date/time for a place
  DateTime? getVisitDateTime(PlaceModel place) {
    final placeId = getPlaceId(place);
    return visitListItemsWithDates[placeId];
  }

  // ✅ Check if place is in visit list
  bool isInVisitList(PlaceModel place) {
    final placeId = getPlaceId(place);
    return visitListItemsWithDates.containsKey(placeId);
  }

  // ✅ Remove place from visit list and cancel notification
  Future<void> removeFromVisitListWithDateTime(PlaceModel place) async {
    try {
      print('➖ Removing from visit list: ${place.name}');

      final uid = authService.getCurrentUserId();
      if (uid == null) return;

      final placeId = getPlaceId(place);
      
      // Remove from Firebase
      await userService.removeFromVisitList(uid, placeId);
      
      // Cancel scheduled notification
      await notificationService.cancelVisitReminderNotification(placeId);

      // Update local list immediately instead of re-fetching
      visitListPlaces.removeWhere((p) => getPlaceId(p) == placeId);
      visitListItemsWithDates.remove(placeId);

      print('✅ Removed from visit list');

      Get.snackbar(
        'Removed',
        'Place removed from visit list',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ Error removing from visit list: $e');
      Get.snackbar(
        'Error',
        'Failed to remove from visit list: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
