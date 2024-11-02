import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_InfoCard.dart';
import 'package:flutter_app_chat/models/Shift_modal.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/manager_page/personnel_manager_page/personnel_info_manager_page/personnel_info_manager_page.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/location_manager_page/location_edit_page.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/shift_page/shift_edit_page.dart';
import 'package:flutter_app_chat/pages/manager_page/showtime_manager_page/showtime_edit_manager_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ShiftListPage extends StatefulWidget {
  const ShiftListPage({super.key});

  @override
  State<ShiftListPage> createState() => _ShiftListPageState();
}

class _ShiftListPageState extends State<ShiftListPage> {
  late ApiService _APIService;
  bool isSearching = false;
  FocusNode _focusNode = FocusNode();
  TextEditingController _searchController = TextEditingController();
  late Future<List<Shift>> _allShift;
  List<Shift> _filteredShifts = [];

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
    _allShift = _APIService.getAllListShift();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredShifts = [];
      });
      return;
    }

    _allShift.then((shifts) {
      setState(() {
        _filteredShifts = shifts.where((shift) {
          return shift.shiftName
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              shift.startTime
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              shift.endTime
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              shift.status
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase());
        }).toList();
      });
    });
  }

  Future<void> _navigateToShiftEditPage(bool isEdit, [Shift? shift]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShiftEditPage(
          shift: shift,
          isEdit: isEdit,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _allShift = _APIService.getAllListShift();
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
              onPressed: () => Navigator.of(context).pop(),
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
              child: isSearching
                  ? Container(
                      width: double.infinity,
                      height: 40,
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm ca làm',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  : Text('Danh sách ca làm',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  isSearching ? Icons.close : Icons.search,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    isSearching = !isSearching;
                    if (!isSearching) {
                      _searchController.clear();
                    }
                  });
                },
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              FutureBuilder<List<Shift>>(
                future: _allShift,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Không tìm thấy ca làm nào.'));
                  } else {
                    final displayedShifts = _searchController.text.isNotEmpty
                        ? _filteredShifts
                        : snapshot.data!;

                    if (_searchController.text.isNotEmpty &&
                        _filteredShifts.isEmpty) {
                      return Center(
                          child: Text('Không tìm thấy kết quả phù hợp'));
                    }

                    return ListView.builder(
                      itemCount: displayedShifts.length,
                      itemBuilder: (context, index) {
                        final shift = displayedShifts[index];
                        return Column(
                          children: [
                            ListTile(
                              title: Row(
                                children: [
                                  Text(
                                    shift.shiftName,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 8),
                                ],
                              ),
                              subtitle: Text(
                                'Từ ${shift.startTime} đến ${shift.endTime}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              shift.status == 'Đang hoạt động'
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '${shift.status}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              shift.status == 'Đang hoạt động'
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_ios, size: 16),
                                ],
                              ),
                              onTap: () {
                                _navigateToShiftEditPage(true, shift);
                              },
                            ),
                            if (index < displayedShifts.length - 1)
                              Divider(height: 1, thickness: 0),
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
                    _navigateToShiftEditPage(false);
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
