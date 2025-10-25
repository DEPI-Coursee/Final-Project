class PlaceModel {
  final String? name;
  final String? addressLine2;
  final double? longitude;
  final double? latitude;
  final String? wikipediaUrl;
  final String? wikidataId;
  final String? country;
  final String? category;

  PlaceModel({
    this.name,
    this.addressLine2,
    this.longitude,
    this.latitude,
    this.wikipediaUrl,
    this.wikidataId,
    this.country,
    this.category,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] ?? {};
    final datasources = properties['datasource'] ?? {};
    final wikidata = datasources['raw'] ?? {};

    return PlaceModel(
      name: properties['name'] as String?,
      addressLine2: properties['address_line2'] as String?,
      longitude: properties['lon'] as double?,
      latitude: properties['lat'] as double?,
      wikipediaUrl: wikidata['wikipedia'] as String?,
      wikidataId: wikidata['wikidata'] as String?,
      country: properties['country'] as String?,
      category: properties['categories']?.first as String?,
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
    };
  }
}

