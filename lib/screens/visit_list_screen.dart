import 'package:flutter/material.dart';

class VisitListScreen extends StatelessWidget {
  const VisitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final places = [
      'Giza Pyramids', 'Valley of the Kings', 'Karnak Temple',
      'Abu Simbel Temple', 'Luxor Temple', 'The Sphinx',
      'Aswan Dam', 'Nile River Cruise',
    ];

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
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section outside container
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
                    itemCount: places.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) => _buildCard(context, places[index]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title) {
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
            child: Image.network(
              "https://cdn-imgix.headout.com/media/images/c4a520a45f9aea6fbcaab0eee5089a5a-Louvre%20Paris%20Pyramids.jpg?auto=format&w=1069.6000000000001&h=687.6&q=90&ar=14%3A9&crop=faces&fit=crop",
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey,
                child: const Center(child: Text('Image failed to load', style: TextStyle(fontSize: 8))),
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
                            Text(title, 
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontSize: 12, 
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 8, color: Colors.grey),
                                const SizedBox(width: 2),
                                Text('Cairo, Egypt', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 8,
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text('\$225', style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                      )),
                    ],
                  ),
                  const SizedBox(height: 1),
                    Flexible(
                      child: Text('The magnificent ancient pyramids and Great Sphinx...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 8,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status:', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 7,
                          )),
                          Text('To Visit', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 8, 
                            fontWeight: FontWeight.bold,
                          )),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              minimumSize: Size.zero,
                            ),
                            child: Text('Details', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold, 
                              fontSize: 8, 
                              color: Colors.white,
                            )),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.check_circle, size: 12, color: Theme.of(context).primaryColor),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
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
