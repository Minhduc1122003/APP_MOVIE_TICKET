import 'dart:convert';

import 'package:intl/intl.dart';

class WorkScheduleForCheckIn {
  final int scheduleId;
  final int userId;
  final int shiftId;
  final String startDate;
  final String endDate;
  final String daysOfWeek;
  final String createDate;
  final String shiftName;
  final String startTime;
  final String endTime;
  final String locationName;
  final String latitude;
  final String longitude;
  final double radius;

  WorkScheduleForCheckIn({
    required this.scheduleId,
    required this.userId,
    required this.shiftId,
    required this.startDate,
    required this.endDate,
    required this.daysOfWeek,
    required this.createDate,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  // Phương thức để tạo đối tượng từ JSON
  factory WorkScheduleForCheckIn.fromJson(Map<String, dynamic> json) {
    String formattedStartDate = _formatIsoToTime(json['StartDate']);
    String formattedEndDate = _formatIsoToTime(json['EndDate']);
    String formattedCreateDate = _formatIsoToDate(json['CreateDate']);
    String formattedStartTime = _formatIsoToTime(json['StartTime']);
    String formattedEndTime = _formatIsoToTime(json['EndTime']);
    return WorkScheduleForCheckIn(
      scheduleId: json['ScheduleId'],
      userId: json['UserId'],
      shiftId: json['ShiftId'],
      startDate: formattedStartDate,
      endDate: formattedEndDate,
      daysOfWeek: json['DaysOfWeek'],
      createDate: formattedCreateDate,
      shiftName: json['ShiftName'],
      startTime: formattedStartTime,
      endTime: formattedEndTime,
      locationName: json['LocationName'],
      latitude: json['Latitude'],
      longitude: json['Longitude'],
      radius: json['Radius'].toDouble(),
    );
  }

  // Phương thức để chuyển đổi đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'ScheduleId': scheduleId,
      'UserId': userId,
      'ShiftId': shiftId,
      'StartDate': startDate,
      'EndDate': endDate,
      'DaysOfWeek': daysOfWeek,
      'CreateDate': createDate,
      'ShiftName': shiftName,
      'StartTime': startTime,
      'EndTime': endTime,
      'LocationName': locationName,
      'Latitude': latitude,
      'Longitude': longitude,
      'Radius': radius,
    };
  }

  // Hàm chuyển đổi chuỗi ISO sang định dạng HH:mm cho thời gian
  static String _formatIsoToTime(String isoString) {
    DateTime dateTime = DateTime.parse(isoString);
    return DateFormat('HH:mm').format(dateTime);
  }

  // Hàm chuyển đổi chuỗi ISO sang định dạng dd/MM/yyyy cho ngày
  static String _formatIsoToDate(String isoString) {
    DateTime dateTime = DateTime.parse(isoString);
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}
