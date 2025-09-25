import 'package:flutter/material.dart';
import 'models/place.dart';

void main() {
  runApp(const TravelApp());
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visit List Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: const Color(0xFFFFD700),
        scaffoldBackgroundColor: const Color(0xFFFFF8DC),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFFDAA520),
          surface: Color(0xFFFFFAF0),
          onPrimary: Color(0xFF2D2D2D),
          onSecondary: Color(0xFF2D2D2D),
          onSurface: Color(0xFF2D2D2D),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF5A5A5A)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF5A5A5A)),
        ),
      ),
      home: const VisitListPage(),
    );
  }
}

class VisitListPage extends StatefulWidget {
  const VisitListPage({super.key});

  @override
  State<VisitListPage> createState() => _VisitListPageState();
}

class _VisitListPageState extends State<VisitListPage> {
  final List<Place> _visitList = [
    Place(
      id: '1',
      name: 'Giza Pyramids',
      location: 'Cairo, Egypt',
      description:
          'The magnificent ancient pyramids and Great Sphinx, one of the Seven Wonders of the Ancient World.',
      imageUrl:
          'https://images.unsplash.com/photo-1539650116574-75c0c6d68963?w=400',
      rating: 4.8,
      price: '\$225',
      tags: ['Historical', 'Ancient', 'UNESCO'],
      plannedDate: DateTime.now().add(const Duration(days: 15)),
    ),
    Place(
      id: '2',
      name: 'Karnak Temple Complex',
      location: 'Luxor, Egypt',
      description:
          'A vast mix of decayed temples, chapels, pylons, and other buildings in Egypt.',
      imageUrl:
          'https://images.unsplash.com/photo-1574354076090-5afe8fd0d0d0?w=400',
      rating: 4.7,
      price: '\$185',
      tags: ['Temple', 'Historical', 'Sacred'],
      plannedDate: DateTime.now().add(const Duration(days: 18)),
    ),
    Place(
      id: '3',
      name: 'Blue Hole',
      location: 'Dahab, Egypt',
      description:
          'A submarine sinkhole famous for recreational diving. Crystal clear waters and coral reefs.',
      imageUrl:
          'https://images.unsplash.com/photo-1583212292454-1fe6229603b7?w=400',
      rating: 4.6,
      price: '\$95',
      tags: ['Diving', 'Nature', 'Adventure'],
      plannedDate: DateTime.now().add(const Duration(days: 22)),
    ),
    Place(
      id: '4',
      name: 'Valley of the Kings',
      location: 'Luxor, Egypt',
      description:
          'Ancient burial ground of pharaohs with magnificent tombs and hieroglyphics.',
      imageUrl:
          'https://images.unsplash.com/photo-1548013146-72479768bada?w=400',
      rating: 4.9,
      price: '\$165',
      tags: ['Tombs', 'Pharaohs', 'Ancient'],
      plannedDate: DateTime.now().add(const Duration(days: 25)),
    ),
    Place(
      id: '5',
      name: 'White Desert',
      location: 'Farafra, Egypt',
      description:
          'Surreal white rock formations created by sandstorms, perfect for camping.',
      imageUrl:
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      rating: 4.5,
      price: '\$120',
      tags: ['Desert', 'Camping', 'Nature'],
      plannedDate: DateTime.now().add(const Duration(days: 30)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFF8DC),
        title: Text(
          'Visit List',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D2D2D)),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Color(0xFF2D2D2D)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFFFFFAF0),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[400], size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Search destinations...',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          // Stats Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('${_visitList.length}', 'Places'),
                _buildStatItem(
                  '${_visitList.where((p) => p.isVisited).length}',
                  'Visited',
                ),
                _buildStatItem(
                  '${_visitList.where((p) => !p.isVisited).length}',
                  'Planned',
                ),
              ],
            ),
          ),

          // List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Places',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '${_visitList.length} places',
                    style: const TextStyle(
                      color: Color(0xFFDAA520),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Places List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _visitList.length,
              itemBuilder: (context, index) {
                final place = _visitList[index];
                return _buildPlaceCard(place, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceCard(Place place, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Color(0xFFFFFAF0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.7),
                    const Color(0xFFDAA520).withOpacity(0.9),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Placeholder for image
                  Center(
                    child: Icon(
                      Icons.landscape,
                      size: 50,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  // Rating Badge
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFD700),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.rating.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                    ),
                    Text(
                      place.price,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDAA520),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xFF5A5A5A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      place.location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5A5A5A),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  place.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5A5A5A),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 15),

                // Tags
                Wrap(
                  spacing: 8,
                  children: place.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDAA520).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDAA520),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 15),

                // Planned Date and Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (place.plannedDate != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Planned for:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5A5A5A),
                            ),
                          ),
                          Text(
                            '${place.plannedDate!.day}/${place.plannedDate!.month}/${place.plannedDate!.year}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                        ],
                      ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          color: Color(0xFF2D2D2D),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
