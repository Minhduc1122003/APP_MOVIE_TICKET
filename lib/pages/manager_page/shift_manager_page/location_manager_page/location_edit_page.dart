import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_InfoCard.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/manager_page/personnel_manager_page/personnel_info_manager_page/personnel_info_manager_page.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/location_manager_page/locationSelectionScreen.dart';
import 'package:flutter_app_chat/pages/manager_page/showtime_manager_page/showtime_edit_manager_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationEditPage extends StatefulWidget {
  const LocationEditPage({super.key});

  @override
  State<LocationEditPage> createState() => _LocationEditPageState();
}

class _LocationEditPageState extends State<LocationEditPage> {
  late ApiService _APIService;
  bool isSearching = false;
  FocusNode _focusNode = FocusNode();
  TextEditingController _searchController = TextEditingController();
  late Future<List<User>> _alluser;
  LatLng position = const LatLng(10.927580515436906, 106.79012965530953);
  TextEditingController locationController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController radiusController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> allMarkers = {};
  GoogleMapController? mapController; // Khai báo mapController là nullable
  void initState() {
    initMarker();
    super.initState();
  }

  initMarker() {
    allMarkers.clear();
    allMarkers.add(Marker(
      markerId: const MarkerId("myMarker"),
      draggable: false,
      position: position,
    ));
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

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
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
                    : const Text('Thông tin vị trí',
                        style: TextStyle(color: Colors.white, fontSize: 20))),
            centerTitle: false,
          ),
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  children: [
                    const MyTextfield(
                      placeHolder: 'Tên vị trí',
                      icon: Icons.not_listed_location_sharp,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const MyTextfield(
                      placeHolder: 'Ca làm',
                      icon: Icons.calendar_month_outlined,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: MyTextfield(
                            controller: longitudeController,
                            isPassword: false,
                            placeHolder: "Kinh độ",
                            sendCode: false,
                            icon: Icons.my_location,
                            onSubmitted: (value) {
                              if (latitudeController.text.isEmpty) return;
                              if (longitudeController.text.isEmpty) return;
                              setSelectLatitudeAndLongitude();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MyTextfield(
                            controller: latitudeController,
                            isPassword: false,
                            placeHolder: "Vĩ độ",
                            sendCode: false,
                            icon: Icons.my_location,
                            onSubmitted: (value) {
                              if (latitudeController.text.isEmpty) return;
                              if (longitudeController.text.isEmpty) return;
                              setSelectLatitudeAndLongitude();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 150,
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
                              padding: EdgeInsets.symmetric(vertical: 20.0),
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
                                  vertical: 20.0), // Adjust padding
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
                      placeHolder: 'Bán kính (m)',
                      icon: Icons.radio_button_on,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
