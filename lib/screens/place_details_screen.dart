import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tour_guide/controllers/home_controller.dart';
import 'package:tour_guide/models/place_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetails extends StatefulWidget {

  const PlaceDetails({super.key});

  @override
  State<PlaceDetails> createState() => _PlaceDetailsState();
}

class _PlaceDetailsState extends State<PlaceDetails> {
  PlaceModel? place;
  
  @override
  void initState() {
    super.initState();
    // Handle both PlaceModel directly or from arguments map
    final args = Get.arguments;
    
    if (args is PlaceModel) {
      place = args;
    } else if (args is Map<String, dynamic> && args.containsKey('place')) {
      place = args['place'] as PlaceModel?;
    }
    
    // If no valid place found, this shouldn't happen as route handler checks for null
    // But we'll handle it gracefully just in case
    if (place == null) {
      // Redirect to home immediately
      Future.microtask(() {
        if (mounted) {
          Get.offAllNamed('/home');
        }
      });
      return;
    }
    
    // Check if we just returned from login and need to execute an action
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndExecutePendingAction();
      // 📸 Fetch image immediately if missing
      _fetchImageIfNeeded();
    });
  }

  /// 📸 Fetch image and description immediately if not available
  void _fetchImageIfNeeded() async {
    final currentPlace = place;
    if (currentPlace == null) return;
    
    if (currentPlace.imageUrl == null || currentPlace.description == null) {
      final homeController = Get.find<HomeController>();
      await homeController.fetchImageForPlaceImmediate(currentPlace);
      // Update local place reference
      if (mounted) {
        setState(() {
          place = homeController.places.firstWhereOrNull(
            (p) => p.placeId == currentPlace.placeId
          ) ?? currentPlace;
        });
      }
    }
  }

  void _checkAndExecutePendingAction() {
    // Check if there's a pending action from login
    final currentPlace = place;
    if (currentPlace == null) return;
    
    final homeController = Get.find<HomeController>();
    if (homeController.authService.isLoggedIn()) {
      // Check if we have a pending action stored
      if (homeController.pendingActionType != null && 
          homeController.pendingPlaceId != null) {
        final action = homeController.pendingActionType;
        final placeId = homeController.pendingPlaceId;
        
        // Verify this is the correct place
        final currentPlaceId = homeController.getPlaceId(currentPlace);
        if (placeId == currentPlaceId) {
          if (action == 'visitList') {
            // Show date/time picker for visit list
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                _showDateTimePicker(context, currentPlace);
              }
            });
          } else if (action == 'favorite') {
            // Add to favorites automatically
            homeController.addToFavorites(currentPlace);
          }
          
          // Clear pending action
          homeController.pendingActionType = null;
          homeController.pendingPlaceId = null;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If place is null, show loading/error state
    if (place == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('placeDetails'.tr),
        leading:IconButton(  
              icon: const Icon(Icons.home),
              tooltip: 'home'.tr,         
           onPressed: () => Get.offAllNamed('/home'),
        

            ),
        ),
        
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Details'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'home'.tr,
          onPressed: () => Get.offAllNamed('/home'),
        ),
     ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🖼️ Image Section (Cached)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: place!.imageUrl != null && place!.imageUrl!.isNotEmpty
                    ? (place!.imageUrl!.startsWith('assets/')
                        ? Image.asset(
                            place!.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('❌ Error loading asset image in details: ${place!.imageUrl}');
                              print('Error: $error');
                              return Container(
                                height: 200,
                                color: Colors.grey.shade600,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.broken_image,
                                        size: 48,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Asset not found',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : CachedNetworkImage(
                            imageUrl: place!.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 200,
                              color: Colors.grey.shade700,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 200,
                              color: Colors.grey.shade600,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ))
                    : Container(
                        height: 200,
                        color: Theme.of(context).cardColor,
                        child: Center(
                          child: Text(
                            'Image Not Found for ${place!.name}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
              ),

              // Details Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      place!.name ?? 'Unknown Place',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      place!.description ??
                          place!.addressLine2 ??
                          'Detailed description not available.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // Additional Information Container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (place!.country != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Country: ${place!.country}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          if (place!.category != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.category,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Category: ${place!.category}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                          if (place!.latitude != null && place!.longitude != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.my_location,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Coordinates: ${place!.latitude!.toStringAsFixed(4)}, ${place!.longitude!.toStringAsFixed(4)}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Location:',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            place!.addressLine2 ?? 'Address not listed.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ✅ Add to Favorite Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final homeController = Get.find<HomeController>();
                          if (homeController.authService.isLoggedIn()) {
                            await homeController.addToFavorites(place!);
                          } else {
                            Get.snackbar(
                              'loginRequired'.tr,
                              'pleaseLoginToAddToFavorites'.tr,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            // Store return route with place as argument
                            Get.toNamed('/login', arguments: {
                              'returnRoute': '/place-details',
                              'place': place!,
                              'action': 'favorite',
                            });
                          }
                        },
                        icon: const Icon(Icons.favorite_border),
                        label: Text("addToFavorite".tr),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // ✅ Add to Visit List Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final homeController = Get.find<HomeController>();
                          if (!homeController.authService.isLoggedIn()) {
                            Get.snackbar(
                              'loginRequired'.tr,
                              'pleaseLoginToAddToVisitList'.tr,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            // Store return route with place as argument
                            Get.toNamed('/login', arguments: {
                              'returnRoute': '/place-details',
                              'place': place!,
                              'action': 'visitList',
                            });
                            return;
                          }
                          await _showDateTimePicker(context, place!);
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text("addToVisitList".tr),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Open Google Map Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final url = Uri.parse('geo:0,0?q=${place!.latitude},${place!.longitude}');
                          launchUrl(url);
                        },
                        icon: const Icon(Icons.map),
                        label: Text("openGoogleMap".tr),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDateTimePicker(BuildContext context, PlaceModel place) async {
    final theme = Theme.of(context);
    
    // Pick date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Visit Date',
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.primaryColor,
              onPrimary: theme.colorScheme.onSurface,
              surface: theme.cardColor,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return; // User cancelled date picker

    // Pick time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select Visit Time',
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.primaryColor,
              onPrimary: theme.colorScheme.onSurface,
              surface: theme.cardColor,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return; // User cancelled time picker

    // Combine date and time
    final DateTime visitDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // Add to visit list
    final homeController = Get.find<HomeController>();
    await homeController.addToVisitListWithDateTime(place, visitDateTime);
  }
}