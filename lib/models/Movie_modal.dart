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
  final bool subTitle;
  final String genres;
  final String cinemaName;
  final String cinemaAddress;
  final String? reviewContents; // Có thể null
  final double? averageRating; // Có thể null
  final int reviewCount;
  final int age;

  MovieDetails({
    required this.movieId,
    required this.title,
    required this.description,
    required this.duration,
    required this.releaseDate,
    required this.posterUrl,
    required this.trailerUrl,
    required this.languageName,
    required this.subTitle,
    required this.genres,
    required this.cinemaName,
    required this.cinemaAddress,
    this.reviewContents, // Có thể null
    this.averageRating, // Có thể null
    required this.reviewCount,
    required this.age,
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
      age: json['Age'],
      languageName: json['LanguageName'],
      subTitle: json['Subtitle'],
      genres: json['Genres'],
      cinemaName: json['CinemaName'],
      cinemaAddress: json['CinemaAddress'],
      reviewContents: json['ReviewContents'], // Có thể null
      averageRating: json['AverageRating'] != null
          ? (json['AverageRating'] as num).toDouble()
          : null, // Có thể null
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
      'ReleaseDate':
          formatDate(releaseDate.toIso8601String()), // Sử dụng hàm formatDate
      'PosterUrl': posterUrl,
      'TrailerUrl': trailerUrl,
      'Age': age,
      'LanguageName': languageName,
      'Subtitle': subTitle,
      'Genres': genres,
      'CinemaName': cinemaName,
      'CinemaAddress': cinemaAddress,
      'ReviewContents': reviewContents, // Có thể null
      'AverageRating': averageRating, // Có thể null
      'ReviewCount': reviewCount,
    };
  }

  // Hàm helper để định dạng ngày tháng
  String formatDate(String dateString) {
    try {
      // Phân tích chuỗi ngày tháng từ định dạng ISO 8601
      DateTime date = DateTime.parse(dateString);
      // Định dạng ngày tháng theo định dạng 'dd/MM/yyyy'
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      // Nếu có lỗi trong phân tích chuỗi, trả về chuỗi rỗng hoặc thông báo lỗi
      return 'Ngày không hợp lệ';
    }
  }
}
