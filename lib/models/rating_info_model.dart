class RatingInfoModel {
  final int userId;
  final String? avatar;
  final String name;
  final int movieId;
  final String reviewContent;
  final double rating;
  final DateTime ratingDate;

  RatingInfoModel({
    required this.userId,
    this.avatar,
    required this.name,
    required this.movieId,
    required this.reviewContent,
    required this.rating,
    required this.ratingDate,
  });

  // Phương thức từ JSON
  factory RatingInfoModel.fromJson(Map<String, dynamic> json) {
    return RatingInfoModel(
      userId: json['UserID'],
      avatar: json['Avatar'],
      name: json['Name'],
      movieId: json['MovieID'],
      reviewContent: json['ReviewContent'],
      rating: json['Rating'].toDouble(),
      ratingDate: DateTime.parse(json['RatingDate']),
    );
  }

  // Phương thức chuyển sang JSON
  Map<String, dynamic> toJson() {
    return {
      'UserID': userId,
      'Avatar': avatar,
      'Name': name,
      'MovieID': movieId,
      'ReviewContent': reviewContent,
      'Rating': rating,
      'RatingDate': ratingDate.toIso8601String(),
    };
  }
}
