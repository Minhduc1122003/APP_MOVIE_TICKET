import 'package:intl/intl.dart';

class BuyTicket {
  final String buyTicketId;
  final String createDate;
  final double totalPrice;
  final String status;
  final bool isCheckIn;
  final int movieID;
  final String movieName;
  final String posterUrl;
  final String showtimeDate;
  final String startTime;
  final String cinemaName;
  final int cinemaRoomId;
  final String seatNumbers;
  final double totalTicketPrice;
  final double totalComboPrice;
  final String comboDetails;

  BuyTicket({
    required this.buyTicketId,
    required this.createDate,
    required this.totalPrice,
    required this.status,
    required this.isCheckIn,
    required this.movieID,
    required this.movieName,
    required this.posterUrl,
    required this.showtimeDate,
    required this.startTime,
    required this.cinemaName,
    required this.cinemaRoomId,
    required this.seatNumbers,
    required this.totalTicketPrice,
    required this.totalComboPrice,
    required this.comboDetails,
  });

  factory BuyTicket.fromJson(Map<String, dynamic> json) {
    return BuyTicket(
      buyTicketId: json['BuyTicketId'] ?? '', // Default to empty string
      createDate: json['CreateDate'] ?? '', // Default to empty string
      totalPrice: (json['TotalPrice'] as num?)?.toDouble() ??
          0.0, // Handle int and double
      status: json['Status'] ?? '',
      isCheckIn: json['IsCheckIn'] ?? false, // Default to false
      movieID: json['MovieID'] ?? 0,
      movieName: json['MovieName'] ?? '',
      posterUrl: json['PosterUrl'] ?? '',
      showtimeDate: json['ShowtimeDate'] != null
          ? DateFormat('dd/MM/yyyy')
              .format(DateTime.parse(json['ShowtimeDate']))
          : '',
      startTime: json['StartTime'] != null
          ? DateFormat('HH:mm').format(DateTime.parse(json['StartTime']))
          : '',
      cinemaName: json['CinemaName'] ?? '',
      cinemaRoomId: json['CinemaRoomID'] ?? 0, // Default to 0
      seatNumbers: json['SeatNumbers'] ?? '',
      totalTicketPrice: (json['TotalTicketPrice'] as num?)?.toDouble() ??
          0.0, // Handle int and double
      totalComboPrice: (json['TotalComboPrice'] as num?)?.toDouble() ??
          0.0, // Handle int and double
      comboDetails: json['ComboDetails'] ?? '',
    );
  }
}
