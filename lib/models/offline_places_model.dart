class OfflinePlace {
  final String name;
  final String country;
  final String description;
  final String imagePath;
  final String? shortdescription;

  OfflinePlace({
     this.shortdescription,
    required this.name,
    required this.country,
    required this.description,
    required this.imagePath,
  });
}
