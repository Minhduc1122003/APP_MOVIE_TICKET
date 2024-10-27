class WorkSchedule {
  final int scheduleId;
  final int userId;
  final int shiftId;
  final DateTime startDate;
  final DateTime endDate;
  final String daysOfWeek;
  final DateTime createDate;

  WorkSchedule({
    required this.scheduleId,
    required this.userId,
    required this.shiftId,
    required this.startDate,
    required this.endDate,
    required this.daysOfWeek,
    required this.createDate,
  });

  // Factory method to create WorkSchedule from JSON
  factory WorkSchedule.fromJson(Map<String, dynamic> json) {
    return WorkSchedule(
      scheduleId: json['ScheduleId'],
      userId: json['UserId'],
      shiftId: json['ShiftId'],
      startDate: DateTime.parse(json['StartDate']),
      endDate: DateTime.parse(json['EndDate']),
      daysOfWeek: json['DaysOfWeek'],
      createDate: DateTime.parse(json['CreateDate']),
    );
  }

  // Method to convert WorkSchedule to JSON
  Map<String, dynamic> toJson() {
    return {
      'ScheduleId': scheduleId,
      'UserId': userId,
      'ShiftId': shiftId,
      'StartDate': startDate.toIso8601String(),
      'EndDate': endDate.toIso8601String(),
      'DaysOfWeek': daysOfWeek,
      'CreateDate': createDate.toIso8601String(),
    };
  }
}
