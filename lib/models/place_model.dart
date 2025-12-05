
class PlaceModel {
  final String? name;
  final String? addressLine2;
  final double? longitude;
  final double? latitude;
  final String? wikipediaUrl;
  final String? wikidataId;
  final String? country;
  final String? category;
  final String? type;
  final String? imageUrl;
  final String? description;
  final String? placeId;
  final double? distance;


  PlaceModel({
    this.name,
    this.addressLine2,
    this.longitude,
    this.latitude,
    this.wikipediaUrl,
    this.wikidataId,
    this.country,
    this.category,
    this.type,
    this.imageUrl,
    this.description,
    this.placeId,
    this.distance,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] ?? {};

    double? longitude = (properties['lon'] as num?)?.toDouble();
    double? latitude = (properties['lat'] as num?)?.toDouble();

    if (longitude == null || latitude == null) {
      final geometry = json['geometry'] as Map<String, dynamic>?;
      final coordinates = geometry?['coordinates'] as List<dynamic>?;
      if (coordinates != null && coordinates.length >= 2) {
        longitude = (coordinates[0] as num?)?.toDouble();
        latitude = (coordinates[1] as num?)?.toDouble();
      }
    }

    String? address = properties['formatted'] as String? ??
        properties['address_line2'] as String? ??
        properties['address_line1'] as String?;

    String? placeId = properties['place_id'] as String? ??
        properties['id'] as String? ??
        json['id'] as String?;

    // Extract distance from the root level of the JSON response
    // Distance can be at root level or in properties
    final double? distance = (json['distance'] as num?)?.toDouble() ?? 
                            (properties['distance'] as num?)?.toDouble();

    return PlaceModel(
      name: properties['name'] as String?,
      addressLine2: address,
      longitude: longitude,
      latitude: latitude,
      wikipediaUrl: properties['wikipedia'] as String?,
      wikidataId: properties['wikidata'] as String?,
      country: properties['country'] as String?,
      category: properties['categories'] is List
          ? (properties['categories'] as List).isNotEmpty
          ? properties['categories'][0]
          : null
          : properties['category'] as String?,
      imageUrl: null,
      description: null,
      placeId: placeId,
      distance: distance,
    );
  }

  PlaceModel copyWith({
    String? imageUrl,
    String? description,
    String? name,
    String? addressLine2,
    double? longitude,
    double? latitude,
    String? wikipediaUrl,
    String? wikidataId,
    String? country,
    String? category,
    String? type,
    String? placeId,
    double? distance,
  }) {
    return PlaceModel(
      name: name ?? this.name,
      addressLine2: addressLine2 ?? this.addressLine2,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      wikipediaUrl: wikipediaUrl ?? this.wikipediaUrl,
      wikidataId: wikidataId ?? this.wikidataId,
      country: country ?? this.country,
      category: category ?? this.category,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      placeId: placeId ?? this.placeId,
      distance: distance ?? this.distance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'addressLine2': addressLine2,
      'longitude': longitude,
      'latitude': latitude,
      'wikipediaUrl': wikipediaUrl,
      'wikidataId': wikidataId,
      'country': country,
      'category': category,
      'type': type,
      'imageUrl': imageUrl,
      'description': description,
      'placeId': placeId,
      'distance': distance,
    };
  }

  // Create PlaceModel from stored JSON (simpler format, not API response)
  factory PlaceModel.fromStoredJson(Map<String, dynamic> json) {
    return PlaceModel(
      name: json['name'] as String?,
      addressLine2: json['addressLine2'] as String?,
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      wikipediaUrl: json['wikipediaUrl'] as String?,
      wikidataId: json['wikidataId'] as String?,
      country: json['country'] as String?,
      category: json['category'] as String?,
      type: json['type'] as String?,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      placeId: json['placeId'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }
}
