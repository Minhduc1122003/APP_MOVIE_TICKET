import 'package:intl/intl.dart';

class MovieDetails {
  final int movieId;
  final String title;
  final String description;
  final int duration;
  final DateTime releaseDate;
  final String posterUrl;
  final String trailerUrl;
  final String languageName;
  final String genres;
  final String cinemaName;
  final String cinemaAddress;
  final String reviewContents;
  final double averageRating;
  final int reviewCount;

  MovieDetails({
    required this.movieId,
    required this.title,
    required this.description,
    required this.duration,
    required this.releaseDate,
    required this.posterUrl,
    required this.trailerUrl,
    required this.languageName,
    required this.genres,
    required this.cinemaName,
    required this.cinemaAddress,
    required this.reviewContents,
    required this.averageRating,
    required this.reviewCount,
  });

  // Hàm khởi tạo từ JSON
  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
      movieId: json['MovieID'],
      title: json['Title'],
      description: json['Description'],
      duration: json['Duration'],
      releaseDate: DateTime.parse(json['ReleaseDate']),
      posterUrl: json['PosterUrl'],
      trailerUrl: json['TrailerUrl'],
      languageName: json['LanguageName'],
      genres: json['Genres'],
      cinemaName: json['CinemaName'],
      cinemaAddress: json['CinemaAddress'],
      reviewContents: json['ReviewContents'],
      averageRating: json['AverageRating'].toDouble(),
      reviewCount: json['ReviewCount'],
    );
  }

  // Hàm chuyển đổi thành JSON
  Map<String, dynamic> toJson() {
    return {
      'MovieID': movieId,
      'Title': title,
      'Description': description,
      'Duration': duration,
      'ReleaseDate': DateFormat('dd/MM/yyyy').format(releaseDate),
      'PosterUrl': posterUrl,
      'TrailerUrl': trailerUrl,
      'LanguageName': languageName,
      'Genres': genres,
      'CinemaName': cinemaName,
      'CinemaAddress': cinemaAddress,
      'ReviewContents': reviewContents,
      'AverageRating': averageRating,
      'ReviewCount': reviewCount,
    };
  }
}
