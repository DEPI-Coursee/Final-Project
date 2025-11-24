class PlaceModel {
  final String? name;
  final String? addressLine2;
  final double? longitude;
  final double? latitude;
  final String? wikipediaUrl;
  final String? wikidataId;
  final String? country;
  final String? category;

  final String? imageUrl;
  final String? description;
  final String? placeId; // Generated once and stored

  PlaceModel({
    this.name,
    this.addressLine2,
    this.longitude,
    this.latitude,
    this.wikipediaUrl,
    this.wikidataId,
    this.country,
    this.category,

    this.imageUrl,
    this.description,
    this.placeId,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] ?? {};

    // Handle both lon/lat and coordinates from geometry
    double? longitude = (properties['lon'] as num?)?.toDouble();
    double? latitude = (properties['lat'] as num?)?.toDouble();
    
    // Fallback: try geometry coordinates if lon/lat not in properties
    if (longitude == null || latitude == null) {
      final geometry = json['geometry'] as Map<String, dynamic>?;
      final coordinates = geometry?['coordinates'] as List<dynamic>?;
      if (coordinates != null && coordinates.length >= 2) {
        longitude = (coordinates[0] as num?)?.toDouble();
        latitude = (coordinates[1] as num?)?.toDouble();
      }
    }

    // Handle address - autocomplete returns formatted, places API returns address_line2
    String? address = properties['formatted'] as String? ?? 
                     properties['address_line2'] as String? ??
                     properties['address_line1'] as String?;

    // Generate place_id from multiple possible sources
    String? placeId = properties['place_id'] as String? ??
                     properties['id'] as String? ??
                     json['id'] as String?;

    return PlaceModel(
      name: properties['name'] as String?,
      addressLine2: address,
      longitude: longitude,
      latitude: latitude,

      // ✔ THESE ARE THE CORRECT FIELDS FROM GEOAPIFY
      wikipediaUrl: properties['wikipedia'] as String?, // ex: "en:Cairo_Tower"
      wikidataId: properties['wikidata'] as String?, // ex: "Q12345"

      country: properties['country'] as String?,
      category: properties['categories'] is List
          ? (properties['categories'] as List).isNotEmpty
                ? properties['categories'][0]
                : null
          : properties['category'] as String?, // Autocomplete might use singular

      imageUrl: null,
      description: null,
      placeId: placeId,
    );
  }

  // 🔑 Crucial method: Allows you to create a new model instance
  // with updated fields (like image/description) while keeping the old data.
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

      // Update the fields being fetched later
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
      'imageUrl': imageUrl,
      'description': description,
      'placeId': placeId,
    };
  }
}
