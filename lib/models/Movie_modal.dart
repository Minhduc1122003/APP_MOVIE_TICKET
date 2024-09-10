import 'package:intl/intl.dart';

class MovieDetails {
  final int movieId;
  final String title;
  final String description;
  final int duration;
  final String releaseDate;
  final String posterUrl;
  final String trailerUrl;
  final bool subTitle; // Đã thêm SubTitle
  final bool voiceover; // Đã thêm Voiceover
  final String age; // Thay thế LanguageName bằng Age
  final String genres;
  final String cinemaName;
  final String cinemaAddress;
  final String? reviewContents; // Có thể null
  final double? averageRating; // Có thể null
  final int reviewCount;
  final bool? favourite; // Không sử dụng late
  final int rating9_10;
  final int rating7_8;
  final int rating5_6;
  final int rating3_4;
  final int rating1_2;

  MovieDetails({
    required this.movieId,
    required this.title,
    required this.description,
    required this.duration,
    required this.releaseDate,
    required this.posterUrl,
    required this.trailerUrl,
    required this.subTitle,
    required this.voiceover,
    required this.genres,
    required this.cinemaName,
    required this.cinemaAddress,
    this.reviewContents, // Có thể null
    this.averageRating, // Có thể null
    required this.reviewCount,
    required this.age,
    this.favourite,
    required this.rating9_10,
    required this.rating7_8,
    required this.rating5_6,
    required this.rating3_4,
    required this.rating1_2,
  });
  // Hàm khởi tạo từ JSON
  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final DateTime? parsedDate = json['ReleaseDate'] != null
        ? DateTime.tryParse(json['ReleaseDate'])
        : null;
    return MovieDetails(
      movieId: json['MovieID'],
      title: json['Title'],
      description: json['Description'],
      duration: json['Duration'],
      releaseDate: parsedDate != null ? formatter.format(parsedDate) : '',
      posterUrl: json['PosterUrl'],
      trailerUrl: json['TrailerUrl'],
      age: json['Age'],
      subTitle: json['SubTitle'],
      voiceover: json['Voiceover'],
      genres: json['Genres'],
      cinemaName: json['CinemaName'],
      cinemaAddress: json['CinemaAddress'],
      reviewContents: json['ReviewContents'], // Có thể null
      averageRating: json['AverageRating'] != null
          ? (json['AverageRating'] as num).toDouble()
          : null, // Có thể null
      reviewCount: json['ReviewCount'],
      favourite: json['IsFavourite'],
      rating9_10: json['Rating_9_10'] ?? 0,
      rating7_8: json['Rating_7_8'] ?? 0,
      rating5_6: json['Rating_5_6'] ?? 0,
      rating3_4: json['Rating_3_4'] ?? 0,
      rating1_2: json['Rating_1_2'] ?? 0,
    );
  }

  // Hàm chuyển đổi thành JSON
  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ');
    return {
      'MovieID': movieId,
      'Title': title,
      'Description': description,
      'Duration': duration,
      'ReleaseDate': releaseDate, // Định dạng ngày tháng
      'PosterUrl': posterUrl,
      'TrailerUrl': trailerUrl,
      'Subtitle': subTitle,
      'Voiceover': voiceover,
      'Age': age,

      'Genres': genres,
      'CinemaName': cinemaName,
      'CinemaAddress': cinemaAddress,
      'ReviewContents': reviewContents, // Có thể null
      'AverageRating': averageRating, // Có thể null
      'ReviewCount': reviewCount,
      'IsFavourite': favourite,
      'Rating_9_10': rating9_10,
      'Rating_7_8': rating7_8,
      'Rating_5_6': rating5_6,
      'Rating_3_4': rating3_4,
      'Rating_1_2': rating1_2,
    };
  }

  MovieDetails copyWith({
    int? movieId,
    String? title,
    String? description,
    int? duration,
    String? releaseDate,
    String? posterUrl,
    String? trailerUrl,
    bool? subTitle,
    bool? voiceover,
    String? age,
    String? genres,
    String? cinemaName,
    String? cinemaAddress,
    String? reviewContents,
    double? averageRating,
    int? reviewCount,
    bool? favourite,
    int? rating9_10,
    int? rating7_8,
    int? rating5_6,
    int? rating3_4,
    int? rating1_2,
  }) {
    return MovieDetails(
      movieId: movieId ?? this.movieId,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      releaseDate: releaseDate ?? this.releaseDate,
      posterUrl: posterUrl ?? this.posterUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      subTitle: subTitle ?? this.subTitle,
      voiceover: voiceover ?? this.voiceover,
      genres: genres ?? this.genres,
      cinemaName: cinemaName ?? this.cinemaName,
      cinemaAddress: cinemaAddress ?? this.cinemaAddress,
      reviewContents: reviewContents ?? this.reviewContents,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      age: age ?? this.age,
      favourite: favourite ?? this.favourite,
      rating9_10: rating9_10 ?? this.rating9_10,
      rating7_8: rating7_8 ?? this.rating7_8,
      rating5_6: rating5_6 ?? this.rating5_6,
      rating3_4: rating3_4 ?? this.rating3_4,
      rating1_2: rating1_2 ?? this.rating1_2,
    );
  }
}
