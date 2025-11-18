import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../models/place_model.dart';
import '../services/AuthService.dart';
import '../services/places_service.dart';
import '../services/wikipedia_image_service.dart';
import 'location_controller.dart';

class HomeController extends GetxController{
  final searchController = TextEditingController();

  final WikipediaImageService wikiService = WikipediaImageService();
  final LocationController locationController = Get.find<LocationController>();

  final authService = Authservice();
  final placesService = PlacesService();

  late List<PlaceModel> myplaces;
  late Position location;

  // Observable variables
  final RxList<PlaceModel> places = <PlaceModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // API parameters (configurable)
  final categories = 'tourism.attraction'; //???
  final radius = 10000.0;
  final limit = 20;

  Future<void> getlocation() async {
    location = await locationController.determinePosition();
    fetchPlaces(latitude: location.latitude, longitude: location.longitude);
  }
  
  void startTimer(){
    Timer.periodic(50.seconds, (timer) async {
      print("hello");
      final newLocation = await locationController.determinePosition();
      final distance = locationController.calculateDistance(
        location.latitude, 
        location.longitude, 
        newLocation.latitude, 
        newLocation.longitude,
      );
      if(distance >= 200){
        getlocation();
      }
    });
  }
  @override
  void onInit() {
    super.onInit();
    // getlocation();///////

    startTimer();
    // Call fetchPlaces once the screen is initialized
  }

  //Fetch places from API
  Future<void> fetchPlaces({required double longitude,required double latitude}) async {
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

          enrichedList.add(enrichedPlace);//place with image and description
        } else {
          // If no name, add the basic place model as is
          // enrichedList.add(place);(lw mlosh esm msh 3ayzeno)
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



}
