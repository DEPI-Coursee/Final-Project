import 'package:dio/dio.dart';

class WikipediaImageService {
  final Dio _dio = Dio();

  static const String _wikiApiBaseEn = 'https://en.wikipedia.org/w/api.php';
  static const String _wikiApiBaseAr = 'https://ar.wikipedia.org/w/api.php';
  static const String _wikidataApiBase = 'https://www.wikidata.org/w/api.php';

  bool _isPrimarilyArabic(String text) {
    final arabicCount = RegExp(r'[\u0600-\u06FF]').allMatches(text).length;
    return arabicCount > (text.length / 2);
  }

  // Helper: Searches Wikipedia for the most relevant page title.
  Future<String?> _searchWikiTitle(String placeName) async {
    final String apiBase = _isPrimarilyArabic(placeName)
        ? _wikiApiBaseAr
        : _wikiApiBaseEn;

    final Map<String, dynamic> searchParams = {
      'action': 'query',
      'list': 'search',
      'srsearch': placeName,
      'format': 'json',
      'srlimit': 1,
    };
    try {
      final response = await _dio.get(apiBase, queryParameters: searchParams);
      final search = response.data['query']?['search'] as List<dynamic>?;
      if (search != null && search.isNotEmpty) {
        return search.first['title'] as String?;
      }
    } on DioException catch (e) {
      print("Dio Error searching Wikipedia: ${e.message}");
    }
    return null;
  }

  // --- Secondary Fallback Logic (Wikidata Q-ID and P18 Lookup) ---

  Future<String?> _getWikiDataEntityId(String wikiTitle) async {
    final String apiBase = _isPrimarilyArabic(wikiTitle)
        ? _wikiApiBaseAr
        : _wikiApiBaseEn;

    final Map<String, dynamic> matchParams = {
      'action': 'query',
      'prop': 'pageprops',
      'titles': wikiTitle,
      'format': 'json',
    };

    try {
      final response = await _dio.get(apiBase, queryParameters: matchParams);
      final pages = response.data['query']?['pages'] as Map<String, dynamic>?;

      if (pages != null) {
        final pageId = pages.keys.first;
        final pageData = pages[pageId];

        // Return Q-ID if found
        if (pageId != '-1' && pageData?['pageprops'] != null) {
          return pageData['pageprops']['wikibase_item'] as String?;
        }
      }
    } on DioException catch (e) {
      print("Dio Error fetching Q-ID: ${e.message}");
    }
    return null;
  }

  Future<String?> _getFilenameFromWikidata(String entityId) async {
    final Map<String, dynamic> propertyParams = {
      'action': 'wbgetentities',
      'ids': entityId,
      'props': 'claims',
      'format': 'json',
    };
    try {
      final response = await _dio.get(
        _wikidataApiBase,
        queryParameters: propertyParams,
      );
      final claims =
          response.data['entities']?[entityId]?['claims']
              as Map<String, dynamic>?;

      // P18 is the Wikidata property ID for the "Image" file
      if (claims != null && claims.containsKey('P18')) {
        final imageClaim = claims['P18'][0];
        return imageClaim['mainsnak']['datavalue']['value'] as String?;
      }
    } on DioException catch (e) {
      print("Dio Error fetching P18 filename: ${e.message}");
    }
    return null;
  }

  // Combines Q-ID and P18 logic to get the final image URL.
  Future<String?> _fallbackImageLookup(String placeName) async {
    final String? wikiTitle = await _searchWikiTitle(placeName);
    if (wikiTitle == null) return null;

    final String? entityId = await _getWikiDataEntityId(wikiTitle);
    if (entityId == null) return null;

    final String? filename = await _getFilenameFromWikidata(entityId);
    if (filename == null) return null;

    // Convert filename to direct URL using MediaWiki API (Commons)
    final Map<String, dynamic> imageParams = {
      'action': 'query',
      'titles': 'File:$filename', // Must prefix with 'File:'
      'prop': 'imageinfo',
      'iiprop': 'url',
      'format': 'json',
    };

    try {
      final response = await _dio.get(
        _wikiApiBaseEn,
        queryParameters: imageParams,
      ); // Use English base for Commons
      final pages = response.data['query']?['pages'] as Map<String, dynamic>?;

      if (pages != null) {
        final pageId = pages.keys.first;
        final infoList = pages[pageId]?['imageinfo'] as List?;
        if (pageId != '-1' && infoList != null && infoList.isNotEmpty) {
          return infoList.first['url'] as String?;
        }
      }
    } on DioException catch (e) {
      print("Dio Error fetching final image URL from filename: ${e.message}");
    }
    return null;
  }

  // --- Master Public Image Method ---

  Future<String?> getBestImageUrl(String placeName) async {
    final String? wikiTitle = await _searchWikiTitle(placeName);
    if (wikiTitle == null) return null;

    final String apiBase = _isPrimarilyArabic(placeName)
        ? _wikiApiBaseAr
        : _wikiApiBaseEn;

    // 1. PRIMARY ATTEMPT: Use the reliable pageimages property (fastest)
    final Map<String, dynamic> primaryParams = {
      'action': 'query',
      'titles': wikiTitle,
      'prop': 'pageimages',
      'pithumbsize': 400,
      'format': 'json',
      'redirects': 1,
    };

    try {
      final response = await _dio.get(apiBase, queryParameters: primaryParams);
      final pages = response.data['query']?['pages'] as Map<String, dynamic>?;

      if (pages != null) {
        final thumbnailUrl =
            pages[pages.keys.first]?['thumbnail']?['source'] as String?;
        if (thumbnailUrl != null) {
          return thumbnailUrl; // 🚀 SUCCESS: Return fast result
        }
      }
    } on DioException {
      // Log, but do not stop. Proceed to fallback.
    }

    // 2. SECONDARY ATTEMPT: Fallback to the Q-ID/P18 lookup (slower but deeper)
    return _fallbackImageLookup(placeName);
  }

  // --- Public Method: Get Short Summary/Description (Remains Correct) ---
  Future<String?> getSummary(String placeName) async {
    final String? wikiTitle = await _searchWikiTitle(placeName);
    if (wikiTitle == null) return null;

    final String apiBase = _isPrimarilyArabic(placeName)
        ? _wikiApiBaseAr
        : _wikiApiBaseEn;

    final Map<String, dynamic> params = {
      'action': 'query',
      'prop': 'extracts',
      'titles': wikiTitle,
      'format': 'json',
      'exsentences': 3,
      'exintro': 1,
      'explaintext': 1,
      'redirects': 1,
    };

    try {
      final response = await _dio.get(apiBase, queryParameters: params);
      final pages = response.data['query']?['pages'] as Map<String, dynamic>?;

      if (pages != null) {
        final pageId = pages.keys.first;
        final pageData = pages[pageId];

        if (pageId != '-1' && pageData?['extract'] != null) {
          return pageData['extract'] as String?;
        }
      }
    } on DioException catch (e) {
      print("Dio Error fetching summary for '$placeName': ${e.message}");
    }
    return null;
  }
}
// import 'package:dio/dio.dart';

// class WikipediaImageService {
//   final Dio _dio = Dio();

//   // Base URLs
//   static const String _wikiApiBaseEn = 'https://en.wikipedia.org/w/api.php';
//   static const String _wikiApiBaseAr = 'https://ar.wikipedia.org/w/api.php';

//   // Base URLs for Wikidata
//   static const String _wikidataApiBase = 'https://www.wikidata.org/w/api.php';

//   // Helper function to check if the name contains mostly Arabic characters
//   bool _isPrimarilyArabic(String text) {
//     // Counts the number of Arabic characters (Unicode range 0600-06FF)
//     final arabicCount = RegExp(r'[\u0600-\u06FF]').allMatches(text).length;
//     return arabicCount >
//         (text.length / 2); // True if more than half the characters are Arabic
//   }

//   // Helper function: Searches Wikipedia for the most relevant page title.
//   Future<String?> _searchWikiTitle(String placeName) async {
//     // Determine which API base to use
//     final String apiBase = _isPrimarilyArabic(placeName)
//         ? _wikiApiBaseAr
//         : _wikiApiBaseEn;

//     final Map<String, dynamic> searchParams = {
//       'action': 'query',
//       'list': 'search',
//       'srsearch': placeName,
//       'format': 'json',
//       'srlimit': 1,
//     };
//     try {
//       final response = await _dio.get(apiBase, queryParameters: searchParams);
//       final search = response.data['query']?['search'] as List<dynamic>?;
//       if (search != null && search.isNotEmpty) {
//         return search.first['title'] as String?;
//       }
//     } on DioException catch (e) {
//       print("Dio Error searching Wikipedia: ${e.message}");
//     }
//     return null;
//   }

//   // --- Public Method: Get Best Image URL (Final Reliable Method) ---
//   Future<String?> getBestImageUrl(String placeName) async {
//     final String? wikiTitle = await _searchWikiTitle(placeName);
//     if (wikiTitle == null) return null;

//     final String apiBase = _isPrimarilyArabic(placeName)
//         ? _wikiApiBaseAr
//         : _wikiApiBaseEn;

//     final Map<String, dynamic> params = {
//       'action': 'query',
//       'titles': wikiTitle, // Use the verified title
//       'prop': 'pageimages',
//       'pithumbsize': 400,
//       'format': 'json',
//       'redirects': 1,
//     };

//     try {
//       final response = await _dio.get(apiBase, queryParameters: params);
//       final pages = response.data['query']?['pages'] as Map<String, dynamic>?;

//       if (pages != null) {
//         final pageId = pages.keys.first;
//         final thumbnailUrl = pages[pageId]?['thumbnail']?['source'] as String?;

//         if (thumbnailUrl != null) {
//           return thumbnailUrl;
//         }
//       }
//     } on DioException catch (e) {
//       print("Dio Error (getBestImageUrl) for '$placeName': ${e.message}");
//     }
//     return null;
//   }

//   // --- Public Method: Get Short Summary/Description ---
//   Future<String?> getSummary(String placeName) async {
//     // Get the title using the language-aware search
//     final String? wikiTitle = await _searchWikiTitle(placeName);
//     if (wikiTitle == null) return null;

//     final String apiBase = _isPrimarilyArabic(placeName)
//         ? _wikiApiBaseAr
//         : _wikiApiBaseEn;

//     final Map<String, dynamic> params = {
//       'action': 'query',
//       'prop': 'extracts',
//       'titles': wikiTitle, // Use the search-validated title
//       'format': 'json',
//       'exsentences': 3,
//       'exintro': 1,
//       'explaintext': 1,
//       'redirects': 1,
//     };

//     try {
//       final response = await _dio.get(apiBase, queryParameters: params);
//       final pages = response.data['query']?['pages'] as Map<String, dynamic>?;

//       if (pages != null) {
//         final pageId = pages.keys.first;
//         final pageData = pages[pageId];

//         if (pageId != '-1' && pageData?['extract'] != null) {
//           // If the lookup was on the Arabic site, the summary will be in Arabic!
//           return pageData['extract'] as String?;
//         }
//       }
//     } on DioException catch (e) {
//       print("Dio Error fetching summary for '$placeName': ${e.message}");
//     }
//     return null;
//   }
// }
