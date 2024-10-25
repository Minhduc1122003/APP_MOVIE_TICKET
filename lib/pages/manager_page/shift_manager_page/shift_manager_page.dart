import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_InfoCard.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/manager_page/personnel_manager_page/personnel_info_manager_page/personnel_info_manager_page.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/location_manager_page/location_list_page.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/shift_page/shift_list_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:diacritic/diacritic.dart'; // Để xử lý loại bỏ dấu

class ShiftManagerPage extends StatefulWidget {
  const ShiftManagerPage({super.key});

  @override
  State<ShiftManagerPage> createState() => _ShiftManagerPageState();
}

class _ShiftManagerPageState extends State<ShiftManagerPage> {
  late ApiService _APIService;
  bool isSearching = false;
  FocusNode _focusNode = FocusNode();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
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
                          hintText: 'Tìm kiếm cài đặt...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: TextStyle(color: Colors.black),
                      )
                    : Text('Cài đặt quản trị',
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
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: keyboardHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      UtilitySection(
                        title: 'Cài đặt quản trị',
                        buttons: [
                          UtilityButton(
                            color: Colors.pink,
                            title: 'Ca làm việc',
                            icon: Icons
                                .people_alt_outlined, // Đổi thành icon phù hợp với "Quản lý người dùng"
                            isExpandable: true,
                            expandedItems: [
                              UtilityButton(
                                color: Colors.pink,
                                title: 'Thiết lập vị trí',
                                icon: Icons.bar_chart,
                                textStyle: TextStyle(fontSize: 16),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    SlideFromRightPageRoute(
                                      page:
                                          LocationListPage(), // Thay editPage() bằng trang cần chuyển tới
                                    ),
                                  );
                                },
                              ),
                              UtilityButton(
                                color: Colors.pink,
                                title: 'Thiết lập ca làm',
                                icon: Icons
                                    .account_box, // Đổi thành icon phù hợp với "Chi tiết người dùng"
                                textStyle: TextStyle(fontSize: 16),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    SlideFromRightPageRoute(
                                      page:
                                          ShiftListPage(), // Thay editPage() bằng trang cần chuyển tới
                                    ),
                                  );
                                },
                              ),
                              // Add more sub-items here as needed
                            ],
                            onPressed:
                                () {}, // This will be called when the item is tapped, even if it's expandable
                          ),
                          UtilityButton(
                            color: Colors.pink,
                            title: 'Phát thông báo',
                            icon: Icons
                                .notifications_active, // Đổi thành icon phù hợp với "Quản lý phim"
                            isExpandable: true,
                            expandedItems: [
                              UtilityButton(
                                color: Colors.pink,
                                title: 'Thông báo cho nhân viên',
                                icon: Icons
                                    .edit_notifications, // Đổi thành icon phù hợp với "Thêm phim sắp chiếu"
                                textStyle: TextStyle(fontSize: 16),
                                onPressed: () {},
                              ),
                              UtilityButton(
                                color: Colors.pink,
                                title: 'Thông báo cho khách hàng',
                                icon: Icons
                                    .notifications, // Đổi thành icon phù hợp với "Chỉnh sửa nội dung"
                                textStyle: TextStyle(fontSize: 16),
                                onPressed: () {},
                              ),
                              // Add more sub-items here as needed
                            ],
                            onPressed:
                                () {}, // This will be called when the item is tapped, even if it's expandable
                          ),
                          UtilityButton(
                            color: Colors.pink,
                            title: 'Quản lý phòng chiếu',
                            icon: Icons
                                .account_box, // Đổi thành icon phù hợp với "Chi tiết người dùng"
                            onPressed: () {},
                          ),
                          UtilityButton(
                            color: Colors.pink,
                            title: 'Báo cáo &  thống kê doanh thu',
                            icon: Icons
                                .account_box, // Đổi thành icon phù hợp với "Chi tiết người dùng"
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Các phần tử cố định ở cuối màn hình
            ],
          )),
    );
  }
}
