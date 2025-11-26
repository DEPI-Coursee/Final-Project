
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
    };
  }
}
