class Usermodel {

  final String uid; 
  final String? fullName;
  final String? email;
  final String? password;
  final double? currentLat;
  final double? currentLng;
  final List<String>? favoritePlaces; // Legacy: kept for backward compatibility
  final List<Map<String, dynamic>>? favoritePlacesData; // New: full place data
  final Map<String, DateTime>? visitListItems; // Legacy: Map of placeId -> visitDateTime
  final Map<String, Map<String, dynamic>>? visitListItemsData; // New: Map of placeId -> {placeData, visitDateTime}


  Usermodel({
    required this.uid,
    this.fullName,
    this.email,
    this.password,
    this.currentLat,
    this.currentLng,
    this.favoritePlaces,
    this.favoritePlacesData,
    this.visitListItems,
    this.visitListItemsData,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toJson() {
    // Convert DateTime to ISO string for Firestore
    Map<String, String>? visitListItemsJson;
    if (visitListItems != null) {
      visitListItemsJson = visitListItems!.map(
        (key, value) => MapEntry(key, value.toIso8601String())
      );
    }
    
    // Convert visitListItemsData to JSON
    Map<String, dynamic>? visitListItemsDataJson;
    if (visitListItemsData != null) {
      visitListItemsDataJson = visitListItemsData!.map(
        (key, value) => MapEntry(key, value)
      );
    }
    
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'currentLat': currentLat,
      'currentLng': currentLng,
      'favoritePlaces': favoritePlaces ?? [], // Legacy
      'favoritePlacesData': favoritePlacesData ?? [], // New
      'visitListItems': visitListItemsJson ?? {}, // Legacy
      'visitListItemsData': visitListItemsDataJson ?? {}, // New
      // Note: password is not saved to Firestore for security
    };
  }

  // Create UserModel from Firestore document
  factory Usermodel.fromJson(Map<String, dynamic> json) {
    Map<String, DateTime>? visitListItems;
    if (json['visitListItems'] != null) {
      final items = json['visitListItems'] as Map;
      visitListItems = items.map(
        (key, value) => MapEntry(
          key as String,
          DateTime.parse(value as String)
        )
      );
    }

    // Parse visitListItemsData
    Map<String, Map<String, dynamic>>? visitListItemsData;
    if (json['visitListItemsData'] != null) {
      final items = json['visitListItemsData'] as Map;
      visitListItemsData = items.map(
        (key, value) => MapEntry(
          key as String,
          value as Map<String, dynamic>
        )
      );
    }

    // Parse favoritePlacesData
    List<Map<String, dynamic>>? favoritePlacesData;
    if (json['favoritePlacesData'] != null) {
      favoritePlacesData = List<Map<String, dynamic>>.from(json['favoritePlacesData'] as List);
    }

    return Usermodel(
      uid: json['uid'] as String,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      currentLat: json['currentLat'] as double?,
      currentLng: json['currentLng'] as double?,
      favoritePlaces: json['favoritePlaces'] != null 
          ? List<String>.from(json['favoritePlaces'] as List)
          : [],
      favoritePlacesData: favoritePlacesData,
      visitListItems: visitListItems,
      visitListItemsData: visitListItemsData,
    );
  }

  // Create a copy with updated fields
  Usermodel copyWith({
    String? fullName,
    String? email,
    double? currentLat,
    double? currentLng,
    List<String>? favoritePlaces,
    List<Map<String, dynamic>>? favoritePlacesData,
    Map<String, DateTime>? visitListItems,
    Map<String, Map<String, dynamic>>? visitListItemsData,
  }) {
    return Usermodel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      favoritePlaces: favoritePlaces ?? this.favoritePlaces,
      favoritePlacesData: favoritePlacesData ?? this.favoritePlacesData,
      visitListItems: visitListItems ?? this.visitListItems,
      visitListItemsData: visitListItemsData ?? this.visitListItemsData,
    );
  }
}

