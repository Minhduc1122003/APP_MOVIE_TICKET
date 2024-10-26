import 'package:intl/intl.dart';

class LocationWithShift {
  final int locationId;
  final String locationName;
  final String latitude; // Keeping as String to match the JSON structure
  final String longitude; // Keeping as String to match the JSON structure
  final double radius;
  final int shiftId;
  final String shiftName;
  final String startTime; // Keeping as String to match the JSON structure
  final String endTime; // Keeping as String to match the JSON structure
  final bool isCrossDay;
  String? createDate; // Ngày tạo dưới dạng dd/MM/yyyy
  final String status;

  LocationWithShift({
    required this.locationId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.shiftId,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.isCrossDay,
    required this.createDate,
    required this.status,
  });

  // Factory constructor to create a LocationWithShift instance from a JSON map
  factory LocationWithShift.fromJson(Map<String, dynamic> json) {
    String formattedStartTime = _formatIsoToTime(json['StartTime']);
    String formattedEndTime = _formatIsoToTime(json['EndTime']);
    String formattedCreateDate = _formatIsoToDate(json['CreateDate']);
    return LocationWithShift(
      locationId: json['LocationId'],
      locationName: json['LocationName'],
      latitude: json['Latitude'],
      longitude: json['Longitude'],
      radius: json['Radius'].toDouble(), // Convert to double
      shiftId: json['ShiftId'],
      shiftName: json['ShiftName'],
      startTime: formattedStartTime,
      endTime: formattedEndTime,
      isCrossDay: json['IsCrossDay'],
      createDate: formattedCreateDate,
      status: json['Status'],
    );
  }

  // Method to convert a LocationWithShift instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'LocationId': locationId,
      'LocationName': locationName,
      'Latitude': latitude,
      'Longitude': longitude,
      'Radius': radius,
      'ShiftId': shiftId,
      'ShiftName': shiftName,
      'StartTime': startTime,
      'EndTime': endTime,
      'IsCrossDay': isCrossDay,
      'CreateDate': createDate, // Convert DateTime to ISO string
      'Status': status,
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
