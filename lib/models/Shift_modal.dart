import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Shift {
  int? shiftId;
  String shiftName;
  String startTime; // Thời gian bắt đầu dưới dạng HH:mm
  String endTime; // Thời gian kết thúc dưới dạng HH:mm
  bool isCrossDay;
  String? createDate; // Ngày tạo dưới dạng dd/MM/yyyy
  String status;

  Shift({
    this.shiftId,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.isCrossDay,
    this.createDate,
    required this.status,
  });

  // Phương thức để tạo một đối tượng Shift từ Map (ví dụ: từ JSON)
  factory Shift.fromMap(Map<String, dynamic> json) {
    // Chuyển chuỗi ISO thành DateTime và định dạng lại
    String formattedStartTime = _formatIsoToTime(json['StartTime']);
    String formattedEndTime = _formatIsoToTime(json['EndTime']);
    String formattedCreateDate = _formatIsoToDate(json['CreateDate']);

    return Shift(
      shiftId: json['ShiftId'],
      shiftName: json['ShiftName'],
      startTime: formattedStartTime,
      endTime: formattedEndTime,
      isCrossDay: json['IsCrossDay'] == true,
      createDate: formattedCreateDate,
      status: json['Status'],
    );
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
