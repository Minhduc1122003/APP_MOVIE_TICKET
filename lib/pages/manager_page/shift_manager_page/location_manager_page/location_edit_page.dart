import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_InfoCard.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/models/Location_modal.dart';
import 'package:flutter_app_chat/models/Shift_modal.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/manager_page/personnel_manager_page/personnel_info_manager_page/personnel_info_manager_page.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/location_manager_page/locationSelectionScreen.dart';
import 'package:flutter_app_chat/pages/manager_page/showtime_manager_page/showtime_edit_manager_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationEditPage extends StatefulWidget {
  final bool isEdit; // Thuộc tính xác định chế độ sửa
  final LocationWithShift? location;
  const LocationEditPage({
    super.key,
    required this.isEdit,
    this.location,
  });

  @override
  State<LocationEditPage> createState() => _LocationEditPageState();
}

class _LocationEditPageState extends State<LocationEditPage> {
  late ApiService _APIService;
  bool isSearching = false;
  FocusNode _focusNode = FocusNode();
  TextEditingController _searchController = TextEditingController();
  LatLng position = const LatLng(10.927580515436906, 106.79012965530953);
  final TextEditingController locationNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController radiusController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController shiftController = TextEditingController();
  final TextEditingController idController = TextEditingController();

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> allMarkers = {};
  GoogleMapController? mapController; // Khai báo mapController là nullable
  ApiService apiService = ApiService();
  late Future<List<Shift>> _allShift;
  int? idShift;
  final FocusNode _locationNameFocus = FocusNode();
  final FocusNode _shiftFocus = FocusNode();
  final FocusNode _longitudeFocus = FocusNode();
  final FocusNode _latitudeFocus = FocusNode();
  final FocusNode _radiusFocus = FocusNode();
  final FocusNode _idfocus = FocusNode();

  void initState() {
    initMarker();
    super.initState();
    _APIService = ApiService();

    _allShift = _APIService.getAllListShift();
    if (widget.isEdit && widget.location != null) {
      idController.text = widget.location!.locationId.toString();
      locationNameController.text = widget.location!.locationName.toString();
      shiftController.text = widget.location!.shiftName.toString();
      idShift = widget.location!.shiftId;
      longitudeController.text = widget.location!.longitude;
      latitudeController.text = widget.location!.latitude;
      radiusController.text = widget.location!.radius.toString();
    }
  }

  initMarker() {
    allMarkers.clear();
    allMarkers.add(Marker(
      markerId: const MarkerId("myMarker"),
      draggable: false,
      position: position,
    ));
  }

  void _unfocusAll() {
    _locationNameFocus.unfocus();
    _shiftFocus.unfocus();
    _longitudeFocus.unfocus();
    _latitudeFocus.unfocus();
    _radiusFocus.unfocus();
    _focusNode.unfocus();
    _idfocus.unfocus();
  }

  setSelectpalce(String placeId) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 16.5));
    setState(() {});
  }

  Future<void> setSelectLatitudeAndLongitude() async {
    position = LatLng(
      double.parse(latitudeController.text),
      double.parse(longitudeController.text),
    );
    initMarker();
    _animateToUser(); // Animate camera to the new coordinates
    setState(() {});
  }

  Future<void> _animateToUser() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 16.5));
  }

  Future<void> getCurrentLocation() async {
    try {
      // Kiểm tra quyền truy cập vị trí
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Position currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          position =
              LatLng(currentPosition.latitude, currentPosition.longitude);
          latitudeController.text = position.latitude.toString();
          longitudeController.text = position.longitude.toString();

          // Cập nhật marker mới cho vị trí hiện tại
          allMarkers = {
            Marker(
              markerId: MarkerId('currentLocation'),
              position: position,
            ),
          };

          // Di chuyển camera đến vị trí hiện tại
          moveCameraToPosition(position);
        });
      } else {
        print('Permission denied');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void updateMapPosition() async {
    double? latitude = double.tryParse(latitudeController.text);
    double? longitude = double.tryParse(longitudeController.text);
    latitudeController.text = latitude.toString();
    longitudeController.text = longitude.toString();

    // Update the position and trigger a rebuild
    setState(() {
      position = LatLng(latitude!, longitude!);

      allMarkers = {
        Marker(
          markerId: MarkerId('selectedLocation'),
          position: position, // Update the marker position
        ),
      };
    });

    // Move the camera to the new position
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }

// Hàm di chuyển camera đến vị trí mới
  void moveCameraToPosition(LatLng targetPosition) {
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(targetPosition));
    } else {
      print('mapController is not initialized');
    }
  }

  void _showShiftBottomSheet(TextEditingController controller) {
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
              child: FutureBuilder<List<Shift>>(
                future: _allShift,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Không có phim nào.'));
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
                                'Ngày tạo: ${shift.createDate}', // Ngày tạo
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              onTap: () {
                                print('Đã chọn  ${shift.shiftName}');

                                setState(() {
                                  controller.text =
                                      shift.shiftName; // Update the text field
                                  idShift = shift
                                      .shiftId; // Update the idShift variable with the selected shift ID
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

  Future<void> _submitLocation() async {
    if (locationNameController.text.isEmpty ||
        latitudeController.text.isEmpty ||
        longitudeController.text.isEmpty ||
        radiusController.text.isEmpty == null ||
        idShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
      );
      return;
    }
    print(locationNameController.text);
    print(latitudeController.text);
    print(longitudeController.text);
    print(radiusController.text);
    print(idShift);
    int shiftId = idShift!;
    // Tạo một đối tượng Shift từ dữ liệu đã nhập

    try {
      // Gọi API để gửi dữ liệu và lấy message
      String message = await _APIService.createLocation(
          locationNameController.text,
          latitudeController.text,
          longitudeController.text,
          double.parse(radiusController.text),
          shiftId);

      // Kiểm tra nếu message là "Shift created successfully"
      if (message == 'Location created successfully') {
        EasyLoading.showSuccess('Tạo ca làm thành công!');
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

  Future<void> _updateLocation() async {
    if (locationNameController.text.isEmpty ||
        latitudeController.text.isEmpty ||
        longitudeController.text.isEmpty ||
        radiusController.text.isEmpty == null ||
        idShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
      );
      return;
    }

    int shiftId = idShift!;

    try {
      // Gọi API để gửi dữ liệu và lấy message
      String message = await _APIService.updateLocationShifts(
          int.parse(idController.text),
          locationNameController.text,
          latitudeController.text,
          longitudeController.text,
          double.parse(radiusController.text),
          shiftId);

      // Kiểm tra nếu message là "Shift created successfully"
      if (message == 'Location updated successfully') {
        EasyLoading.showSuccess('Sửa vị trí làm thành công!');
        Navigator.of(context).pop(true); // Trả về true khi tạo ca thành công
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi sửa ca làm: $message')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi sửa ca làm: $e')),
      );
    }
  }

  Future<void> _removeLocation() async {
    if (locationNameController.text.isEmpty ||
        latitudeController.text.isEmpty ||
        longitudeController.text.isEmpty ||
        radiusController.text.isEmpty == null ||
        idShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
      );
      return;
    }

    int shiftId = idShift!;

    try {
      // Gọi API để gửi dữ liệu và lấy message
      String message = await _APIService.removeLocationShifts(
        int.parse(idController.text),
      );
      print('message11111: $message');

      // Kiểm tra nếu message là "Shift created successfully"
      if (message == 'Location deleted successfully') {
        EasyLoading.showSuccess('Xóa vị trí thành công!');
        Navigator.of(context).pop(true); // Trả về true khi tạo ca thành công
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa vị trí: $message')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa vị trí: $e')),
      );
    }
  }

  @override
  void dispose() {
    _locationNameFocus.dispose();
    _shiftFocus.dispose();
    _longitudeFocus.dispose();
    _latitudeFocus.dispose();
    _radiusFocus.dispose();
    _focusNode.dispose();
    _searchController.dispose();
    locationNameController.dispose();
    addressController.dispose();
    radiusController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    shiftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _unfocusAll();
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
                _unfocusAll();
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
                    : Text(widget.isEdit ? 'Sửa vị trí' : 'Tạo vị trí',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20))),
            centerTitle: false,
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              children: [
                if (widget.isEdit)
                  MyTextfield(
                    controller: idController,
                    focusNode: _idfocus,
                    placeHolder: 'ID vị trí',
                    icon: Icons.not_listed_location_sharp,
                  ),
                const SizedBox(
                  height: 10,
                ),
                MyTextfield(
                  controller: locationNameController,
                  focusNode: _locationNameFocus,
                  placeHolder: 'Tên vị trí',
                  icon: Icons.not_listed_location_sharp,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyTextfield(
                  controller: shiftController,
                  focusNode: _shiftFocus,
                  placeHolder: 'Ca làm',
                  icon: Icons.calendar_month_outlined,
                  onArrowTap: () {
                    _unfocusAll();
                    _showShiftBottomSheet(shiftController);
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: MyTextfield(
                        controller: longitudeController,
                        focusNode: _longitudeFocus,
                        isPassword: false,
                        placeHolder: "Kinh độ",
                        sendCode: false,
                        icon: Icons.my_location,
                        onSubmitted: (value) {
                          if (latitudeController.text.isEmpty) return;
                          if (longitudeController.text.isEmpty) return;
                          setSelectLatitudeAndLongitude();
                          _unfocusAll();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MyTextfield(
                        controller: latitudeController,
                        focusNode: _latitudeFocus,
                        isPassword: false,
                        placeHolder: "Vĩ độ",
                        sendCode: false,
                        icon: Icons.my_location,
                        onSubmitted: (value) {
                          if (latitudeController.text.isEmpty) return;
                          if (longitudeController.text.isEmpty) return;
                          setSelectLatitudeAndLongitude();
                          _unfocusAll();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
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
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    circles: {
                      Circle(
                        circleId: const CircleId("myCircle"),
                        radius: 150,
                        center: position,
                        fillColor: const Color.fromRGBO(100, 100, 100, 0.3),
                        strokeWidth: 0,
                      )
                    },
                    markers: allMarkers,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          await getCurrentLocation();
                          updateMapPosition();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide.none,
                          ),
                        ),
                        child: const AutoSizeText(
                          'Lấy vị trí hiện tại',
                          style: TextStyle(fontSize: 16.0),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          // Define the initial position for the map (you can adjust this as needed)
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LocationSelectionScreen(
                                initialPosition: position,
                              ),
                            ),
                          );

                          // Check if result is not null and update the text fields and map
                          if (result is LatLng) {
                            print(
                                "Selected Location: Latitude: ${result.latitude}, Longitude: ${result.longitude}");

                            // Update the text fields with the selected coordinates
                            latitudeController.text =
                                result.latitude.toString();
                            longitudeController.text =
                                result.longitude.toString();

                            // Update the position and trigger a rebuild
                            setState(() {
                              position =
                                  result; // Update the position to the selected location
                              allMarkers = {
                                Marker(
                                  markerId: MarkerId('selectedLocation'),
                                  position:
                                      position, // Update the marker position
                                ),
                              };
                            });

                            // Move the camera to the new position
                            final GoogleMapController controller =
                                await _controller.future;
                            controller.animateCamera(
                                CameraUpdate.newLatLng(position));
                          } else {
                            print("No location selected.");
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              mainColor, // Set the background color to blue
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0), // Adjust padding
                          foregroundColor:
                              Colors.white, // Set the text color to white
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Optional: rounded corners
                            side: BorderSide.none, // Remove the border
                          ),
                        ),
                        child: const AutoSizeText(
                          'Chọn vị trí cụ thể',
                          style: TextStyle(
                              fontSize: 16.0), // Đặt kích thước chữ tối đa
                          maxLines: 1, // Chỉ cho phép 1 dòng
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                MyTextfield(
                  controller: radiusController,
                  focusNode: _radiusFocus,
                  placeHolder: 'Bán kính (m)',
                  icon: Icons.radio_button_on,
                ),
                Spacer(),
                if (widget.isEdit)
                  Row(
                    children: [
                      Expanded(
                        child: MyButton(
                          color: Colors.red,
                          fontsize: 20,
                          paddingText: 10,
                          text: 'Xóa ca',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Xác nhận xóa ca'),
                                  content: const Text(
                                      'Bạn có chắc chắn muốn xóa ca này không?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Đóng hộp thoại
                                      },
                                      child: const Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Đóng hộp thoại
                                        _removeLocation(); // Gọi hàm xóa ca sau khi xác nhận
                                      },
                                      child: const Text(
                                        'Xóa',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10), // Khoảng cách giữa hai nút
                      Expanded(
                        child: MyButton(
                          fontsize: 20,
                          paddingText: 10,
                          text: 'Lưu',
                          onTap: _updateLocation, // Gọi hàm _submitShift
                        ),
                      ),
                    ],
                  )
                else
                  MyButton(
                    fontsize: 20,
                    paddingText: 10,
                    text: 'Hoàn tất',
                    onTap: _submitLocation, // Gọi hàm _submitShift
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
