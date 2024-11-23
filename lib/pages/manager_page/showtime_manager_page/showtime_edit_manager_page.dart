import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/showTimeForAdmin_model.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

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
  DateTime _currentWeekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1)); // Thứ 2 của tuần hiện tại
  DateTime _currentWeekEnd = DateTime.now().add(
      Duration(days: 7 - DateTime.now().weekday)); // Chủ nhật của tuần hiện tại
  DateTime? _selectedDate;
  TextEditingController _dateController = TextEditingController();

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

  void _updateDateController() {
    if (_selectedDate != null) {
      _dateController.text =
          'Tuần: ${DateFormat('dd/MM/yyyy').format(_getWeekStart(_selectedDate!))} - ${DateFormat('dd/MM/yyyy').format(_getWeekEnd(_selectedDate!))}';
    }
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1)); // Thứ 2 của tuần
  }

  // Hàm để lấy ngày kết thúc của tuần cho một ngày cụ thể
  DateTime _getWeekEnd(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday)); // Chủ nhật của tuần
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
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          setState(() {
                            _currentWeekStart =
                                _currentWeekStart.subtract(Duration(days: 7));
                            _currentWeekEnd =
                                _currentWeekEnd.subtract(Duration(days: 7));
                            _selectedDate =
                                _currentWeekStart; // Cập nhật ngày đã chọn
                            _updateDateController(); // Cập nhật controller
                          });
                        },
                      ),
                      // TextField để chọn ngày
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Chưa chọn tuần',
                            border: OutlineInputBorder(),
                          ),
                          controller: _dateController,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );

                            if (pickedDate != null) {
                              setState(() {
                                _selectedDate = pickedDate;
                                _currentWeekStart =
                                    _getWeekStart(_selectedDate!);
                                _currentWeekEnd = _getWeekEnd(_selectedDate!);
                                _updateDateController();
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () {
                          setState(() {
                            _currentWeekStart =
                                _currentWeekStart.add(Duration(days: 7));
                            _currentWeekEnd =
                                _currentWeekEnd.add(Duration(days: 7));
                            _selectedDate =
                                _currentWeekStart; // Cập nhật ngày đã chọn
                            _updateDateController();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
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
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: MyButton(
                    text: 'Lưu',
                    paddingText: 13,
                    fontsize: 16,
                    onTap: () {
                      // Danh sách lưu trữ kết quả dưới dạng model
                      List<ShowtimeModel> showtimeModels = [];

                      showtimes.asMap().entries.forEach((rowEntry) {
                        int rowIndex = rowEntry.key;
                        List<String> row = rowEntry.value;

                        // Lấy mốc thời gian tương ứng với rowIndex từ timeSlots
                        String timeSlot = (rowIndex < timeSlots.length)
                            ? timeSlots[rowIndex]
                            : 'N/A';

                        // Danh sách phim trong hàng
                        List<MovieItem> movieItems = [];

                        row.asMap().entries.forEach((columnEntry) {
                          int columnIndex = columnEntry.key;
                          String showtime = columnEntry.value;

                          // Nếu showtime không rỗng, lấy ID phim và thêm vào danh sách
                          if (showtime.isNotEmpty) {
                            String movieId = showtime.split(",")[0].trim();
                            movieItems.add(MovieItem(
                              movieId: movieId,
                              columnIndex: columnIndex + 1,
                            ));
                          }
                        });

                        // Nếu có dữ liệu phim, thêm vào model
                        if (movieItems.isNotEmpty) {
                          showtimeModels.add(ShowtimeModel(
                            timeSlot: timeSlot,
                            movies: movieItems,
                          ));
                        }
                      });

                      // In ra danh sách model
                      showtimeModels.forEach((model) {
                        print('Thời gian: ${model.timeSlot}');
                        model.movies.forEach((movie) {
                          print(
                              'Phim ID: ${movie.movieId}, Cột: ${movie.columnIndex}');
                        });
                      });

                      // Chuyển đổi showtimeModels thành danh sách Showtimes cho API
                      List<Map<String, dynamic>> showtimesForApi = [];

                      showtimeModels.forEach((model) {
                        model.movies.forEach((movie) {
                          showtimesForApi.add({
                            'MovieID': movie.movieId,
                            'CinemaRoomID': movie.columnIndex.toString(),
                            'StartTime': model
                                .timeSlot, // Giả sử thời gian là StartTime của suất chiếu
                          });
                        });
                      });

                      String formattedStartDate =
                          DateFormat('yyyy-MM-dd').format(_currentWeekStart);
                      String formattedEndDate =
                          DateFormat('yyyy-MM-dd').format(_currentWeekEnd);
                      print('================');
                      print(showtimesForApi);

                      apiService.insertShowTime(
                        StartDate: formattedStartDate,
                        EndDate: formattedEndDate,
                        Showtimes: showtimesForApi,
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
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
      var fetchedShowtimes = await apiService.getShowtimeListForAdmin();
      fetchedShowtimes = [];

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
                              leading: CachedNetworkImage(
                                imageUrl: movie.posterUrl,
                                width: 30,
                                height: 40,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                fadeInDuration: const Duration(seconds: 1),
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
                                      "${movie.movieId}, ${movie.title}, ${movie.posterUrl}";
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
                List<String> showtimeParts = showtime.split(', ');
                String title = showtimeParts.length > 1 ? showtimeParts[1] : '';
                String posterUrl =
                    showtimeParts.length > 1 ? showtimeParts[2] : '';
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
                                  CachedNetworkImage(
                                    imageUrl: posterUrl,
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

class ShowtimeItem {
  final String timeSlot; // Thời gian chiếu
  final String title; // Tên phim
  final String posterUrl; // URL poster của phim

  ShowtimeItem({
    required this.timeSlot,
    required this.title,
    required this.posterUrl,
  });

  @override
  String toString() {
    return 'ShowtimeItem(timeSlot: $timeSlot, title: $title, posterUrl: $posterUrl)';
  }
}

class ShowtimeModel {
  final String timeSlot;
  final List<MovieItem> movies;

  ShowtimeModel({required this.timeSlot, required this.movies});
}

class MovieItem {
  final String movieId;
  final int columnIndex;

  MovieItem({required this.movieId, required this.columnIndex});
}
