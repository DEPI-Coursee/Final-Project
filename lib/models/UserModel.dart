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
}

