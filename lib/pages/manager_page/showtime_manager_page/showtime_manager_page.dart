import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/models/showTimeForAdmin_model.dart';
import 'package:flutter_app_chat/pages/manager_page/showtime_manager_page/showtime_edit_manager_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ShowtimeManagerPage extends StatefulWidget {
  const ShowtimeManagerPage({Key? key}) : super(key: key);

  @override
  _ShowtimeManagerPageState createState() => _ShowtimeManagerPageState();
}

class _ShowtimeManagerPageState extends State<ShowtimeManagerPage> {
  List<String> cinemas = []; // Initialize as an empty list
  final List<String> timeSlots = [];
  final List<List<String>> showtimes = [];
  final ScrollController _verticalController1 = ScrollController();
  final ScrollController _verticalController2 = ScrollController();
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _showtimeHorizontalController = ScrollController();
  ApiService apiService = ApiService();
  List<ShowtimeforadminModel> listShowtimeforadminModel = [];
  bool isSearching = false;
  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  String _searchTerm = '';

  bool _isVerticalSyncing = false;
  bool _isHorizontalSyncing = false;

  @override
  void initState() {
    super.initState();
    _fetchShowtimes();
    // Synchronize scroll controllers
    _setupScrollSynchronization();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchTerm = value.toLowerCase(); // Store the search term in lowercase
    });
  }

  List<List<String>> _filteredShowtimes() {
    if (_searchTerm.isEmpty) {
      return showtimes;
    } else {
      return showtimes.map((row) {
        return row.map((showtime) {
          if (showtime.toLowerCase().contains(_searchTerm)) {
            return showtime;
          } else {
            return ''; // Return an empty string if the showtime doesn't match the search term
          }
        }).toList();
      }).toList();
    }
  }

  void _setupScrollSynchronization() {
    // Vertical scroll synchronization
    _verticalController1.addListener(() {
      if (_isVerticalSyncing) return;
      _isVerticalSyncing = true;
      if (_verticalController2.hasClients) {
        _verticalController2.jumpTo(_verticalController1.offset);
      }
      _isVerticalSyncing = false;
    });

    _verticalController2.addListener(() {
      if (_isVerticalSyncing) return;
      _isVerticalSyncing = true;
      if (_verticalController1.hasClients) {
        _verticalController1.jumpTo(_verticalController2.offset);
      }
      _isVerticalSyncing = false;
    });

    // Horizontal scroll synchronization
    _headerHorizontalController.addListener(() {
      if (_isHorizontalSyncing) return;
      _isHorizontalSyncing = true;
      if (_showtimeHorizontalController.hasClients) {
        _showtimeHorizontalController
            .jumpTo(_headerHorizontalController.offset);
      }
      _isHorizontalSyncing = false;
    });

    _showtimeHorizontalController.addListener(() {
      if (_isHorizontalSyncing) return;
      _isHorizontalSyncing = true;
      if (_headerHorizontalController.hasClients) {
        _headerHorizontalController
            .jumpTo(_showtimeHorizontalController.offset);
      }
      _isHorizontalSyncing = false;
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

  void _initializeCinemas(List<ShowtimeforadminModel> apiData) {
    Set<String> uniqueCinemas = {};
    for (var showtime in apiData) {
      uniqueCinemas.add('Phòng ${showtime.RoomNumber}');
    }
    cinemas.clear();
    cinemas.addAll(uniqueCinemas.toList()..sort());
  }

  void _initializeTimeSlots(List<ShowtimeforadminModel> apiData) {
    Set<String> uniqueTimeSlots = {};
    for (var showtime in apiData) {
      String timeSlot =
          "${showtime.StartTime.hour.toString().padLeft(2, '0')}:${showtime.StartTime.minute.toString().padLeft(2, '0')}";
      uniqueTimeSlots.add(timeSlot);
    }
    timeSlots.clear();
    timeSlots.addAll(uniqueTimeSlots.toList()..sort());
  }

  void _processApiData(List<ShowtimeforadminModel> apiData) {
    _initializeCinemas(apiData);
    _initializeTimeSlots(apiData);
    showtimes.clear();

    for (String timeSlot in timeSlots) {
      List<String> row = List.filled(cinemas.length, '');

      for (var showtime in apiData) {
        String showtimeSlot =
            "${showtime.StartTime.hour.toString().padLeft(2, '0')}:${showtime.StartTime.minute.toString().padLeft(2, '0')}";

        if (showtimeSlot == timeSlot) {
          int roomIndex = cinemas.indexOf('Phòng ${showtime.RoomNumber}');
          if (roomIndex >= 0 && roomIndex < cinemas.length) {
            row[roomIndex] = '${showtime.MovieName}\n$showtimeSlot';
          }
        }
      }

      // Only add non-empty rows
      if (row.any((showtime) => showtime.isNotEmpty)) {
        showtimes.add(row);
      }
    }

    // Remove empty columns (rooms)
    _removeEmptyRooms();
  }

  void _removeEmptyRooms() {
    // Determine which rooms have showtimes
    List<bool> hasShowtime = List.filled(cinemas.length, false);

    for (var row in showtimes) {
      for (int i = 0; i < row.length; i++) {
        if (row[i].isNotEmpty) {
          hasShowtime[i] = true;
        }
      }
    }

    // Filter out rooms that have no showtimes
    List<String> filteredCinemas = [];
    for (int i = 0; i < cinemas.length; i++) {
      if (hasShowtime[i]) {
        filteredCinemas.add(cinemas[i]);
      }
    }
    cinemas = filteredCinemas;

    // Update showtimes to remove empty columns
    for (int i = 0; i < showtimes.length; i++) {
      showtimes[i] = showtimes[i]
          .asMap()
          .entries
          .where((entry) => hasShowtime[entry.key])
          .map((entry) => entry.value)
          .toList();
    }
  }

  Future<void> _fetchShowtimes() async {
    try {
      final fetchedShowtimes = await apiService.getShowtimeListForAdmin();

      // Kiểm tra nếu dữ liệu trả về là mảng rỗng
      if (fetchedShowtimes.isEmpty) {
        print('đã vào mảng null');
        cinemas = List.generate(6, (index) => 'Phòng ${index + 1}');

        // Thiết lập khung giờ mặc định
        timeSlots.clear();
        timeSlots.addAll(['09:00', '09:30', '10:00', '10:30']);

        showtimes.clear(); // Xóa nội dung hiện tại
        for (String timeSlot in timeSlots) {
          List<String> row =
              List.filled(cinemas.length, ''); // Tạo hàng rỗng cho mỗi phòng
          showtimes.add(row); // Thêm hàng vào showtimes
        }
      } else {
        setState(() {
          listShowtimeforadminModel =
              fetchedShowtimes; // Cập nhật dữ liệu từ API
          _processApiData(fetchedShowtimes); // Xử lý dữ liệu
        });
      }
    } catch (e) {
      print('Error fetching showtimes: $e');
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
                  onChanged: _onSearchChanged, // Use the defined method here
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
                SizedBox(
                  height: 80,
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
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideFromRightPageRoute(
                          page: ShowtimeEditManagerPage(),
                        ),
                      );
                    },
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
      height: 60, // Set a fixed height for the header
      color: Colors.grey[200],
      child: CustomPaint(
        painter: DiagonalPainter(),
        child: const Padding(
          padding: EdgeInsets.all(6.0),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  width: 30, // Set the maximum width for the text
                  child: AutoSizeText(
                    'Giờ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    maxFontSize: 12,
                    minFontSize: 1,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 30, // Set the maximum width for the text
                  child: AutoSizeText(
                    'Phòng',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    maxFontSize: 12,
                    minFontSize: 1,
                  ),
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
      controller: _headerHorizontalController,
      child: Row(
        children: cinemas.map((cinema) {
          return Row(
            children: [
              Container(
                width:
                    120, // Ensure this width matches the showtime grid item width
                color: Colors.grey[200],
                padding: const EdgeInsets.all(3.0),
                alignment: Alignment.center,
                child: Text(
                  cinema,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              // Add a vertical divider only if it's not the last item
              if (cinema != cinemas.last)
                const VerticalDivider(
                  width: 1,
                  color: Colors.grey,
                  thickness: 1, // Ensure the thickness is consistent
                ),
            ],
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
          return Column(
            children: [
              Container(
                height: 40,
                color: Colors.grey[100],
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Text(
                  timeSlot,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(height: 1, color: Colors.grey), // Add divider here
            ],
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
        scrollDirection: Axis.vertical,
        child: Column(
          children: _filteredShowtimes().map((row) {
            return Row(
              children: row.map((showtime) {
                return Container(
                  width:
                      121, // Ensure this width matches the header row item width
                  height: 41,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey),
                      right: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: AutoSizeText(
                    showtime,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black),
                    maxLines: 1,
                    maxFontSize: 15,
                    minFontSize: 10,
                    overflow: TextOverflow.clip,
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

class DiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    // Draw a diagonal line from top-left to bottom-right
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
