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

  // Static search terms - you can modify these!
  final List<String> staticSearchTerms = [
    'متحف',           // Museum
    'مطعم',           // Restaurant
    'حديقة',          // Park
    'معلم سياحي',     // Tourist attraction
    'مسجد',           // Mosque
    'كنيسة',          // Church
    'قلعة',           // Castle
    'سوق',            // Market
  ];

  /// New method: Get places using Autocomplete API with static search terms
  /// This searches multiple categories and returns combined results
  Future<List<PlaceModel>> getPlaces({
    required String categories, // Kept for backward compatibility but not used
    required double longitude,
    required double latitude,
    required double radius, // Not used in autocomplete, proximity bias instead
    int limit = 10,
  }) async {
    try {
      List<PlaceModel> allPlaces = [];
      
      // Search for each static term
      for (String searchTerm in staticSearchTerms) {
        try {
          final places = await _searchAutocomplete(
            searchText: searchTerm,
            longitude: longitude,
            latitude: latitude,
            limit: limit,
          );
          allPlaces.addAll(places);
        } catch (e) {
          print('⚠️ Error searching for "$searchTerm": $e');
          // Continue with other search terms even if one fails
        }
      }
      
      // Remove duplicates based on place_id
      final uniquePlaces = <String, PlaceModel>{};
      for (var place in allPlaces) {
        final id = place.placeId ?? '${place.latitude}_${place.longitude}';
        if (!uniquePlaces.containsKey(id)) {
          uniquePlaces[id] = place;
        }
      }
      
      print('✅ Found ${uniquePlaces.length} unique places from ${staticSearchTerms.length} categories');
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
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'text': searchText,
        'filter': 'countrycode:eg',
        'bias': 'proximity:$longitude,$latitude',
        'limit': limit,
        'apiKey': apiKey,
      };

      print('📡 Searching autocomplete: "$searchText" near ($longitude, $latitude)');

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

  /// Public method to search with a custom search term (if needed)
  Future<List<PlaceModel>> searchCustomTerm({
    required String searchText,
    required double longitude,
    required double latitude,
    int limit = 10,
  }) async {
    return await _searchAutocomplete(
      searchText: searchText,
      longitude: longitude,
      latitude: latitude,
      limit: limit,
    );
  }
}
