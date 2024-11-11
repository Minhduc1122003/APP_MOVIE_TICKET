class Actor {
  final String name;
  final String image;
  final int movieId;

  Actor({
    required this.name,
    required this.image,
    required this.movieId,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      name: json['Name'] ?? '',
      image: json['Image'] ?? '',
      movieId: json['MovieID'] ?? 0,
    );
  }
}
