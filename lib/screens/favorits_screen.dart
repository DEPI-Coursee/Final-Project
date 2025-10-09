import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  final List<String> cardData = const [
    'Giza Pyramids',
    'Valley of the Kings',
    'Karnak Temple',
    'Abu Simbel Temple',
    'Luxor Temple',
    'The Sphinx',
    'Aswan Dam',
    'Nile River Cruise',
    'Abu Qir',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favorites",
          style: TextStyle(color: Color(0xFF4A3A2A)),
        ),
        centerTitle: true,
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            itemCount: cardData.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              return DestinationCard(title: cardData[index]);
            },
          ),
        ),
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String title;

  const DestinationCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 45,
            child: Image.network(
              "https://gratisography.com/wp-content/uploads/2024/11/gratisography-augmented-reality-800x525.jpg",
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey,
                  child: const Center(
                    child: Text(
                      'Image failed to load',
                      style: TextStyle(fontSize: 8),
                    ),
                  ),
                );
              },
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A3A2A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Row(
                            children: [
                              Icon(Icons.location_on, size: 8, color: Colors.grey),
                              SizedBox(width: 2),
                              Text(
                                'Cairo, Egypt',
                                style: TextStyle(fontSize: 8, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Text(
                        '\$225',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3A2A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  const Flexible(
                    child: Text(
                      'The magnificent ancient pyramids and Great Sphinx...',
                      style: TextStyle(fontSize: 8, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Planned for:',
                              style: TextStyle(fontSize: 7, color: Colors.grey)),
                          Text('15/10/2025',
                              style:
                              TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8B7B6B),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              elevation: 2,
                              minimumSize: Size.zero,
                            ),
                            child: const Text(
                              'Details',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8,
                                  color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.favorite),
                              iconSize: 12,
                              padding: EdgeInsets.zero,
                              color: Color(0xFF4A3A2A),
                            ),
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
