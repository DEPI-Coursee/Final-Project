class Usermodel {

  final String uid; 
  final String? fullName;
  final String? email;
  final String? password;
  final double? currentLat;
  final double? currentLng;
  final List<String>? favoritePlaces;
  final Map<String, DateTime>? visitListItems; // Map of placeId -> visitDateTime


  Usermodel({
    required this.uid,
    this.fullName,
    this.email,
    this.password,
    this.currentLat,
    this.currentLng,
    this.favoritePlaces,
    this.visitListItems,
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
    
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'currentLat': currentLat,
      'currentLng': currentLng,
      'favoritePlaces': favoritePlaces ?? [],
      'visitListItems': visitListItemsJson ?? {},
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

    return Usermodel(
      uid: json['uid'] as String,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      currentLat: json['currentLat'] as double?,
      currentLng: json['currentLng'] as double?,
      favoritePlaces: json['favoritePlaces'] != null 
          ? List<String>.from(json['favoritePlaces'] as List)
          : [],
      visitListItems: visitListItems,
    );
  }

  // Create a copy with updated fields
  Usermodel copyWith({
    String? fullName,
    String? email,
    double? currentLat,
    double? currentLng,
    List<String>? favoritePlaces,
    Map<String, DateTime>? visitListItems,
  }) {
    return Usermodel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      favoritePlaces: favoritePlaces ?? this.favoritePlaces,
      visitListItems: visitListItems ?? this.visitListItems,
    );
  }
}

