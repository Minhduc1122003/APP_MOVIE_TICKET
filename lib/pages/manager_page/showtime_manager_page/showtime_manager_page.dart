import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ShowtimeManagerPage extends StatefulWidget {
  const ShowtimeManagerPage({Key? key}) : super(key: key);

  @override
  _ShowtimeManagerPageState createState() => _ShowtimeManagerPageState();
}

class _ShowtimeManagerPageState extends State<ShowtimeManagerPage> {
  final List<String> cinemas = [
    'Phòng 1',
    'Phòng 2',
    'Phòng 3',
    'Phòng 4',
    'Phòng 5',
    'Phòng 6'
  ];
  final List<String> timeSlots = [];
  final List<List<String>> showtimes = [];
  final ScrollController _verticalController1 = ScrollController();
  final ScrollController _verticalController2 = ScrollController();
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _showtimeHorizontalController = ScrollController();

  bool isSearching = false;
  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _initializeTimeSlots();
    _initializeShowtimes();

    // Vertical scroll synchronization
    _verticalController1.addListener(() {
      if (_verticalController2.hasClients) {
        _verticalController2.jumpTo(_verticalController1.offset);
      }
    });
    _verticalController2.addListener(() {
      if (_verticalController1.hasClients) {
        _verticalController1.jumpTo(_verticalController2.offset);
      }
    });

    // Horizontal scroll synchronization
    _headerHorizontalController.addListener(() {
      if (_showtimeHorizontalController.hasClients) {
        _showtimeHorizontalController
            .jumpTo(_headerHorizontalController.offset);
      }
    });

    _showtimeHorizontalController.addListener(() {
      if (_headerHorizontalController.hasClients) {
        _headerHorizontalController
            .jumpTo(_showtimeHorizontalController.offset);
      }
    });
  }

  @override
  void dispose() {
    _verticalController1.dispose();
    _verticalController2.dispose();
    _headerHorizontalController.dispose();
    _showtimeHorizontalController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
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

  void _onSearchChanged(String value) {
    setState(() {
      _searchTerm = value.toLowerCase(); // Store the search term in lower case
    });
  }

  List<List<String>> _filteredShowtimes() {
    if (_searchTerm.isEmpty) {
      return showtimes;
    } else {
      return showtimes.map((row) {
        return row.where((showtime) {
          return showtime.toLowerCase().contains(_searchTerm);
        }).toList();
      }).toList();
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
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                child: child,
              ),
            );
          },
          child: isSearching || _searchController.text.isNotEmpty
              ? TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm lịch chiếu...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(color: Colors.black),
                )
              : const Text(
                  'Lịch chiếu phim',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 20),
            onPressed: () {
              setState(() {
                if (isSearching || _searchController.text.isNotEmpty) {
                  _searchController.clear();
                  _searchTerm = ''; // Clear search term
                  isSearching = false;
                } else {
                  isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            _buildTimeSlotHeader(),
                            Expanded(
                              child: _buildHeaderRow(),
                            ),
                          ],
                        ),
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
            child: Align(
              alignment: Alignment.bottomRight,
              child: SpeedDial(
                icon: Icons.add,
                activeIcon: Icons.close,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                activeBackgroundColor: Colors.red,
                activeForegroundColor: Colors.white,
                visible: true,
                closeManually: false,
                curve: Curves.bounceIn,
                overlayColor: Colors.black,
                overlayOpacity: 0.5,
                onOpen: () => print('OPENING DIAL'),
                onClose: () => print('DIAL CLOSED'),
                elevation: 8.0,
                shape: CircleBorder(),
                children: [
                  SpeedDialChild(
                    child: Icon(Icons.calendar_today),
                    backgroundColor: Colors.green,
                    label: 'Thêm lịch',
                    labelStyle: TextStyle(fontSize: 15.0),
                    onTap: () => print('Thêm lịch'),
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.edit),
                    backgroundColor: Colors.orange,
                    label: 'Sửa lịch',
                    labelStyle: TextStyle(fontSize: 15.0),
                    onTap: () => print('Sửa lịch'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, Color color) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15.0, left: 20, right: 20),
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(icon, color: Colors.white),
          label: Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  // Fixed header for time slots
  Widget _buildTimeSlotHeader() {
    return Container(
      width: 80,
      color: Colors.grey[200],
      padding: const EdgeInsets.all(6.0),
      alignment: Alignment.center,
      child: const Text(
        'Khung giờ',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHeaderRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _headerHorizontalController,
      child: Row(
        children: cinemas.map((cinema) {
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
      ),
    );
  }

  Widget _buildTimeColumn() {
    return SingleChildScrollView(
      controller: _verticalController1,
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
      controller: _showtimeHorizontalController,
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        controller: _verticalController2,
        child: Column(
          children: _filteredShowtimes().map((row) {
            return Row(
              children: row.map((showtime) {
                return Container(
                  width: 120,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text(showtime,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black)),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
