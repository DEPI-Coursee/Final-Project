import 'package:dio/dio.dart';
import '../models/place_model.dart';

class PlacesService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.geoapify.com/v2',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final String apiKey = '89dc05ab7f2e4f3082488262f63ac859';

  Future<List<PlaceModel>> getPlaces({
    required String categories,
    required double longitude,
    required double latitude,
    required double radius,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/places',
        queryParameters: {
          'categories': categories,
          'filter': 'circle:$longitude,$latitude,$radius',
          'bias': 'proximity:$longitude,$latitude',
          'limit': limit,
          'apiKey': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final features = response.data['features'] as List;
        return features.map((json) => PlaceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load places');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout');
      } else {
        throw Exception('Error: ${e.message}');
      }
    }
  }
}

