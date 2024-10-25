import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_InfoCard.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/manager_page/personnel_manager_page/personnel_info_manager_page/personnel_info_manager_page.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/location_manager_page/location_edit_page.dart';
import 'package:flutter_app_chat/pages/manager_page/showtime_manager_page/showtime_edit_manager_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ShiftEditPage extends StatefulWidget {
  const ShiftEditPage({super.key});

  @override
  State<ShiftEditPage> createState() => _ShiftEditPageState();
}

class _ShiftEditPageState extends State<ShiftEditPage> {
  late ApiService _APIService;
  bool isSearching = false;
  FocusNode _focusNode = FocusNode();
  TextEditingController _searchController = TextEditingController();
  late Future<List<User>> _alluser;
  TextEditingController shiftNameController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController isCrossDateController = TextEditingController();
  String? selectedShiftType;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
    _alluser = _APIService.getUserListForAdmin();
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
                    : Text('Sửa ca',
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
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  children: [
                    const MyTextfield(
                      placeHolder: 'Tên ca làm',
                      icon: Icons.drive_file_rename_outline,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: MyTextfield(
                            controller: startTimeController,
                            isTimePicker: true,
                            isPassword: false,
                            placeHolder: "Giờ bắt đầu",
                            sendCode: false,
                            icon: Icons.timer_sharp,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MyTextfield(
                            controller: endTimeController,
                            isTimePicker: true,
                            isPassword: false,
                            placeHolder: "Giờ kết thúc",
                            sendCode: false,
                            icon: Icons.access_time,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        labelText: 'Loại ca làm',
                      ),
                      value: selectedShiftType, // Giá trị được chọn
                      items: const [
                        DropdownMenuItem(
                          value: 'Không qua đêm',
                          child: Text('Không qua đêm'),
                        ),
                        DropdownMenuItem(
                          value: 'Qua đêm',
                          child: Text('Qua đêm'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedShiftType = value; // Cập nhật giá trị đã chọn
                        });
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        labelText: 'Trạng thái',
                      ),
                      value: selectedStatus, // Giá trị được chọn
                      items: const [
                        DropdownMenuItem(
                          value: 'Đang hoạt động',
                          child: Text('Đang hoạt động'),
                        ),
                        DropdownMenuItem(
                          value: 'Ngưng hoạt động',
                          child: Text('Ngưng hoạt động'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value; // Cập nhật giá trị đã chọn
                        });
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    MyButton(
                        fontsize: 20,
                        paddingText: 10,
                        text: 'Đặt vé ngay',
                        isBold: true,
                        onTap: () {})
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
