import 'package:dio/dio.dart';
import '../models/place_model.dart';

class PlacesService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.geoapify.com/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final String apiKey = '209b94b8f29c43018eeb659d8ba68684';

  // Static search terms
  final List<String> staticSearchTerms = [
    'متحف',           // Museum
    'مطعم',           // Restaurant
    'حديقة',          // Park
    'محميه',     // Tourist attraction
    'مسج',           // Mosque
    'كنيسة',          // Church
    'Citadel',           // Castle
    //'فندق',
    'كافيه',
    'سينما',
    'مستشفي',
    'fast food',
    'stadium',
    'shopping'
  ];

  final Map<String, String> placeTypeTranslations = {
    'متحف': 'Museum',
    'مطعم': 'Restaurant',
    'حديقة': 'Park',
    'محميه': 'Nature preserve',
    'مسج': 'Mosque',
    'كنيسة': 'Church',
    'Citadel': 'Castle',
    //'فندق': 'Hotel',
    'كافيه': 'Cafe',
    'سينما': 'Cinema',
    'مستشفي': 'Hospital',
    'fast food':'fast food',
    'stadium':'stadium',
    'shopping':'shopping'
  };

  /// This searches multiple categories and returns combined results
  /// 🚀 OPTIMIZED: All API calls are now executed in parallel for faster loading
  Future<List<PlaceModel>> getPlaces({
    required String categories, // Kept for backward compatibility but not used
    required double longitude,
    required double latitude,
    required double radius, // Not used in autocomplete, proximity bias instead
    int limit = 10,
  }) async {
    try {
      String? countryCode = await _getCountryCode(
        latitude: latitude,
        longitude: longitude,
      );
      countryCode ??= 'eg';
      print('🌍 Using country code: $countryCode');
      // 🚀 Execute all searches in parallel instead of sequentially
      final List<Future<List<PlaceModel>>> searchFutures = staticSearchTerms.map((searchTerm) async {
        try {
          // حفظ النوع الإنجليزي حسب الترجمة
          final englishType = placeTypeTranslations[searchTerm] ?? 'Unknown';

          final places = await _searchAutocomplete(
            searchText: searchTerm,
            longitude: longitude,
            latitude: latitude,
            limit: limit,
            countryCode: countryCode!,
          );

          // إضافة الـ type لكل نتيجة
          return places.map((p) => p.copyWith(type: englishType)).toList();
        } catch (e) {
          print('⚠️ Error searching for "$searchTerm": $e');
          // Return empty list if search fails, so other searches can continue
          return <PlaceModel>[];
        }
      }).toList();

      // Wait for all searches to complete in parallel
      final List<List<PlaceModel>> results = await Future.wait(searchFutures);
      
      // Flatten all results into a single list
      //This line converts a list of lists into a single flat list.
      final List<PlaceModel> allPlaces = results.expand((places) => places).toList();

      // Remove duplicates based on place_id
      final uniquePlaces = <String, PlaceModel>{};
      for (var place in allPlaces) {
        final id = place.placeId ?? '${place.latitude}_${place.longitude}';
        if (!uniquePlaces.containsKey(id)) {
          uniquePlaces[id] = place;
        }
      }

      print('✅ ✅ ✅ Found ${uniquePlaces.length} unique places from ${staticSearchTerms.length} categories (loaded in parallel)');
      return uniquePlaces.values.toList();

    } catch (e) {
      print('❌ Error in getPlaces: $e');
      throw Exception('Error fetching places: $e');
    }
  }

  /// Single search term autocomplete
  Future<List<PlaceModel>> _searchAutocomplete({
    required String searchText,
    required double longitude,
    required double latitude,
    required String countryCode,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'text': searchText,
        'filter': 'countrycode:$countryCode',
        'bias': 'proximity:$longitude,$latitude',
        // 'bias': 'proximity:12.496366,41.902782',//it
        // 'bias': 'proximity:-73.935242,40.730610',//us
        'limit': limit,
        'apiKey': apiKey,
      };

      print(
          '📡 Searching autocomplete: "$searchText" in $countryCode near ($longitude, $latitude)');


      final response = await _dio.get(
        '/geocode/autocomplete',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final features = response.data['features'] as List? ?? [];
        print('✅ Found ${features.length} results for "$searchText"');

        return features.map((json) => PlaceModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to search: ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('❌ Dio Response data: ${e.response?.data}');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout');
      } else {
        throw Exception('Error fetching autocomplete: ${e.message}');
      }
    }
  }

  Future<List<PlaceModel>> searchCustomTerm({
    required String searchText,
    required double longitude,
    required double latitude,
    int limit = 10,
  }) async {
    String? countryCode = await _getCountryCode(
      latitude: latitude,
      longitude: longitude,
    );
    countryCode ??= 'eg';
    return await _searchAutocomplete(

      searchText: searchText,
      longitude: longitude,
      latitude: latitude,
      limit: limit,
      countryCode: countryCode,
    );
  }



  Future<String?> _getCountryCode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        '/geocode/reverse',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'apiKey': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final features = response.data['features'] as List? ?? [];
        if (features.isNotEmpty) {
          final props = features[0]['properties'] as Map<String, dynamic>;
          // Geoapify بيرجع country_code جاهز small (مثلاً eg, us, it)
          final String? code = props['country_code'];
          print('🌍 Detected country code: $code');
          return code;
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting country code: $e');
      return null;
    }
  }

}
