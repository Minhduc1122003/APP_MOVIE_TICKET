import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimekeepingHistoryCalendar extends StatefulWidget {
  const TimekeepingHistoryCalendar({Key? key}) : super(key: key);

  @override
  _TimekeepingHistoryCalendarState createState() =>
      _TimekeepingHistoryCalendarState();
}

class _TimekeepingHistoryCalendarState
    extends State<TimekeepingHistoryCalendar> {
  late DateTime _currentDate;
  final List<String> _weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLegend(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildCalendar(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(Icons.check_circle, Colors.green, 'Đủ công'),
          _buildLegendItem(Icons.access_time, Colors.blue, 'Nửa công'),
          _buildLegendItem(Icons.cancel, Colors.red, 'Vắng mặt'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 5),
        Text(text),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: _previousMonth,
          ),
          Text(
            DateFormat('MMMM yyyy').format(_currentDate),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    int totalDays = _daysInMonth(_currentDate);
    int firstWeekday =
        DateTime(_currentDate.year, _currentDate.month, 1).weekday - 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index < 7) {
          return _buildWeekdayCell(_weekDays[index]);
        }
        final day = index - 6 - firstWeekday;
        if (day < 1 || day > totalDays) {
          return Container(); // Ô trống
        }
        final date = DateTime(_currentDate.year, _currentDate.month, day);
        return _buildDayCell(date);
      },
      itemCount: totalDays + 7 + firstWeekday,
    );
  }

  Widget _buildWeekdayCell(String weekDay) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        weekDay,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isToday = _isToday(date);
    final attendanceStatus = _getAttendanceStatus(date);

    IconData? icon;
    Color? iconColor;

    switch (attendanceStatus) {
      case 1:
        icon = Icons.access_time;
        iconColor = Colors.blue;
        break;
      case 2:
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 3:
        icon = Icons.cancel;
        iconColor = Colors.red;
        break;
      default:
        icon = null;
        break;
    }

    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getCellColor(date),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              color: isToday ? Colors.white : Colors.black,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(
                icon,
                color: iconColor,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Color _getCellColor(DateTime date) {
    if (_isToday(date)) return Colors.blue;
    if (date.weekday == DateTime.sunday) return Colors.red[100]!;
    return Colors.transparent;
  }

  int _getAttendanceStatus(DateTime date) {
    final now = DateTime.now();

    if (date.isBefore(DateTime(now.year, now.month, now.day))) {
      if (date.day % 2 == 0) return 2;
      if (date.day % 5 == 0) return 1;
      if (date.day % 7 == 0) return 3;
      return 3;
    }
    return 0;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }
}
