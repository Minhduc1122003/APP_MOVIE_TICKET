import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/Shift_modal.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/models/work_schedule_model.dart';
import 'package:flutter_app_chat/pages/manager_page/personnel_manager_page/personnel_info_manager_page/personnel_info_manager_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart'; // Để xử lý loại bỏ dấu

class CalendarShiftListPage extends StatefulWidget {
  const CalendarShiftListPage({super.key});

  @override
  State<CalendarShiftListPage> createState() => _CalendarShiftListPageState();
}

class _CalendarShiftListPageState extends State<CalendarShiftListPage> {
  late ApiService _APIService;
  bool isSearching = false;
  FocusNode _focusNode = FocusNode();
  TextEditingController _searchController = TextEditingController();
  late Future<List<User>> _alluser;
  late Future<List<Shift>> _allShift;
  late Future<List<WorkSchedule>?> _allSchedule;
  Map<int, List<bool>> selectedDaysMap = {};
  DateTime _currentWeekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1)); // Thứ 2 của tuần hiện tại
  DateTime _currentWeekEnd = DateTime.now().add(
      Duration(days: 7 - DateTime.now().weekday)); // Chủ nhật của tuần hiện tại

  // Biến để lưu trữ ngày đã chọn
  DateTime? _selectedDate;
  TextEditingController _dateController = TextEditingController();
  Map<int, bool> isExpandedMap = {};

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
    _alluser = _APIService.getUserListForAdmin();
    _allShift = _APIService.getAllListShift();
    _selectedDate = DateTime.now();
    _updateDateController();
    _allSchedule = Future.value([]); // Initialize to an empty future
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Hàm để lấy ngày bắt đầu của tuần cho một ngày cụ thể
  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1)); // Thứ 2 của tuần
  }

  // Hàm để lấy ngày kết thúc của tuần cho một ngày cụ thể
  DateTime _getWeekEnd(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday)); // Chủ nhật của tuần
  }

  void _updateDateController() {
    if (_selectedDate != null) {
      _dateController.text =
          'Tuần: ${DateFormat('dd/MM/yyyy').format(_getWeekStart(_selectedDate!))} - ${DateFormat('dd/MM/yyyy').format(_getWeekEnd(_selectedDate!))}';
    }
  }

  Future<void> _fetchShiftData(
      String userId, DateTime weekStart, DateTime weekEnd) async {
    setState(() {
      _allSchedule = _APIService.getAllWorkSchedulesByID(
        int.parse(userId),
        DateFormat('yyyy-MM-dd').format(weekStart),
        DateFormat('yyyy-MM-dd').format(weekEnd),
      );
    });
  }

  void _showShiftBottomSheet(
      BuildContext context, Color mainColor, String userId) {
    selectedDaysMap.clear(); // Xóa tất cả dữ liệu trong selectedDaysMap

    _currentWeekStart = _getWeekStart(_selectedDate!);
    _currentWeekEnd = _getWeekEnd(_selectedDate!);
    _allShift = _APIService.getAllListShift(); // Tải tất cả ca làm

    // Fetch the work schedules for the selected user and week
    _fetchShiftData(userId, _currentWeekStart, _currentWeekEnd);

    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
            expand: false,
            builder: (context, scrollController) {
              return Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: FutureBuilder<List<Shift>>(
                    future: _allShift,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Không có ca làm nào.'));
                      }

                      final shiftmodel = snapshot.data!;

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
                              'Danh sách ca làm',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: () {
                                  setState(() {
                                    _currentWeekStart = _currentWeekStart
                                        .subtract(Duration(days: 7));
                                    _currentWeekEnd = _currentWeekEnd
                                        .subtract(Duration(days: 7));
                                    _selectedDate =
                                        _currentWeekStart; // Cập nhật ngày đã chọn
                                    _updateDateController(); // Cập nhật controller
                                  });
                                  _fetchShiftData(userId, _currentWeekStart,
                                      _currentWeekEnd);
                                },
                              ),
                              // TextField để chọn ngày
                              Expanded(
                                child: TextField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: 'Chọn ngày',
                                    border: OutlineInputBorder(),
                                  ),
                                  controller: _dateController,
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          _selectedDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                    );

                                    if (pickedDate != null) {
                                      setState(() {
                                        _selectedDate = pickedDate;
                                        _currentWeekStart =
                                            _getWeekStart(_selectedDate!);
                                        _currentWeekEnd =
                                            _getWeekEnd(_selectedDate!);
                                        _updateDateController();
                                      });
                                      _fetchShiftData(userId, _currentWeekStart,
                                          _currentWeekEnd);
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward),
                                onPressed: () {
                                  setState(() {
                                    _currentWeekStart = _currentWeekStart
                                        .add(Duration(days: 7));
                                    _currentWeekEnd =
                                        _currentWeekEnd.add(Duration(days: 7));
                                    _selectedDate =
                                        _currentWeekStart; // Cập nhật ngày đã chọn
                                    _updateDateController();
                                  });
                                  _fetchShiftData(userId, _currentWeekStart,
                                      _currentWeekEnd);
                                },
                              ),
                            ],
                          ),
                          Expanded(
                            child: FutureBuilder<List<WorkSchedule>?>(
                              future:
                                  _allSchedule, // Vẫn giữ để lấy lịch làm cho user
                              builder: (context, scheduleSnapshot) {
                                if (scheduleSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (scheduleSnapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Error: ${scheduleSnapshot.error}'));
                                }
                                for (int i = 0; i < shiftmodel.length; i++) {
                                  selectedDaysMap[i] = List<bool>.filled(
                                      7, false); // Khởi tạo tất cả là false
                                }

// Sau đó, cập nhật selectedDaysMap cho các ca làm có dữ liệu từ server
                                for (var schedule in scheduleSnapshot.data!) {
                                  int shiftIndex = shiftmodel.indexWhere(
                                      (shift) =>
                                          shift.shiftId.toString() ==
                                          schedule.shiftId.toString());
                                  if (shiftIndex != -1) {
                                    List<String> days =
                                        schedule.daysOfWeek.split(', ');
                                    for (String day in days) {
                                      int dayIndex = _getDayIndex(day);
                                      if (dayIndex != -1) {
                                        selectedDaysMap[shiftIndex]![dayIndex] =
                                            true; // Đánh dấu ngày đã chọn
                                      }
                                    }
                                  }
                                }
                                return ListView.separated(
                                  controller: scrollController,
                                  itemCount: shiftmodel.length,
                                  separatorBuilder: (context, index) =>
                                      Divider(height: 1, thickness: 0),
                                  itemBuilder: (context, index) {
                                    final shift = shiftmodel[index];
                                    return ExpansionTile(
                                      title: Text(shift.shiftName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                          'Từ ${shift.startTime} đến ${shift.endTime}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                  'Ngày tạo: ${shift.createDate}'),
                                              SizedBox(height: 15),
                                              Text(
                                                '${shift.status}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: shift.status ==
                                                          'Đang hoạt động'
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 8),
                                          const Icon(Icons.keyboard_arrow_down,
                                              size: 16),
                                        ],
                                      ),
                                      children: [
                                        Container(
                                          padding: EdgeInsets.fromLTRB(
                                              20, 20, 20, 10),
                                          color: Colors.grey[100],
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Chọn ngày làm:',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16)),
                                              SizedBox(height: 10),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  _buildDayButton(
                                                      'Thứ 2',
                                                      mainColor,
                                                      shift.shiftId.toString(),
                                                      index,
                                                      0),
                                                  _buildDayButton(
                                                      'Thứ 3',
                                                      mainColor,
                                                      shift.shiftId.toString(),
                                                      index,
                                                      1),
                                                  _buildDayButton(
                                                      'Thứ 4',
                                                      mainColor,
                                                      shift.shiftId.toString(),
                                                      index,
                                                      2),
                                                  _buildDayButton(
                                                      'Thứ 5',
                                                      mainColor,
                                                      shift.shiftId.toString(),
                                                      index,
                                                      3),
                                                  _buildDayButton(
                                                      'Thứ 6',
                                                      mainColor,
                                                      shift.shiftId.toString(),
                                                      index,
                                                      4),
                                                  _buildDayButton(
                                                      'Thứ 7',
                                                      mainColor,
                                                      shift.shiftId.toString(),
                                                      index,
                                                      5),
                                                  _buildDayButton(
                                                      'Chủ Nhật',
                                                      mainColor,
                                                      shift.shiftId.toString(),
                                                      index,
                                                      6),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Divider(height: 2, thickness: 0),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: MyButton(
                                                      color: selectedDaysMap
                                                                  .containsKey(
                                                                      index) &&
                                                              selectedDaysMap[
                                                                      index]!
                                                                  .contains(
                                                                      true)
                                                          ? Colors.red
                                                          : Colors.grey,
                                                      fontsize: 20,
                                                      paddingText: 10,
                                                      text: 'Hủy',
                                                      onTap: () {
                                                        // Xử lý sự kiện xóa
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: MyButton(
                                                      fontsize: 20,
                                                      paddingText: 10,
                                                      text: 'Lưu',
                                                      onTap: () {
                                                        // Lấy các ngày đã chọn cho ca hiện tại
                                                        List<String>
                                                            selectedDays =
                                                            _getSelectedDays(
                                                                index);
                                                        String shiftID = shift
                                                            .shiftId
                                                            .toString();
                                                        String startDay = DateFormat(
                                                                'dd/MM/yyyy')
                                                            .format(
                                                                _currentWeekStart);
                                                        String endDay = DateFormat(
                                                                'dd/MM/yyyy')
                                                            .format(
                                                                _currentWeekEnd);

                                                        print(
                                                            'User ID: $userId, Tuần: $startDay - $endDay, Shift ID: $shiftID, Ngày đã chọn: $selectedDays');

                                                        // Gọi hàm để lưu lịch làm
                                                        _submitWorkSchedules(
                                                            userId,
                                                            shiftID,
                                                            startDay,
                                                            endDay,
                                                            selectedDays
                                                                .toString());
                                                      },
                                                      color: selectedDaysMap
                                                                  .containsKey(
                                                                      index) &&
                                                              selectedDaysMap[
                                                                      index]!
                                                                  .contains(
                                                                      true)
                                                          ? mainColor
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ));
            });
      },
    );
  }

  Widget _buildDayButton(String day, Color mainColor, String shiftID,
      int shiftIndex, int dayIndex) {
    return StatefulBuilder(
      builder: (context, setState) {
        // Tính toán ngày cho ngày cụ thể trong tuần
        DateTime date = _currentWeekStart.add(Duration(days: dayIndex));

        // Kiểm tra xem selectedDaysMap đã được khởi tạo cho shiftIndex chưa
        bool isSelected = selectedDaysMap[shiftIndex] != null &&
            selectedDaysMap[shiftIndex]![dayIndex];

        return ElevatedButton(
          onPressed: () {
            setState(() {
              if (selectedDaysMap[shiftIndex] != null) {
                selectedDaysMap[shiftIndex]![dayIndex] =
                    !selectedDaysMap[shiftIndex]![dayIndex];
              }
              // In ra các ngày đã chọn
              print(
                  'Shift ID: $shiftID, Ngày đã chọn: ${_getSelectedDays(shiftIndex)}');
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? mainColor
                : Colors.white, // Màu trắng nếu không được chọn
            foregroundColor: isSelected ? Colors.white : Colors.black,
            side: BorderSide(color: mainColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 2, 0, 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(day), // Tên ngày
                SizedBox(height: 1), // Khoảng cách giữa tên ngày và ngày
                Text(
                  DateFormat('dd/MM').format(date), // Định dạng ngày
                  style: TextStyle(fontSize: 12), // Font nhỏ cho ngày
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _getDayIndex(String day) {
    switch (day) {
      case 'T2':
        return 0; // Monday
      case 'T3':
        return 1; // Tuesday
      case 'T4':
        return 2; // Wednesday
      case 'T5':
        return 3; // Thursday
      case 'T6':
        return 4; // Friday
      case 'T7':
        return 5; // Saturday
      case 'CN':
        return 6; // Sunday
      default:
        return -1; // Invalid day
    }
  }

  List<String> _getSelectedDays(int shiftIndex) {
    List<String> selectedDays = [];
    if (selectedDaysMap.containsKey(shiftIndex)) {
      List<bool> days = selectedDaysMap[shiftIndex]!;
      if (days[0]) selectedDays.add('T2');
      if (days[1]) selectedDays.add('T3');
      if (days[2]) selectedDays.add('T4');
      if (days[3]) selectedDays.add('T5');
      if (days[4]) selectedDays.add('T6');
      if (days[5]) selectedDays.add('T7');
      if (days[6]) selectedDays.add('CN');
    }
    return selectedDays;
  }

  Future<void> _submitWorkSchedules(
      String UserId, // Get from your text field
      String ShiftId, // Get from your text field
      String StartDate, // Get from your text field
      String EndDate, // Get from your text field
      String DaysOfWeek) async {
    try {
      // Gọi API để gửi dữ liệu và lấy message
      String message = await _APIService.createWorkSchedules(
          UserId, ShiftId, StartDate, EndDate, DaysOfWeek);

      // Kiểm tra nếu message là "Shift created successfully"
      if (message == 'Location created successfully') {
        EasyLoading.showSuccess('Gán ca làm cho nhân viên $UserId thành công!');
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop(true); // Trả về true khi tạo ca thành công
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tạo ca làm: $message')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tạo ca làm: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: mainColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_outlined,
                  color: Colors.white, size: 16),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
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
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm nhân viên...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: TextStyle(color: Colors.black),
                      )
                    : Text('Chọn nhân viên',
                        style: TextStyle(color: Colors.white, fontSize: 20))),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.white, size: 20),
                onPressed: () {
                  setState(() {
                    if (isSearching || _searchController.text.isNotEmpty) {
                      _searchController.clear();
                      isSearching = false;
                    } else {
                      isSearching = true;
                    }
                  });
                },
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: FutureBuilder<List<User>>(
            future: _alluser,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No users found.'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final user = snapshot.data![index];
                    return ListTile(
                      title: Text(user.fullName),
                      subtitle: Text(user.email),
                      leading: user.photo != null
                          ? Image.network(user.photo!)
                          : Icon(Icons.person),
                      trailing: Text(user.status),
                      onTap: () {
                        _showShiftBottomSheet(context, mainColor,
                            user.userId.toString()); // Pass user ID
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
