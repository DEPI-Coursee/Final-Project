import 'package:dio/dio.dart';
import '../models/place_model.dart';

class PlacesService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.geoapify.com/v2',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final String apiKey = '209b94b8f29c43018eeb659d8ba68684';

  Future<List<PlaceModel>> getPlaces({
    required String categories,
    required double longitude,
    required double latitude,
    required double radius, // بالـ meters
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'categories': categories,
        'filter': 'circle:$longitude,$latitude,$radius',
        'bias': 'proximity:$longitude,$latitude',
        'limit': limit,
        'apiKey': apiKey,
      };

      // طباعه الـ URL النهائي عشان نفهم المشكلة
      print('📡 Requesting: /places with params: $queryParams');

      final response = await _dio.get('/places', queryParameters: queryParams);

      print('✅ Response status: ${response.statusCode}');
      print('📄 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final features = response.data['features'] as List;
        return features.map((json) => PlaceModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load places: ${response.statusCode} - ${response.data}',
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
        throw Exception('Error fetching places: ${e.message}');
      }
    }
  }
}
