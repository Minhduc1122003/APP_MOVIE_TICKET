import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/showTimeForAdmin_model.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ShowtimeEditManagerPage extends StatefulWidget {
  const ShowtimeEditManagerPage({Key? key}) : super(key: key);

  @override
  _ShowtimeEditManagerPageState createState() =>
      _ShowtimeEditManagerPageState();
}

class _ShowtimeEditManagerPageState extends State<ShowtimeEditManagerPage> {
  List<String> cinemas = []; // Initialize as an empty list
  late List<String> timeSlots = [];
  late List<List<String>> showtimes = [];
  final ScrollController _verticalController1 = ScrollController();
  late ScrollController _verticalController2 = ScrollController();
  final ScrollController _headerHorizontalController = ScrollController();
  late ScrollController _showtimeHorizontalController = ScrollController();
  ApiService apiService = ApiService();
  List<ShowtimeforadminModel> listShowtimeforadminModel = [];
  bool isSearching = false;
  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  String _searchTerm = '';

  bool _isVerticalSyncing = false;
  bool _isHorizontalSyncing = false;
  late Future<List<MovieDetails>> _moviesFuture;
  int? selectedRowIndex; // Biến để lưu chỉ số hàng đã chọn
  int? selectedShowtimeIndex; // Biến để lưu chỉ số showtime đã chọn
  @override
  void initState() {
    super.initState();
    _fetchShowtimes();
    // Synchronize scroll controllers
    _setupScrollSynchronization();
    _verticalController2 = ScrollController();
    _showtimeHorizontalController = ScrollController();
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
                  child: SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 60,
                          child: _buildTimeColumn(),
                        ),
                        Expanded(
                          child: _buildShowtimeGrid(),
                        ),
                      ],
                    ),
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
                    onTap: () => print('Sửa '),
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
      width: 60,
      height: 50, // Set a fixed height for the header
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
                  thickness: 1,
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
                height: 50,
                color: Colors.grey[100],
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.topCenter,
                child: Center(
                  child: Text(
                    timeSlot,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Divider(height: 1, color: Colors.grey), // Add divider here
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _fetchShowtimes() async {
    try {
      final fetchedShowtimes = await apiService.getShowtimeListForAdmin();

      // Kiểm tra nếu dữ liệu trả về là mảng rỗng
      if (fetchedShowtimes.isEmpty) {
        print('đã vào mảng null');
        _moviesFuture = apiService.getMoviesDangChieu();

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

        // Gọi setState để cập nhật giao diện
        setState(() {});
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

  DateTime? startTime;
  int movieDurationInMinutes = 0;

  int _roundMinutesUp(int minutes) {
    int roundedToFive = ((minutes + 4) ~/ 5) * 5;
    return roundedToFive + 15;
  }

  List<AddedRow> addedRows = [];

  List<int> generatedTimeSlotIndices =
      []; // Danh sách lưu trữ chỉ số khung giờ đã được sinh ra

  void _showMoviesBottomSheet(BuildContext context, int rowIndex,
      int showtimeIndex, Function(MovieDetails) onMovieSelected) {
    if (rowIndex >= showtimes.length || showtimeIndex >= cinemas.length) {
      print(
          'Chỉ số không hợp lệ: rowIndex=$rowIndex, showtimeIndex=$showtimeIndex');
      return;
    }

    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              child: FutureBuilder<List<MovieDetails>>(
                future: _moviesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Không có phim nào.'));
                  }

                  final movies = snapshot.data!;
                  return Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Container(
                          width: 50,
                          height: 6,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Danh sách phim',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Divider(),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: movies.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            final movie = movies[index];
                            return ListTile(
                              leading: Image.asset(
                                'assets/images/${movie.posterUrl}',
                                width: 30,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                              title: Text(movie.title),
                              subtitle: Text('Thể loại: ${movie.genres}'),
                              trailing: Text('${movie.duration} phút'),
                              onTap: () {
                                print(
                                    'Đã chọn phim cho: rowIndex=$rowIndex, showtimeIndex=$showtimeIndex');

                                onMovieSelected(movie);

                                setState(() {
                                  final currentStartTimeStr =
                                      timeSlots[rowIndex];
                                  final startTime = DateTime.parse(
                                      '2023-10-18 $currentStartTimeStr:00');
                                  movieDurationInMinutes = movie.duration;
                                  final endTime = startTime.add(Duration(
                                      minutes: movieDurationInMinutes));
                                  final roundedEndMinutes =
                                      _roundMinutesUp(endTime.minute);
                                  final adjustedEndTime = DateTime(
                                    endTime.year,
                                    endTime.month,
                                    endTime.day,
                                    endTime.hour,
                                    roundedEndMinutes,
                                  );

                                  String newTimeSlot =
                                      "${adjustedEndTime.hour.toString().padLeft(2, '0')}:${adjustedEndTime.minute.toString().padLeft(2, '0')}";

                                  // Tìm AddedRow hiện tại (nếu có)
                                  AddedRow? currentAddedRow;
                                  try {
                                    currentAddedRow = addedRows.firstWhere(
                                      (row) =>
                                          row.originalRowIndex == rowIndex &&
                                          row.originalShowtimeIndex ==
                                              showtimeIndex,
                                    );
                                  } catch (e) {
                                    // Không tìm thấy AddedRow
                                    currentAddedRow = null;
                                  }

                                  if (currentAddedRow != null) {
                                    // Cập nhật thời gian kết thúc cho hàng đã thêm
                                    String oldTimeSlot =
                                        currentAddedRow.endTime;
                                    currentAddedRow.endTime = newTimeSlot;

                                    // Tìm index của old time slot
                                    int oldTimeSlotIndex =
                                        timeSlots.indexOf(oldTimeSlot);

                                    if (oldTimeSlotIndex != -1) {
                                      // Cập nhật timeSlots
                                      timeSlots[oldTimeSlotIndex] = newTimeSlot;

                                      // Giữ nguyên tên phim trong showtimes
                                      // Không cần thay đổi gì ở đây vì chúng ta chỉ cập nhật thời gian
                                    } else {
                                      // Nếu không tìm thấy old time slot, thêm mới
                                      timeSlots.add(newTimeSlot);
                                      List<String> newRow = List.from(showtimes[
                                          currentAddedRow.addedRowIndex]);
                                      showtimes.add(newRow);
                                      currentAddedRow.addedRowIndex =
                                          showtimes.length - 1;
                                    }
                                  } else {
                                    // Nếu chưa có hàng được thêm, thêm mới như trước
                                    int existingTimeSlotIndex =
                                        timeSlots.indexOf(newTimeSlot);
                                    if (existingTimeSlotIndex == -1) {
                                      List<String> newRow =
                                          List.filled(cinemas.length, '');
                                      showtimes.add(newRow);
                                      timeSlots.add(newTimeSlot);

                                      addedRows.add(AddedRow(
                                        originalRowIndex: rowIndex,
                                        originalShowtimeIndex: showtimeIndex,
                                        addedRowIndex: showtimes.length - 1,
                                        endTime: newTimeSlot,
                                        unlockedShowtimeIndexes: {
                                          showtimeIndex
                                        },
                                      ));
                                    } else {
                                      AddedRow existingRow;
                                      try {
                                        existingRow = addedRows.firstWhere(
                                          (row) =>
                                              row.addedRowIndex ==
                                              existingTimeSlotIndex,
                                        );
                                      } catch (e) {
                                        existingRow = AddedRow(
                                          originalRowIndex: rowIndex,
                                          originalShowtimeIndex: showtimeIndex,
                                          addedRowIndex: existingTimeSlotIndex,
                                          endTime: newTimeSlot,
                                          unlockedShowtimeIndexes: {},
                                        );
                                        addedRows.add(existingRow);
                                      }
                                      existingRow.unlockedShowtimeIndexes
                                          .add(showtimeIndex);
                                    }
                                  }

                                  // Cập nhật tên phim cho ô hiện tại
                                  showtimes[rowIndex][showtimeIndex] =
                                      "${movie.title}|${movie.posterUrl}";
                                  _sortShowtimes();
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  bool _hasSelectedThirdRoom =
      false; // Biến trạng thái để theo dõi việc chọn phòng thứ 3
  void _sortShowtimes() {
    List<MapEntry<String, List<dynamic>>> sortedEntries = [];
    for (int i = 0; i < timeSlots.length; i++) {
      sortedEntries.add(MapEntry(timeSlots[i], [
        showtimes[i],
        addedRows.firstWhere((row) => row.addedRowIndex == i,
            orElse: () => AddedRow(
                originalRowIndex: -1,
                originalShowtimeIndex: -1,
                addedRowIndex: -1,
                endTime: '',
                unlockedShowtimeIndexes: {}))
      ]));
    }

    sortedEntries.sort((a, b) => a.key.compareTo(b.key));

    timeSlots = sortedEntries.map((e) => e.key).toList();
    showtimes = sortedEntries.map((e) => e.value[0] as List<String>).toList();

    // Update addedRows
    List<AddedRow> newAddedRows = [];
    for (int i = 0; i < sortedEntries.length; i++) {
      AddedRow row = sortedEntries[i].value[1] as AddedRow;
      if (row.addedRowIndex != -1) {
        row.updateAddedRowIndex(i);
        newAddedRows.add(row);
      }
    }
    addedRows = newAddedRows;
  }

  bool _resetToFirstRow = false;
  int totalRows = 4;
  Widget _buildShowtimeGrid() {
    return SingleChildScrollView(
      controller: _verticalController2,
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        controller: _showtimeHorizontalController,
        scrollDirection: Axis.horizontal,
        child: Column(
          children: showtimes.asMap().entries.map((rowEntry) {
            int rowIndex = rowEntry.key;
            List<String> row = rowEntry.value;

            return Row(
              children: row.asMap().entries.map((showtimeEntry) {
                int showtimeIndex = showtimeEntry.key;
                String showtime = showtimeEntry.value;

                bool isUnlocked = false;
                AddedRow? addedRow;
                try {
                  addedRow = addedRows.firstWhere(
                    (row) => row.addedRowIndex == rowIndex,
                  );
                  isUnlocked =
                      addedRow.unlockedShowtimeIndexes.contains(showtimeIndex);
                } catch (e) {
                  // If addedRow is not found, this is an initial row
                  for (int i = 0; i <= showtimeIndex; i++) {
                    int currentRow = i % totalRows;
                    int currentShowtime = i;

                    if (rowIndex == currentRow &&
                        showtimeIndex == currentShowtime) {
                      isUnlocked = true;
                      break;
                    }
                  }
                }

                bool isSelected = showtime.isNotEmpty;
                bool shouldShowAddIcon = isUnlocked && !isSelected;
                List<String> showtimeParts = showtime.split('|');
                String title = showtimeParts.isNotEmpty ? showtimeParts[0] : '';
                String posterUrl =
                    showtimeParts.length > 1 ? showtimeParts[1] : '';
                // Kiểm tra xem có phim nào khác đã được chọn trong cùng khung giờ không
                bool hasOtherMovieInSameTimeSlot =
                    row.where((s) => s.isNotEmpty).length > 1;

                return GestureDetector(
                  onTap: isUnlocked
                      ? () {
                          _showMoviesBottomSheet(
                              context, rowIndex, showtimeIndex,
                              (selectedMovie) {
                            setState(() {
                              showtimes[rowIndex][showtimeIndex] =
                                  selectedMovie.title;
                              _sortShowtimes();
                            });
                          });
                        }
                      : null,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 121),
                    height: 51,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey),
                        right: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelected)
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (posterUrl.isNotEmpty)
                                  Image.asset(
                                    'assets/images/$posterUrl',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: AutoSizeText(
                                    title,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(color: Colors.black),
                                    maxLines: 2,
                                    maxFontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (shouldShowAddIcon)
                          Container(
                            decoration: BoxDecoration(
                              color: mainColor, // Sử dụng màu chính của theme
                              borderRadius:
                                  BorderRadius.circular(20), // Bo góc nhẹ
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),

                                  offset: Offset(2, 2), // Tạo đổ bóng nhẹ
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
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

class AddedRow {
  int originalRowIndex;
  int originalShowtimeIndex;
  int addedRowIndex;
  String endTime;
  Set<int> unlockedShowtimeIndexes;

  AddedRow({
    required this.originalRowIndex,
    required this.originalShowtimeIndex,
    required this.addedRowIndex,
    required this.endTime,
    required this.unlockedShowtimeIndexes,
  });

  void updateAddedRowIndex(int newIndex) {
    addedRowIndex = newIndex;
  }
}
