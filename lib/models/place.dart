class Place {
  final String id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final double rating;
  final String price;
  final List<String> tags;
  final bool isVisited;
  final DateTime? plannedDate;

  Place({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.tags,
    this.isVisited = false,
    this.plannedDate,
  });

  Place copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    String? imageUrl,
    double? rating,
    String? price,
    List<String>? tags,
    bool? isVisited,
    DateTime? plannedDate,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      tags: tags ?? this.tags,
      isVisited: isVisited ?? this.isVisited,
      plannedDate: plannedDate ?? this.plannedDate,
    );
  }
}
