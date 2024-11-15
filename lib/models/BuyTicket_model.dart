import 'dart:convert';

import 'package:intl/intl.dart';

class BuyTicket {
  final String buyTicketId;
  final DateTime createDate;
  final double totalPrice;
  final String status;
  final bool isCheckIn;
  final String movieName;
  final String posterUrl;
  final String showtimeDate;
  final String startTime;
  final String cinemaName;
  final int cinemaRoomId;
  final String seatNumbers;
  final int totalTicketPrice;
  final int totalComboPrice;
  final String comboDetails;

  BuyTicket({
    required this.buyTicketId,
    required this.createDate,
    required this.totalPrice,
    required this.status,
    required this.isCheckIn,
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
      buyTicketId: json['BuyTicketId'] ?? '', // Giá trị mặc định là chuỗi rỗng
      createDate: json['CreateDate'] != null
          ? DateTime.parse(json['CreateDate'])
          : DateTime.now(), // Giá trị mặc định là thời gian hiện tại
      totalPrice: json['TotalPrice'] ?? 0, // Giá trị mặc định là 0
      status: json['Status'] ?? '',
      isCheckIn: json['IsCheckIn'] ?? false, // Giá trị mặc định là false
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
      cinemaRoomId: json['CinemaRoomID'] ?? 0, // Giá trị mặc định là 0
      seatNumbers: json['SeatNumbers'] ?? '',
      totalTicketPrice: json['TotalTicketPrice'] ?? 0,
      totalComboPrice: json['TotalComboPrice'] ?? 0,
      comboDetails: json['ComboDetails'] ?? '',
    );
  }
}
