import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_InfoCard.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/manager_page/personnel_manager_page/personnel_info_manager_page/personnel_info_manager_page.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/calendar_shift_manager_page/calendar_shift_list_page.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/location_manager_page/location_list_page.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/shift_page/shift_list_page.dart';
import 'package:flutter_app_chat/pages/manager_page/statistical_manager_page/new_personnel_manager_page/new_personnel_info_manager_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:diacritic/diacritic.dart'; // Để xử lý loại bỏ dấu

class StatisticalManagerPage extends StatefulWidget {
  const StatisticalManagerPage({super.key});

  @override
  State<StatisticalManagerPage> createState() => _StatisticalManagerPageState();
}

class _StatisticalManagerPageState extends State<StatisticalManagerPage> {
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
                    : Text('Thống kê tổng quan',
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
                        title: 'Người dùng tổng quan',
                        buttons: [
                          UtilityButton(
                            color: mainColor,
                            title: 'Thống kê người dùng',
                            icon: Icons
                                .people_alt_outlined, // Đổi thành icon phù hợp với "Quản lý người dùng"
                            isExpandable: true,
                            expandedItems: [
                              UtilityButton(
                                color: mainColor,
                                title: 'Khách hàng mới',
                                icon: Icons
                                    .account_box, // Đổi thành icon phù hợp với "Chi tiết người dùng"
                                textStyle: TextStyle(fontSize: 16),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    SlideFromRightPageRoute(
                                      page:
                                          NewPersonnelInfoManagerPage(), // Thay editPage() bằng trang cần chuyển tới
                                    ),
                                  );
                                },
                              ),
                              UtilityButton(
                                color: mainColor,
                                title: 'Tài khoản ngưng hoạt động',
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
                            ],
                            onPressed:
                                () {}, // This will be called when the item is tapped, even if it's expandable
                          ),
                        ],
                      ),
                      UtilitySection(
                        title: 'Hoạt động vé & combo',
                        buttons: [
                          UtilityButton(
                            color: mainColor,
                            title: 'Doanh thu vé',
                            icon: Icons
                                .people_alt_outlined, // Đổi thành icon phù hợp với "Quản lý người dùng"
                            isExpandable: true,
                            expandedItems: [
                              UtilityButton(
                                color: mainColor,
                                title: 'Doanh thu đặt vé online',
                                icon: Icons.image_sharp,
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
                                color: mainColor,
                                title: 'Doanh thu tại quầy',
                                icon: Icons
                                    .add_box, // Đổi thành icon phù hợp với "Chi tiết người dùng"
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
                            color: mainColor,
                            title: 'Doanh thu combo',
                            icon: Icons.movie_rounded,
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
