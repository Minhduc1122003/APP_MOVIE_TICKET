class ChairModel {
  final int seatID;
  final int cinemaRoomID;
  final String chairCode;
  final bool defectiveChair;
  final bool reservationStatus;

  ChairModel({
    required this.seatID,
    required this.cinemaRoomID,
    required this.chairCode,
    required this.defectiveChair,
    required this.reservationStatus,
  });

  // Phương thức để tạo đối tượng từ JSON
  factory ChairModel.fromJson(Map<String, dynamic> json) {
    return ChairModel(
      seatID: json['SeatID'],
      cinemaRoomID: json['CinemaRoomID'],
      chairCode: json['ChairCode'],
      defectiveChair: json['DefectiveChair'],
      reservationStatus: json['ReservationStatus'],
    );
  }

  // Phương thức để chuyển đổi đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'SeatID': seatID,
      'CinemaRoomID': cinemaRoomID,
      'ChairCode': chairCode,
      'DefectiveChair': defectiveChair,
      'ReservationStatus': reservationStatus,
    };
  }
}
