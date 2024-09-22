import 'package:intl/intl.dart';

class ShowTimeDetails {
  final String movieTitle;
  final int movieDuration;
  final int cinemaRoomID;
  final DateTime showtimeDate;
  final DateTime startTime;
  final DateTime endTime;

  ShowTimeDetails({
    required this.movieTitle,
    required this.movieDuration,
    required this.cinemaRoomID,
    required this.showtimeDate,
    required this.startTime,
    required this.endTime,
  });
  factory ShowTimeDetails.fromJson(Map<String, dynamic> json) {
    return ShowTimeDetails(
      movieTitle: json['MovieTitle'],
      movieDuration: json['MovieDuration'],
      cinemaRoomID: json['CinemaRoomID'],
      showtimeDate: DateTime.parse(json['ShowtimeDate']),
      startTime: DateTime.parse(json['StartTime']),
      endTime: DateTime.parse(json['EndTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MovieTitle': movieTitle,
      'MovieDuration': movieDuration,
      'CinemaRoomID': cinemaRoomID,
      'ShowtimeDate': showtimeDate.toIso8601String(),
      'StartTime': startTime.toIso8601String(),
      'EndTime': endTime.toIso8601String(),
    };
  }

  String getFormattedDate() {
    return DateFormat('dd/MM/yyyy').format(showtimeDate);
  }

  String getFormattedTime() {
    return DateFormat('HH:mm').format(startTime);
  }

  String getFormattedEndTime() {
    // Phương thức định dạng thời gian kết thúc
    return DateFormat('HH:mm').format(endTime);
  }
}
