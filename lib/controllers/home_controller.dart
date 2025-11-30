import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tour_guide/controllers/connection_controller.dart';
import 'package:tour_guide/services/Authservice.dart';

import '../models/place_model.dart';
import '../services/places_service.dart';
import '../services/wikipedia_image_service.dart';
import 'location_controller.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';

class HomeController extends GetxController {
  final searchController = TextEditingController();
  final RxBool hasSearchText = false.obs;

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
  final limit = 10;

  String? pendingPlaceId;
  String? pendingActionType;

  // 🚀 FIFO Queue for Lazy Loading Images
  final List<PlaceModel> _imageQueue = [];
  bool _isProcessingQueue = false;
  Timer? _searchDebounceTimer;

  // ✅ Add connection listener
  StreamSubscription? _connectionSubscription;

  final RxList<PlaceModel> allPlaces = <PlaceModel>[].obs;
  final  placeType =  [
    'All',
    'Museum',
    'Restaurant',
    'Park',
    'Nature preserve',
    'Mosque',
    'Church',
    'Castle',
    'Cafe',
    'Cinema',
    'Hospital',
    // 'Hotel',
  ];
  final selected = 0.obs;
  // ⭐⭐⭐ FIRST METHOD BELOW VARIABLES ⭐⭐⭐
  void filterPlacesByType() {
    final String selectedType = placeType[selected.value];

    // All → reset the original list
    if (selectedType == 'All') {
      places.value = allPlaces;
      return;
    }

    // Filter based on place.type
    places.value = allPlaces.where((place) {
      return (place.type ?? '').toLowerCase() ==
          selectedType.toLowerCase();
    }).toList();
  }




  Future<void> getlocation() async {
    try {
      // ✅ Check internet FIRST
      final connectionController = Get.find<ConnectionController>();
      final bool hasInternet = await connectionController.hasInternet();

      if (!hasInternet) {
        print('🌐 No internet connection - redirecting to offline page');
        errorMessage.value = '';
        isLoading.value = false;
        Get.offAllNamed('/offline-page');
        return;
      }

      isLoading.value = true;

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
      print('❌ Error getting location: $e');

      // On web, any location error should send the user to the offline page
      if (kIsWeb) {
        print('🌐 Web: location error - redirecting to offline page');
        errorMessage.value = '';
        isLoading.value = false;
        Get.offAllNamed('/offline-page');
        return;
      }

      // On mobile/native, still differentiate network vs other errors
      final connectionController = Get.find<ConnectionController>();
      final bool hasInternet = await connectionController.hasInternet();

      if (!hasInternet) {
        print('🌐 Network error detected - redirecting to offline page');
        errorMessage.value = '';
        isLoading.value = false;
        Get.offAllNamed('/offline-page');
      } else {
        errorMessage.value = e.toString();
        isLoading.value = false;
      }
    }
  }

  void startTimer() {
    Timer.periodic(50.seconds, (timer) async {
      print("⏰ Timer check triggered");

      try {
        // ✅ Check internet first in timer
        final connectionController = Get.find<ConnectionController>();
        final bool hasInternet = await connectionController.hasInternet();

        if (!hasInternet) {
          print('🌐 Timer: No internet - redirecting to offline page');
          Get.offAllNamed('/offline-page');
          return;
        }

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

        if (distance >= 200) {
          location = newLocation;
          await fetchPlaces(
            latitude: newLocation.latitude,
            longitude: newLocation.longitude,
          );
        }
      } catch (e) {
        print('❌ Error while updating location in timer: $e');

        final connectionController = Get.find<ConnectionController>();
        final bool hasInternet = await connectionController.hasInternet();

        if (!hasInternet) {
          Get.offAllNamed('/offline-page');
        }
      }
    });
  }

  @override
  void onInit() {
    super.onInit();

    // ✅ Listen to real-time connection changes
    _listenToConnectionChanges();

    // ✅ Check connection and initialize
    _checkConnectionAndInitialize();

    // ✅ Setup search listener with debounce
    searchController.addListener(_onSearchChanged);
    // ✅ Listen to text changes for clear button visibility
    searchController.addListener(_updateSearchText);
  }

  /// ✅ NEW: Listen to connection changes in real-time
  void _listenToConnectionChanges() {
    final connectionController = Get.find<ConnectionController>();

    // Listen to the isConnected observable
    ever(connectionController.isConnected, (bool isConnected) {
      print('🔄 Connection status changed: $isConnected');

      if (!isConnected) {
        print('❌ Lost connection - redirecting to offline page');
        // Only redirect if we're not already on offline page
        if (Get.currentRoute != '/offline-page') {
          Get.offAllNamed('/offline-page');
        }
      } else {
        print('✅ Connection restored');
        // Optionally reload data when connection is restored
        // You can add logic here if needed
      }
    });
  }

  /// ✅ Check connection before initializing
  Future<void> _checkConnectionAndInitialize() async {
    try {
      final connectionController = Get.find<ConnectionController>();

      // Wait a bit for the initial connection check to complete
      await Future.delayed(const Duration(milliseconds: 500));

      final bool hasInternet = await connectionController.hasInternet();

      if (!hasInternet) {
        print('🌐 onInit: No internet - redirecting to offline page');
        Get.offAllNamed('/offline-page');
        return;
      }

      // Only proceed if we have internet
      await getlocation();
      startTimer();
    } catch (e) {
      print('❌ Error in initialization: $e');
      final connectionController = Get.find<ConnectionController>();
      final bool hasInternet = await connectionController.hasInternet();

      if (!hasInternet) {
        Get.offAllNamed('/offline-page');
      }
    }
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    _connectionSubscription?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.removeListener(_updateSearchText);
    searchController.dispose();
    super.onClose();
  }

  /// 🔍 Handle search input changes with 350ms debounce
  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 350), () {
      final query = searchController.text.trim();
      if (query.isNotEmpty) {
        _performCustomSearch(query);
      }
    });
  }

  /// Update reactive variable for search text visibility
  void _updateSearchText() {
    hasSearchText.value = searchController.text.isNotEmpty;
  }

  /// 🔎 Perform custom search with user input
  Future<void> _performCustomSearch(String searchText) async {
    if (location == null) {
      print('⚠️ No location available for search');
      return;
    }

    try {
      // ✅ Check internet before search
      final connectionController = Get.find<ConnectionController>();
      final bool hasInternet = await connectionController.hasInternet();

      if (!hasInternet) {
        print('🌐 Search: No internet - redirecting to offline page');
        Get.offAllNamed('/offline-page');
        return;
      }

      isLoading.value = true;
      errorMessage.value = '';

      print('🔍 Searching for: "$searchText"');

      final List<PlaceModel> searchResults = await placesService.searchCustomTerm(
        searchText: searchText,
        longitude: location!.longitude,
        latitude: location!.latitude,
        limit: limit,
      );

      final List<PlaceModel> quickList = [];
      for (var place in searchResults) {
        if (place.name == null || place.name!.isEmpty) {
          continue;
        }
        final placeId = place.placeId ?? generateplaceid(place);
        quickList.add(place.copyWith(placeId: placeId));
      }

      places.value = quickList;
      allPlaces.value = quickList;
      print('✅ Found ${quickList.length} results for "$searchText"');

      _imageQueue.clear();
      _imageQueue.addAll(quickList);
      _processImageQueue();

    } catch (e) {
      print('❌ Search error: $e');

      final connectionController = Get.find<ConnectionController>();
      final bool hasInternet = await connectionController.hasInternet();

      if (!hasInternet) {
        Get.offAllNamed('/offline-page');
      } else {
        errorMessage.value = 'Search failed: $e';
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔄 Clear search and reload default places
  void clearSearch() {
    searchController.clear();
    hasSearchText.value = false;
    if (location != null) {
      fetchPlaces(
        longitude: location!.longitude,
        latitude: location!.latitude,
      );
    }
  }

  /// 🚀 Fetch places with lazy image loading (FIFO queue)
  Future<void> fetchPlaces({required double longitude, required double latitude,}) async {
    try {
      // ✅ Check internet FIRST
      final connectionController = Get.find<ConnectionController>();
      final bool hasInternet = await connectionController.hasInternet();

      if (!hasInternet) {
        isLoading.value = false;
        errorMessage.value = '';
        print('🌐 fetchPlaces: No internet - redirecting to offline page');
        Get.offAllNamed('/offline-page');
        return;
      }

      isLoading.value = true;
      errorMessage.value = '';

      final List<PlaceModel> basicList = await placesService.getPlaces(
        categories: categories,
        longitude: longitude,
        latitude: latitude,
        radius: radius,
        limit: limit,
      );

      final List<PlaceModel> quickList = [];
      for (var place in basicList) {
        if (place.name == null || place.name!.isEmpty) {
          print('⚠️ Skipping place with no name');
          continue;
        }

        final placeId = place.placeId ?? generateplaceid(place);
        final quickPlace = place.copyWith(placeId: placeId);
        quickList.add(quickPlace);
      }

      places.value = quickList;
      allPlaces.value = quickList;

      places.shuffle();

      print('✅ Showing ${quickList.length} places (images loading in background)');

      _imageQueue.clear();
      _imageQueue.addAll(quickList);
      _processImageQueue();

    } catch (e) {
      print('❌ Error fetching places: $e');

      // On web, treat any fetch error as network-related and go to offline page
      if (kIsWeb) {
        print('🌐 Web: error fetching places - redirecting to offline page');
        errorMessage.value = '';
        Get.offAllNamed('/offline-page');
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('connection') ||
          e.toString().contains('Network')) {
        print('🌐 Network error detected - redirecting to offline page');
        errorMessage.value = '';
        Get.offAllNamed('/offline-page');
      } else {
        errorMessage.value = 'Failed to load places: $e';
        Get.snackbar(
          'Error',
          'Failed to load places. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// 🎯 Process image queue in background (FIFO - First In First Out)
  void _processImageQueue() async {
    if (_isProcessingQueue) {
      print('⚠️ Queue already processing, skipping...');
      return;
    }

    _isProcessingQueue = true;
    print('🚀 Starting image queue processing (${_imageQueue.length} items)');

    while (_imageQueue.isNotEmpty) {
      final place = _imageQueue.removeAt(0);

      if (place.imageUrl != null && place.imageUrl!.isNotEmpty) {
        print('⏭️ Skipping ${place.name} - already has image');
        continue;
      }

      try {
        print('📸 Fetching image for: ${place.name}');
        await _fetchImageForPlace(place);
      } catch (e) {
        print('❌ Failed to fetch image for ${place.name}: $e');
      }

      await Future.delayed(const Duration(milliseconds: 250));
    }

    _isProcessingQueue = false;
    print('✅ Image queue processing complete');
  }

  /// 📸 Fetch image and description for a single place
  Future<void> _fetchImageForPlace(PlaceModel place) async {
    try {
      final String? queryId = place.wikidataId ?? place.name;

      if (queryId == null || queryId.isEmpty) {
        print('⚠️ No query ID for place');
        return;
      }

      final results = await Future.wait([
        wikiService.getBestImageUrl(queryId),
        // wikiService.getSummary(queryId),
      ]);

      final String? imageUrl = results[0];
      // final String? description = results[1];

      final index = places.indexWhere((p) => p.placeId == place.placeId);
      if (index != -1) {
        if (imageUrl != null && imageUrl.isNotEmpty) {
          final updatedPlace = places[index].copyWith(
            imageUrl: imageUrl,
            // description: description,
          );
          places[index] = updatedPlace;
          print('✅ Updated ${place.name} with image');
        }else{
          final updatedPlace = putCategoryImage(places[index]);
          places[index] = updatedPlace;
          print('✅ Updated ${place.name} with category image');
        }
      }
    } catch (e) {
      print('❌ Error fetching image for ${place.name}: $e');
    }
  }

  /// 🖼️ Add category image from assets based on place type
  PlaceModel putCategoryImage(PlaceModel place) {
    try {
      final String? placeType = place.type;
      
      print('🖼️ putCategoryImage called for: ${place.name}, type: $placeType');
      
      if (placeType == null || placeType.isEmpty) {
        print('⚠️ No type specified for place: ${place.name}');
        return place;
      }

      // Map place types to asset image paths
      final Map<String, String> typeToAssetMap = {
        'Museum': 'assets/categories_imgs/Museum.png',
        'Restaurant': 'assets/categories_imgs/resturant.png',
        'Park': 'assets/categories_imgs/park.jpg',
        'Nature preserve': 'assets/categories_imgs/Nature preserve.jpg',
        'Mosque': 'assets/categories_imgs/Mosque.jpg',
        'Church': 'assets/categories_imgs/Church.png',
        'Castle': 'assets/categories_imgs/Castle.png',
        'Cafe': 'assets/categories_imgs/cafe.png',
        'Cinema': 'assets/categories_imgs/cinema.png',
        'Hospital': 'assets/categories_imgs/hospital.jpg',
        // 'Hotel': 'assets/categories_imgs/Hotel-Cairo_four_se.jpg',
      };

      // Find matching asset path (case-insensitive)
      String? assetPath;
      for (var entry in typeToAssetMap.entries) {
        if (entry.key.toLowerCase() == placeType.toLowerCase()) {
          assetPath = entry.value;
          print('✅ Found asset path: $assetPath for type: $placeType');
          break;
        }
      }

      if (assetPath == null) {
        print('⚠️ No asset image found for type: $placeType (available types: ${typeToAssetMap.keys.join(", ")})');
        return place;
      }

      // Return updated place with asset image path
      final updatedPlace = place.copyWith(imageUrl: assetPath);
      print('✅ Updated place ${place.name} with asset image: $assetPath');
      return updatedPlace;
    } catch (e) {
      print('❌ Error setting category image for ${place.name}: $e');
      return place;
    }
  }

  /// 🔄 Manual image fetch for a specific place
  Future<void> fetchImageForPlaceImmediate(PlaceModel place) async {
    if (place.imageUrl != null && place.description != null) {
      return;
    }

    try {
      final String? queryId = place.wikidataId ?? place.name;
      if (queryId == null || queryId.isEmpty) return;

      final results = await Future.wait([
        wikiService.getBestImageUrl(queryId),
        wikiService.getSummary(queryId),
      ]);

      final String? imageUrl = results[0];
      final String? description = results[1];

      final index = places.indexWhere((p) => p.placeId == place.placeId);
      if (index != -1) {
        places[index] = places[index].copyWith(
          imageUrl: imageUrl,
          description: description,
        );
      }
    } catch (e) {
      print('❌ Error in immediate fetch: $e');
    }
  }

  String generateplaceid(PlaceModel place) {
    if (place.wikidataId != null && place.wikidataId!.isNotEmpty) {
      return place.wikidataId!;
    }
    return '${place.name}-${place.latitude}-${place.longitude}';
  }

  String getPlaceId(PlaceModel place) {
    return place.placeId ?? generateplaceid(place);
  }

  // ✅ Fetch favorites from Firebase
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

  Future<void> removeFromFavorites(PlaceModel place) async {
    try {
      print('➖ Removing from favorites: ${place.name}');

      final uid = authService.getCurrentUserId();
      if (uid == null) return;

      final placeId = getPlaceId(place);
      await userService.removeFromFavorites(uid, placeId);

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

  bool isFavorite(PlaceModel place) {
    final placeId = getPlaceId(place);
    return favoritePlaces.any((p) => getPlaceId(p) == placeId);
  }

  Future<PlaceModel> _parsePlaceFromId(String placeId) async {
    if (placeId.isEmpty) {
      throw Exception('Invalid placeId');
    }

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
      placeId: placeId,
    );
  }

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

      await userService.addToVisitListWithDateTime(uid, placeId, visitDateTime);
      print('✅ Added to Firebase');

      await notificationService.scheduleVisitReminderNotification(
        placeId: placeId,
        placeName: place.name ?? 'Unknown Place',
        visitDateTime: visitDateTime,
      );

      if (!visitListPlaces.any((p) => getPlaceId(p) == placeId)) {
        visitListPlaces.add(place);
        visitListItemsWithDates[placeId] = visitDateTime;
      } else {
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

  DateTime? getVisitDateTime(PlaceModel place) {
    final placeId = getPlaceId(place);
    return visitListItemsWithDates[placeId];
  }

  bool isInVisitList(PlaceModel place) {
    final placeId = getPlaceId(place);
    return visitListItemsWithDates.containsKey(placeId);
  }

  Future<void> removeFromVisitListWithDateTime(PlaceModel place) async {
    try {
      print('➖ Removing from visit list: ${place.name}');

      final uid = authService.getCurrentUserId();
      if (uid == null) return;

      final placeId = getPlaceId(place);

      await userService.removeFromVisitList(uid, placeId);
      await notificationService.cancelVisitReminderNotification(placeId);

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