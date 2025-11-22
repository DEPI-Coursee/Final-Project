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

  // --- Safe GET helper with debug ---
  Future<Response?> _safeGet(String url, Map<String, dynamic> params) async {
    try {
      print('📡 GET $url with params: $params');
      final response = await _dio.get(url, queryParameters: params);
      return response;
    } on DioException catch (e) {
      print('⚠️ Dio Error: ${e.message} (url=$url)');
      return null;
    }
  }

  // --- Search Wikipedia title by name ---
  Future<String?> _searchWikiTitle(String placeName) async {
    if (placeName.isEmpty) return null;
    final String apiBase = _isPrimarilyArabic(placeName)
        ? _wikiApiBaseAr
        : _wikiApiBaseEn;

    final params = {
      'action': 'query',
      'list': 'search',
      'srsearch': placeName,
      'format': 'json',
      'srlimit': 1,
    };

    final response = await _safeGet(apiBase, params);
    final search = response?.data['query']?['search'] as List<dynamic>?;
    if (search != null && search.isNotEmpty) {
      return search.first['title'] as String?;
    }
    return null;
  }

  // --- Get Wikidata P18 image filename ---
  Future<String?> _getFilenameFromWikidata(String entityId) async {
    if (entityId.isEmpty) return null;
    final params = {
      'action': 'wbgetentities',
      'ids': entityId,
      'props': 'claims',
      'format': 'json',
    };
    final response = await _safeGet(_wikidataApiBase, params);
    final claims =
        response?.data['entities']?[entityId]?['claims']
            as Map<String, dynamic>?;
    if (claims != null && claims.containsKey('P18')) {
      final imageClaim = claims['P18'][0];
      return imageClaim['mainsnak']['datavalue']['value'] as String?;
    }
    return null;
  }

  Future<String?> _getImageUrlFromFilename(String filename) async {
    if (filename.isEmpty) return null;
    final params = {
      'action': 'query',
      'titles': 'File:$filename',
      'prop': 'imageinfo',
      'iiprop': 'url',
      'format': 'json',
    };
    final response = await _safeGet(_wikiApiBaseEn, params);
    final pages = response?.data['query']?['pages'] as Map<String, dynamic>?;
    if (pages != null) {
      final pageId = pages.keys.first;
      final infoList = pages[pageId]?['imageinfo'] as List?;
      if (pageId != '-1' && infoList != null && infoList.isNotEmpty) {
        return infoList.first['url'] as String?;
      }
    }
    return null;
  }

  // --- Convert Q-ID to Wikipedia title ---
  Future<String?> _getWikiDataEntityTitle(String entityId) async {
    if (entityId.isEmpty) return null;
    final params = {
      'action': 'wbgetentities',
      'ids': entityId,
      'props': 'sitelinks',
      'format': 'json',
    };
    final response = await _safeGet(_wikidataApiBase, params);
    final sitelinks =
        response?.data['entities']?[entityId]?['sitelinks']
            as Map<String, dynamic>?;
    if (sitelinks != null) {
      final enTitle = sitelinks['enwiki']?['title'] as String?;
      final arTitle = sitelinks['arwiki']?['title'] as String?;
      return enTitle ?? arTitle;
    }
    return null;
  }

  // --- Get Q-ID from Wikipedia title ---
  Future<String?> _getWikiDataEntityId(String wikiTitle) async {
    if (wikiTitle.isEmpty) return null;
    final apiBase = _isPrimarilyArabic(wikiTitle)
        ? _wikiApiBaseAr
        : _wikiApiBaseEn;
    final params = {
      'action': 'query',
      'prop': 'pageprops',
      'titles': wikiTitle,
      'format': 'json',
    };
    final response = await _safeGet(apiBase, params);
    final pages = response?.data['query']?['pages'] as Map<String, dynamic>?;
    if (pages != null) {
      final pageId = pages.keys.first;
      final pageData = pages[pageId];
      if (pageId != '-1' && pageData?['pageprops'] != null) {
        return pageData['pageprops']['wikibase_item'] as String?;
      }
    }
    return null;
  }

  // --- Fetch summary safely ---
  Future<String?> _fetchSummary(String wikiTitle, {String lang = 'en'}) async {
    if (wikiTitle.isEmpty) return null;
    final apiBase = (lang == 'ar') ? _wikiApiBaseAr : _wikiApiBaseEn;
    final params = {
      'action': 'query',
      'prop': 'extracts',
      'titles': wikiTitle,
      'format': 'json',
      'exsentences': 3,
      'exintro': 1,
      'explaintext': 1,
      'redirects': 1,
    };
    final response = await _safeGet(apiBase, params);
    final pages = response?.data['query']?['pages'] as Map<String, dynamic>?;
    if (pages != null) {
      final pageId = pages.keys.first;
      final pageData = pages[pageId];
      if (pageId != '-1' && pageData?['extract'] != null) {
        return pageData['extract'] as String?;
      }
    }
    return null;
  }

  // --- Master Public Image Method ---
  Future<String?> getBestImageUrl(String query) async {
    if (query.isEmpty) return null;

    String? url;
    try {
      if (query.startsWith('Q')) {
        final filename = await _getFilenameFromWikidata(query);
        if (filename != null) url = await _getImageUrlFromFilename(filename);
        if (url != null) return url;
      }

      final wikiTitle = await _searchWikiTitle(query);
      if (wikiTitle == null) return null;

      final apiBase = _isPrimarilyArabic(query)
          ? _wikiApiBaseAr
          : _wikiApiBaseEn;
      final params = {
        'action': 'query',
        'titles': wikiTitle,
        'prop': 'pageimages',
        'pithumbsize': 400,
        'format': 'json',
        'redirects': 1,
      };
      final response = await _safeGet(apiBase, params);
      final pages = response?.data['query']?['pages'] as Map<String, dynamic>?;
      if (pages != null) {
        url = pages[pages.keys.first]?['thumbnail']?['source'] as String?;
        if (url != null) return url;

        // fallback to English if Arabic has no image
        if (apiBase == _wikiApiBaseAr) {
          final responseEn = await _safeGet(_wikiApiBaseEn, params);
          final pagesEn =
              responseEn?.data['query']?['pages'] as Map<String, dynamic>?;
          url =
              pagesEn?[pagesEn.keys.first]?['thumbnail']?['source'] as String?;
          if (url != null) return url;
        }
      }

      // fallback via Q-ID
      final entityId = await _getWikiDataEntityId(wikiTitle);
      if (entityId != null) {
        final filename = await _getFilenameFromWikidata(entityId);
        if (filename != null) {
          url = await _getImageUrlFromFilename(filename);
        }
      }
    } catch (e) {
      print('⚠️ Error in getBestImageUrl: $e');
    }
    return url;
  }

  // --- Get summary / description ---
  Future<String?> getSummary(String query) async {
    if (query.isEmpty) return null;

    String? wikiTitle;
    if (query.startsWith('Q')) {
      wikiTitle = await _getWikiDataEntityTitle(query);
    } else {
      wikiTitle = await _searchWikiTitle(query);
    }
    if (wikiTitle == null) return null;

    String? summary = await _fetchSummary(wikiTitle, lang: 'ar');
    if (summary == null || summary.length < 40) {
      final summaryEn = await _fetchSummary(wikiTitle, lang: 'en');
      if (summaryEn != null) summary = summaryEn;
    }
    return summary;
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
