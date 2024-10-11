class ShowtimeforadminModel {
  final String movieName;
  final DateTime showtimeDate;
  final String startTime;
  final int movieDuration;
  final int roomNumber;
  final String cinemaName;

  ShowtimeforadminModel({
    required this.movieName,
    required this.showtimeDate,
    required this.startTime,
    required this.movieDuration,
    required this.roomNumber,
    required this.cinemaName,
  });

  factory ShowtimeforadminModel.fromJson(Map<String, dynamic> json) {
    return ShowtimeforadminModel(
      movieName: json['MovieName'],
      showtimeDate: DateTime.parse(json['ShowtimeDate']),
      startTime: json['StartTime'],
      movieDuration: json['MovieDuration'],
      roomNumber: json['RoomNumber'],
      cinemaName: json['CinemaName'],
    );
  }
}
