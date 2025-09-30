import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final count = 10;
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 10,
        title: Text(
          'Tourio',
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Color(0xFFA8845F),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.menu, color: Color(0xFFB58E66)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Let’s find the perfect place for you',
                    style: TextStyle(
                      color: Color(0xFFC6986F),
                      fontSize: 20,
                      fontFamily: 'Caveat',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search a place',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          // TODO: search action
                        },
                        icon: Icon(Icons.search, color: Color(0xFFC6986F)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: count,
                itemBuilder: (ctx, index) => InkWell(
                  onTap: () {
                    // TODO: aro7 le one place page
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 180,
                          height: 120,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://upload.wikimedia.org/wikipedia/commons/e/e3/Kheops-Pyramid.jpg',
                              ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(0xFFC6986F),
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pyramids', //test data
                              style: TextStyle(
                                color: Color(0xFF916E53), ///nkhly da ellon el asasy le kol el titles?
                                fontSize: 18,
                              ),
                            ),
                            Text( //test data
                              'The pyramids of Giza and the Great Sphinx are among the most popular tourist destinations in the world, and indeed already were even in Roman times.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}










// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class HomeScreen extends StatelessWidget {
//   HomeScreen({super.key});
//
//   final count = 10;
//   final searchController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9F7F5),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         titleSpacing: 0,
//         title: Text(
//           'Discover new places',
//           style: TextStyle(
//             fontFamily: 'Caveat',
//             fontSize: 28,
//             color: const Color(0xFFC6986F),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.menu, color: Color(0xFFC6986F)),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           Text(
//             'Let’s find the perfect place for you!',
//             style: TextStyle(
//               fontFamily: 'Caveat',
//               fontSize: 22,
//               color: Colors.grey.shade800,
//             ),
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             controller: searchController,
//             decoration: InputDecoration(
//               hintText: 'Search a place...',
//               prefixIcon: const Icon(Icons.search),
//               filled: true,
//               fillColor: Colors.white,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           // Grid of places instead of raw rows
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: count,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               mainAxisSpacing: 16,
//               crossAxisSpacing: 16,
//               childAspectRatio: .75,
//             ),
//             itemBuilder: (context, index) {
//               return GestureDetector(
//                 onTap: () {}, // TODO: navigate to details
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 6,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ClipRRect(
//                         borderRadius: const BorderRadius.vertical(
//                           top: Radius.circular(16),
//                         ),
//                         child: Image.network(
//                           'https://upload.wikimedia.org/wikipedia/commons/e/e3/Kheops-Pyramid.jpg',
//                           height: 120,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           'Pyramids',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: const Color(0xFFC6986F),
//                           ),
//                         ),
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 8.0),
//                         child: Text(
//                           'The pyramids of Giza and the Great Sphinx...',
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(fontSize: 12, color: Colors.black54),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
