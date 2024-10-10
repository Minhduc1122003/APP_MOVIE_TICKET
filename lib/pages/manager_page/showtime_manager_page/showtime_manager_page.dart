import 'package:flutter/material.dart';

class ShowtimeManagerPage extends StatefulWidget {
  const ShowtimeManagerPage({Key? key}) : super(key: key);

  @override
  _ShowtimeManagerPageState createState() => _ShowtimeManagerPageState();
}

class _ShowtimeManagerPageState extends State<ShowtimeManagerPage> {
  final List<String> cinemas = [
    'Rạp 1',
    'Rạp 2',
    'Rạp 3',
    'Rạp 4',
    'Rạp 5',
    'Rạp 6'
  ];
  final List<String> timeSlots = [];
  final List<List<String>> showtimes = [];
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeTimeSlots();
    _initializeShowtimes();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  void _initializeTimeSlots() {
    DateTime startTime = DateTime(2024, 1, 1, 8, 0);
    DateTime endTime = DateTime(2024, 1, 2, 0, 0);
    while (startTime.isBefore(endTime)) {
      timeSlots.add(
          "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}");
      startTime = startTime.add(const Duration(minutes: 30));
    }
  }

  void _initializeShowtimes() {
    for (int i = 0; i < timeSlots.length; i++) {
      List<String> row = [];
      for (int j = 0; j < cinemas.length; j++) {
        row.add('Phim ${j + 1}\n${timeSlots[i]}');
      }
      showtimes.add(row);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0XFF6F3CD7),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 16,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Lịch chiếu phim',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          height: 400,
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: _buildHeaderRow(),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: _buildTimeColumn(),
                    ),
                    Expanded(
                      child: _buildShowtimeGrid(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _horizontalController,
      child: Row(
        children: [
          Container(
            width: 80,
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: const Text(
              'Khung giờ',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          ...cinemas.map((cinema) {
            return Container(
              width: 120,
              color: Colors.grey[200],
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                cinema,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimeColumn() {
    return SingleChildScrollView(
      controller: _verticalController,
      child: Column(
        children: timeSlots.map((timeSlot) {
          return Container(
            height: 60,
            color: Colors.grey[100],
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(
              timeSlot,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShowtimeGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _horizontalController,
      child: SingleChildScrollView(
        controller: _verticalController,
        child: Column(
          children: List.generate(timeSlots.length, (rowIndex) {
            return Row(
              children: List.generate(cinemas.length, (colIndex) {
                return Container(
                  width: 120,
                  height: 60,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Text(
                    showtimes[rowIndex][colIndex],
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
