import 'package:intl/intl.dart';

class Attendance {
  final int attendanceId;
  final int userId;
  final int shiftId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String latitude;
  final String longitude;
  final String location;
  final bool isLate;
  final bool isEarlyLeave;
  final DateTime createDate;
  final String status;
  final String shiftName;
  final String shiftStartTime;
  final String shiftEndTime;

  Attendance({
    required this.attendanceId,
    required this.userId,
    required this.shiftId,
    required this.checkInTime,
    this.checkOutTime,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.isLate,
    required this.isEarlyLeave,
    required this.createDate,
    required this.status,
    required this.shiftName,
    required this.shiftStartTime,
    required this.shiftEndTime,
  });

  // Phương thức để parse từ JSON
  factory Attendance.fromJson(Map<String, dynamic> json) {
    String formattedStartTime = _formatIsoToTime(json['ShiftStartTime']);
    String formattedEndTime = _formatIsoToTime(json['ShiftEndTime']);

    return Attendance(
      attendanceId: json['AttendanceId'],
      userId: json['UserId'],
      shiftId: json['ShiftId'],
      checkInTime: DateTime.parse(json['CheckInTime']),
      checkOutTime: json['CheckOutTime'] != null
          ? DateTime.parse(json['CheckOutTime'])
          : null,
      latitude: json['Latitude'],
      longitude: json['Longitude'],
      location: json['Location'],
      isLate: json['IsLate'],
      isEarlyLeave: json['IsEarlyLeave'],
      createDate: DateTime.parse(json['CreateDate']),
      status: json['Status'],
      shiftName: json['ShiftName'],
      shiftStartTime: formattedStartTime,
      shiftEndTime: formattedEndTime,
    );
  }

  // Phương thức để chuyển đổi sang JSON (nếu cần)
  Map<String, dynamic> toJson() {
    return {
      'AttendanceId': attendanceId,
      'UserId': userId,
      'ShiftId': shiftId,
      'CheckInTime': checkInTime.toIso8601String(),
      'CheckOutTime': checkOutTime?.toIso8601String(),
      'Latitude': latitude,
      'Longitude': longitude,
      'Location': location,
      'IsLate': isLate,
      'IsEarlyLeave': isEarlyLeave,
      'CreateDate': createDate.toIso8601String(),
      'Status': status,
      'ShiftName': shiftName,
      'ShiftStartTime': shiftStartTime,
      'ShiftEndTime': shiftEndTime,
    };
  }

  // Hàm format ISO string thành giờ (HH:mm)
  static String _formatIsoToTime(String isoString) {
    DateTime dateTime = DateTime.parse(isoString);
    return DateFormat('HH:mm').format(dateTime); // Định dạng giờ (HH:mm)
  }

  // Hàm format ISO string thành ngày (dd/MM/yyyy)
  static String _formatIsoToDate(String isoString) {
    DateTime dateTime = DateTime.parse(isoString);
    return DateFormat('dd/MM/yyyy')
        .format(dateTime); // Định dạng ngày (dd/MM/yyyy)
  }
}
