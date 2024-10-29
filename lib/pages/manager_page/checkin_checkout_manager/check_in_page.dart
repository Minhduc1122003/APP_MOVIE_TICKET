import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/models/Shift_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/work_schedule_checkIn.dart';
import 'package:flutter_app_chat/pages/manager_page/checkin_checkout_manager/bloc/timekeeping_bloc.dart';
import 'package:flutter_app_chat/pages/manager_page/checkin_checkout_manager/check_in_history_calendar.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class TimekeepingScreen extends StatefulWidget {
  const TimekeepingScreen();

  @override
  _TimekeepingScreenState createState() => _TimekeepingScreenState();
}

class _TimekeepingScreenState extends State<TimekeepingScreen> {
  late Timer _timer;
  String _currentTime = _getCurrentTime();
  bool _isMapVisible = false;
  bool _isLocationPermissionGranted = false;
  LatLng? _currentPosition;
  GoogleMapController? _mapController;
  final LatLng _targetPosition =
      LatLng(10.830126, 106.618113); // Tọa độ nơi làm việc
  final double banKinh = 50;
  String? _selectedImagePath; // Biến lưu đường dẫn ảnh đã chọn
  final TextEditingController shiftController = TextEditingController();
  late ApiService _APIService;
  late Future<List<WorkScheduleForCheckIn>?> _allWSCheckIn;
  WorkScheduleForCheckIn? _selectedShift;
  LatLng position = const LatLng(10.927580515436906, 106.79012965530953);
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> allMarkers = {};
  GoogleMapController? mapController;
  @override
  void initState() {
    super.initState();
    _startTimer();
    _checkLocationPermission();
    _APIService = ApiService();
  }

  @override
  void dispose() {
    _timer.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  setSelectpalce(String placeId) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 16.5));
    setState(() {});
  }

  void _moveCameraToShift(String latitude, String longitude) async {
    final GoogleMapController controller = await _controller.future;
    LatLng targetPosition =
        LatLng(double.parse(latitude), double.parse(longitude));
    controller.animateCamera(CameraUpdate.newLatLngZoom(targetPosition, 16.5));
  }

  Future<void> setSelectLatitudeAndLongitude() async {
    _animateToUser(); // Animate camera to the new coordinates
    setState(() {});
  }

  Future<void> _animateToUser() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 16.5));
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _getCurrentTime();
      });
    });
  }

  static String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      _requestLocation();
      setState(() {
        _isLocationPermissionGranted = true;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      _requestLocation();
      setState(() {
        _isLocationPermissionGranted = true;
      });
    }
  }

  Future<void> _requestLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isMapVisible = true;
    });
  }

  void _checkIn() {
    if (_currentPosition == null) {
      EasyLoading.showError('Không thể lấy vị trí hiện tại');
      return;
    }

    double currentLatitude = _currentPosition!.latitude;
    double currentLongitude = _currentPosition!.longitude;

    double distance = Geolocator.distanceBetween(
      currentLatitude,
      currentLongitude,
      _targetPosition.latitude,
      _targetPosition.longitude,
    );

    if (distance <= banKinh) {
      EasyLoading.showSuccess('Chấm công thành công lúc $_currentTime');
    } else {
      EasyLoading.showError(
          'Bạn không nằm trong bán kính cho phép để chấm công');
    }
  }

  Future<void> _fetchWSCheckIn(int userId) async {
    DateTime now = DateTime.now();
    DateTime _currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    DateTime _currentWeekEnd = now.add(Duration(days: 7 - now.weekday));

    // Tính toán ký tự tương ứng với ngày hiện tại
    String dayOfWeek;
    switch (now.weekday) {
      case 1: // Thứ Hai
        dayOfWeek = 'T2';
        break;
      case 2: // Thứ Ba
        dayOfWeek = 'T3';
        break;
      case 3: // Thứ Tư
        dayOfWeek = 'T4';
        break;
      case 4: // Thứ Năm
        dayOfWeek = 'T5';
        break;
      case 5: // Thứ Sáu
        dayOfWeek = 'T6';
        break;
      case 6: // Thứ Bảy
        dayOfWeek = 'T7';
        break;
      case 7: // Chủ Nhật
        dayOfWeek = 'CN';
        break;
      default:
        dayOfWeek = '';
    }
    setState(() {
      _allWSCheckIn = _APIService.getShiftForAttendance(
          userId,
          DateFormat('yyyy-MM-dd').format(_currentWeekStart),
          DateFormat('yyyy-MM-dd').format(_currentWeekEnd),
          'T2');
    });
  }

  void _showShiftBottomSheet(TextEditingController controller) {
    setState(() {
      _allWSCheckIn =
          Future.value([]); // Khởi tạo với một Future trả về danh sách rỗng
    });
    _fetchWSCheckIn(UserManager.instance.user!.userId);

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
              child: FutureBuilder<List<WorkScheduleForCheckIn>?>(
                future: _allWSCheckIn,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Hôm nay không có ca làm nào!'));
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
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: shiftmodel.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 0,
                          ),
                          itemBuilder: (context, index) {
                            final shift = shiftmodel[index];
                            return ListTile(
                              title: Text(
                                shift.shiftName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Từ ${shift.startTime} đến ${shift.endTime}', // Dòng thời gian
                              ),
                              trailing: Text(
                                '${shift.daysOfWeek}', // Ngày tạo
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              onTap: () {
                                print('Đã chọn  ${shift.shiftName}');

                                setState(() {
                                  controller.text = shift.shiftName;
                                  _selectedShift = shift;
                                });
                                _moveCameraToShift(
                                    shift.latitude, shift.longitude);

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: BlocProvider(
        create: (context) => TimekeepingBloc()..add(InitTime()),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.blue,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_outlined,
                  color: Colors.white, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('Chấm công',
                style: TextStyle(color: Colors.white, fontSize: 18)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.info, color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(30.0),
              child: Container(
                height: 40,
                child: TabBar(
                  dividerHeight: 0,
                  indicatorColor: Colors.blue,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.white,
                  tabs: const [Tab(text: 'Chấm công'), Tab(text: 'Lịch sử')],
                ),
              ),
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BlocBuilder<TimekeepingBloc, TimekeepingBlocState>(
                        builder: (context, state) {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Icon(Icons.date_range_outlined,
                                          color: Colors.green, size: 18),
                                      const SizedBox(width: 3),
                                      Text(state.dateFormat),
                                    ],
                                  ),
                                  const SizedBox(width: 20),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          color: Colors.blue, size: 18),
                                      const SizedBox(width: 3),
                                      Text(_currentTime),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              _isMapVisible
                                  ? Container(
                                      height: 200,
                                      child: GoogleMap(
                                        zoomGesturesEnabled: true,
                                        scrollGesturesEnabled: true,
                                        tiltGesturesEnabled: true,
                                        rotateGesturesEnabled: true,
                                        zoomControlsEnabled: true,
                                        mapType: MapType.normal,
                                        initialCameraPosition: CameraPosition(
                                          target: position,
                                          zoom: 16.5,
                                        ),
                                        myLocationEnabled: true,
                                        myLocationButtonEnabled: true,
                                        onMapCreated:
                                            (GoogleMapController controller) {
                                          _controller.complete(controller);
                                        },
                                        circles: {
                                          Circle(
                                            circleId:
                                                const CircleId("myCircle"),
                                            radius: 150,
                                            center: position,
                                            fillColor: const Color.fromRGBO(
                                                100, 100, 100, 0.3),
                                            strokeWidth: 0,
                                          )
                                        },
                                        markers: allMarkers,
                                      ),
                                    )
                                  : !_isLocationPermissionGranted
                                      ? ElevatedButton(
                                          onPressed: _requestLocationPermission,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 15),
                                          ),
                                          child: Text(
                                            'Truy cập vị trí',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        )
                                      : Container(
                                          height: 200,
                                          child: Center(
                                            child: Text(
                                                'Đang lấy vị trí của bạn...'),
                                          ),
                                        ),
                              // Nút chụp ảnh và hiển thị ảnh đã chọn
                              SizedBox(
                                height: 20,
                              ),
                              MyTextfield(
                                controller: shiftController,
                                placeHolder: 'Chọn ca làm',
                                icon: Icons.calendar_month_outlined,
                                onArrowTap: () => _showShiftBottomSheet(
                                    shiftController), // Pass the controller here
                              ),
                              // Hiển thị thông tin ca làm
                              if (_selectedShift !=
                                  null) // Kiểm tra nếu có ca làm đã chọn
                                Container(
                                  width: double
                                      .infinity, // Chiều rộng đầy đủ màn hình
                                  margin: EdgeInsets.all(3.0),
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.black, width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3), // Đổ bóng
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Thông tin ca làm:',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            size: 16,
                                          ),
                                          Text(
                                            ' Tên ca: ',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          Text(
                                            '${_selectedShift!.shiftName}',
                                            style: TextStyle(
                                                color: mainColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_outlined,
                                            size: 16,
                                          ),
                                          Text(
                                            ' Thời gian: Từ',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          Text(
                                            ' ${_selectedShift!.startTime}',
                                            style: TextStyle(
                                                color: mainColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            ' đến',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          Text(
                                            ' ${_selectedShift!.endTime}',
                                            style: TextStyle(
                                                color: mainColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month_outlined,
                                            size: 16,
                                          ),
                                          Text(
                                            ' Ngày làm trong tuần:',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          Text(
                                            ' ${_selectedShift!.daysOfWeek}',
                                            style: TextStyle(
                                                color: mainColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: 16,
                                          ),
                                          Text(
                                            ' Địa điểm: ',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          Text(
                                            '${_selectedShift!.locationName}',
                                            style: TextStyle(
                                                color: mainColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.radio_button_checked_outlined,
                                            size: 16,
                                          ),
                                          Text(
                                            ' Bán kính chấm công: ',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          Text(
                                            '${_selectedShift!.radius}m',
                                            style: TextStyle(
                                                color: mainColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: double
                                      .infinity, // Chiều rộng đầy đủ màn hình
                                  padding: EdgeInsets.all(
                                      8.0), // Khoảng cách xung quanh nút
                                  child: ElevatedButton(
                                    onPressed: _checkIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.green, // Màu nền của nút
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 15),
                                    ),
                                    child: Text(
                                      'Chấm công',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: TimekeepingHistoryCalendar(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
