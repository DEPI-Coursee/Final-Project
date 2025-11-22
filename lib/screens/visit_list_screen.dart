import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/controllers/home_controller.dart';
import 'package:tour_guide/models/place_model.dart';
import 'package:tour_guide/screens/place_details_screen.dart';

class VisitListScreen extends StatefulWidget {
  const VisitListScreen({super.key});

  @override
  State<VisitListScreen> createState() => _VisitListScreenState();
}

class _VisitListScreenState extends State<VisitListScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh visit list when screen opens
    final controller = Get.find<HomeController>();
    controller.fetchVisitListPlaces();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        // title: const Text("Visit List"),
        // centerTitle: true,
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
        child: Obx(() {
          if (controller.isVisitListLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.visitListPlaces.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list_alt,
                    size: 64,
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your visit list is empty',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add places to your visit list to see them here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Row(
                    children: [
                      Icon(
                        Icons.list_alt,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Visit List',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Plan your next adventures and track your travel goals',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Caveat',
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Cards container
                  Container(
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
                      itemCount: controller.visitListPlaces.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        final place = controller.visitListPlaces[index];
                        final visitDateTime = controller.getVisitDateTime(place);
                        return _buildCard(context, place, visitDateTime, controller);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCard(BuildContext context, PlaceModel place, DateTime? visitDateTime, HomeController controller) {
    String formatDate(DateTime date) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }

    String formatTime(DateTime date) {
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final amPm = date.hour < 12 ? 'AM' : 'PM';
      return '$hour:$minute $amPm';
    }
    
    return Card(
      color: Theme.of(context).cardColor,
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 45,
            child: place.imageUrl != null && place.imageUrl!.isNotEmpty
                ? Image.network(
                    place.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 24, color: Colors.white70),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 24, color: Colors.grey),
                    ),
                  ),
          ),
          Expanded(
            flex: 55,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name ?? 'Unknown Place',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            if (place.addressLine2 != null)
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 8, color: Colors.grey),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      place.addressLine2!,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 8,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (visitDateTime != null) ...[
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 8, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            formatDate(visitDateTime),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 8, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            formatTime(visitDateTime),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 8,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 7,
                            ),
                          ),
                          Text(
                            visitDateTime != null && visitDateTime.isAfter(DateTime.now())
                                ? 'Upcoming'
                                : 'Past',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: visitDateTime != null && visitDateTime.isAfter(DateTime.now())
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Get.toNamed('/place-details', arguments: place);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              'Details',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await controller.removeFromVisitListWithDateTime(place);
                            },
                            icon: Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Colors.red.shade300,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                            tooltip: 'Remove from visit list',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
