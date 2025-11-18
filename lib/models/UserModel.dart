class Usermodel {

  final String uid; 
  final String? fullName;
  final String? email;
  final String? password;
  final double? currentLat;
  final double? currentLng;
  final List<String>? favoritePlaces;
  final List<String>? visitedPlaces;


  Usermodel({
    required this.uid,
    this.fullName,
    this.email,
    this.password,
    this.currentLat,
    this.currentLng,
    this.favoritePlaces,
    this.visitedPlaces,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'currentLat': currentLat,
      'currentLng': currentLng,
      'favoritePlaces': favoritePlaces ?? [],
      'visitedPlaces': visitedPlaces ?? [],
      // Note: password is not saved to Firestore for security
    };
  }

  // Create UserModel from Firestore document
  factory Usermodel.fromJson(Map<String, dynamic> json) {
    return Usermodel(
      uid: json['uid'] as String,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      currentLat: json['currentLat'] as double?,
      currentLng: json['currentLng'] as double?,
      favoritePlaces: json['favoritePlaces'] != null 
          ? List<String>.from(json['favoritePlaces'] as List)
          : [],
      visitedPlaces: json['visitedPlaces'] != null
          ? List<String>.from(json['visitedPlaces'] as List)
          : [],
    );
  }

  // Create a copy with updated fields
  Usermodel copyWith({
    String? fullName,
    String? email,
    double? currentLat,
    double? currentLng,
    List<String>? favoritePlaces,
    List<String>? visitedPlaces,
  }) {
    return Usermodel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      favoritePlaces: favoritePlaces ?? this.favoritePlaces,
      visitedPlaces: visitedPlaces ?? this.visitedPlaces,
    );
  }
}

