import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilmSapchieuStaff extends StatefulWidget {
  const FilmSapchieuStaff({Key? key}) : super(key: key);

  @override
  _FilmSapchieuStaffState createState() => _FilmSapchieuStaffState();
}

class _FilmSapchieuStaffState extends State<FilmSapchieuStaff> {
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [],
          ),
        ),
      ],
    );
  }
}
