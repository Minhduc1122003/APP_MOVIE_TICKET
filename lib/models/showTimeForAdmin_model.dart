class ShowtimeforadminModel {
  final String MovieName;
  final DateTime ShowtimeDate;
  final DateTime StartTime;
  final int MovieDuration;
  final int RoomNumber;
  final String CinemaName;

  ShowtimeforadminModel({
    required this.MovieName,
    required this.ShowtimeDate,
    required this.StartTime,
    required this.MovieDuration,
    required this.RoomNumber,
    required this.CinemaName,
  });

  factory ShowtimeforadminModel.fromJson(Map<String, dynamic> json) {
    return ShowtimeforadminModel(
      MovieName: json['MovieName'],
      ShowtimeDate: DateTime.parse(json['ShowtimeDate']),
      StartTime: DateTime.parse(json['StartTime']),
      MovieDuration: json['MovieDuration'],
      RoomNumber: json['RoomNumber'],
      CinemaName: json['CinemaName'],
    );
  }
}
