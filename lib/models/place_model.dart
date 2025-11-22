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
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] ?? {};

    return PlaceModel(
      name: properties['name'] as String?,
      addressLine2: properties['address_line2'] as String?,
      longitude: (properties['lon'] as num?)?.toDouble(),
      latitude: (properties['lat'] as num?)?.toDouble(),

      // ✔ THESE ARE THE CORRECT FIELDS FROM GEOAPIFY
      wikipediaUrl: properties['wikipedia'] as String?, // ex: "en:Cairo_Tower"
      wikidataId: properties['wikidata'] as String?, // ex: "Q12345"

      country: properties['country'] as String?,
      category: properties['categories'] is List
          ? (properties['categories'] as List).isNotEmpty
                ? properties['categories'][0]
                : null
          : null,

      imageUrl: null,
      description: null,
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
    };
  }
}
