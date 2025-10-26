import 'package:dio/dio.dart';

class WikipediaImageService {
  final Dio _dio = Dio();

  // Base URLs
  static const String _wikiApiBaseEn = 'https://en.wikipedia.org/w/api.php';
  static const String _wikiApiBaseAr = 'https://ar.wikipedia.org/w/api.php';

  // Base URLs for Wikidata
  static const String _wikidataApiBase = 'https://www.wikidata.org/w/api.php';

  // Helper function to check if the name contains mostly Arabic characters
  bool _isPrimarilyArabic(String text) {
    // Counts the number of Arabic characters (Unicode range 0600-06FF)
    final arabicCount = RegExp(r'[\u0600-\u06FF]').allMatches(text).length;
    return arabicCount >
        (text.length / 2); // True if more than half the characters are Arabic
  }

  // Helper function: Searches Wikipedia for the most relevant page title.
  Future<String?> _searchWikiTitle(String placeName) async {
    // Determine which API base to use
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

  // --- Public Method: Get Best Image URL (Final Reliable Method) ---
  Future<String?> getBestImageUrl(String placeName) async {
    final String? wikiTitle = await _searchWikiTitle(placeName);
    if (wikiTitle == null) return null;

    final String apiBase = _isPrimarilyArabic(placeName)
        ? _wikiApiBaseAr
        : _wikiApiBaseEn;

    final Map<String, dynamic> params = {
      'action': 'query',
      'titles': wikiTitle, // Use the verified title
      'prop': 'pageimages',
      'pithumbsize': 400,
      'format': 'json',
      'redirects': 1,
    };

    try {
      final response = await _dio.get(apiBase, queryParameters: params);
      final pages = response.data['query']?['pages'] as Map<String, dynamic>?;

      if (pages != null) {
        final pageId = pages.keys.first;
        final thumbnailUrl = pages[pageId]?['thumbnail']?['source'] as String?;

        if (thumbnailUrl != null) {
          return thumbnailUrl;
        }
      }
    } on DioException catch (e) {
      print("Dio Error (getBestImageUrl) for '$placeName': ${e.message}");
    }
    return null;
  }

  // --- Public Method: Get Short Summary/Description ---
  Future<String?> getSummary(String placeName) async {
    // Get the title using the language-aware search
    final String? wikiTitle = await _searchWikiTitle(placeName);
    if (wikiTitle == null) return null;

    final String apiBase = _isPrimarilyArabic(placeName)
        ? _wikiApiBaseAr
        : _wikiApiBaseEn;

    final Map<String, dynamic> params = {
      'action': 'query',
      'prop': 'extracts',
      'titles': wikiTitle, // Use the search-validated title
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
          // If the lookup was on the Arabic site, the summary will be in Arabic!
          return pageData['extract'] as String?;
        }
      }
    } on DioException catch (e) {
      print("Dio Error fetching summary for '$placeName': ${e.message}");
    }
    return null;
  }
}
