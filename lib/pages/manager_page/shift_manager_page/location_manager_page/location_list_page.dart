import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_InfoCard.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/manager_page/personnel_manager_page/personnel_info_manager_page/personnel_info_manager_page.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/location_manager_page/location_edit_page.dart';
import 'package:flutter_app_chat/pages/manager_page/showtime_manager_page/showtime_edit_manager_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../../models/Location_modal.dart';

class LocationListPage extends StatefulWidget {
  const LocationListPage({super.key});

  @override
  State<LocationListPage> createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
  late ApiService _APIService;
  bool isSearching = false;
  FocusNode _focusNode = FocusNode();
  TextEditingController _searchController = TextEditingController();
  late Future<List<LocationWithShift>> _allLocation;

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
    _allLocation = _APIService.getAllListLocaion();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _navigateToLocationEditPage(bool isEdit,
      [LocationWithShift? location]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationEditPage(
          location: location,
          isEdit: isEdit,
        ),
      ),
    );

    print('Result from ShiftEditPage: $result');

    if (result == true) {
      setState(() {
        print('đã load lại data');
        _allLocation = _APIService.getAllListLocaion();
      });
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
                    : Text('Danh sách nhân viên',
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
          body: Stack(
            children: [
              FutureBuilder<List<LocationWithShift>>(
                future: _allLocation,
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
                        final location = snapshot.data![index];
                        return Column(
                          children: [
                            ListTile(
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 18,
                                    color: mainColor,
                                  ),
                                  Text(
                                    location.locationName,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        size: 15,
                                      ),
                                      Text(' Ca làm: ${location.shiftName} '),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_outlined,
                                        size: 15,
                                      ),
                                      Text(
                                        ' ${location.startTime} đến ${location.endTime}', // Dòng thời gian
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 10, // Đường kính của hình tròn
                                        height: 10, // Đường kính của hình tròn
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: location.status ==
                                                  'Đang hoạt động'
                                              ? Colors.green
                                              : Colors
                                                  .red, // Màu sắc dựa trên trạng thái
                                        ),
                                      ),
                                      SizedBox(
                                          width:
                                              8), // Khoảng cách giữa hình tròn và văn bản
                                      Text(
                                        '${location.status}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: location.status ==
                                                  'Đang hoạt động'
                                              ? Colors.green
                                              : Colors
                                                  .red, // Màu sắc dựa trên trạng thái
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      width:
                                          8), // Khoảng cách giữa trạng thái và mũi tên
                                  Icon(Icons.arrow_forward_ios,
                                      size: 16), // Mũi tên kiểu iOS
                                ],
                              ),
                              onTap: () {
                                _navigateToLocationEditPage(true, location);
                              },
                            ),
                            if (index < snapshot.data!.length - 1)
                              Divider(
                                height: 1,
                                thickness: 0,
                              ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
              Positioned(
                bottom: 20,
                right: 20,
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
                  elevation: 8.0,
                  shape: CircleBorder(),
                  onPress: () {
                    _navigateToLocationEditPage(false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
