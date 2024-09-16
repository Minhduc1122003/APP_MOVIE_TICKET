import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/my_tickets_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/history_page.dart';
import 'package:flutter_app_chat/pages/home_page/check_user_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'dart:async';

import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/film_home_page.dart';

class HomePage extends StatefulWidget {
  final int initialPageIndex;

  HomePage({this.initialPageIndex = 0});

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  int _page = 0;
  Color bgColor = Color(0XFFf2f2f2);
  late final PageController _pageController;
  DateTime? lastPressed; // Thời gian của lần nhấn nút quay lại gần nhất

  @override
  void initState() {
    super.initState();
    _page = widget.initialPageIndex;
    _pageController = PageController(initialPage: _page);

    print('UserManager from home_page: ${UserManager.instance.user?.email}');
  }

  List<Widget> get _navigatorItems {
    return [
      _buildNavItem(Icons.movie, 'Chọn phim', 0),
      _buildNavItem(Icons.confirmation_number, 'Vé của tôi', 1),
      _buildNavItem(Icons.history, 'Lịch sử', 2),
      _buildNavItem(Icons.person, 'Tôi', 3),
    ];
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = index == _page;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isSelected ? 20 : 18, // Giảm kích thước của biểu tượng
          color: isSelected
              ? Color(0XFF6F3CD7)
              : Colors.black, // Thay đổi màu sắc của biểu tượng
        ),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isSelected ? 10 : 8, // Giảm kích thước chữ
            color: isSelected
                ? Color(0XFF6F3CD7)
                : Colors.black, // Thay đổi màu chữ
          ),
        ),
      ],
    );
  }

  Widget _buildPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return FilmSelectionPage();
      case 1:
        return MyTicketsPage();
      case 2:
        return HistoryPage();
      case 3:
        return CheckUserPage();
      default:
        return const Center(
            child: Text('Unknown page', style: TextStyle(fontSize: 24)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        final maxDuration = Duration(
            seconds: 2); // Thời gian cho phép giữa hai lần nhấn nút quay lại
        bool backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
            lastPressed == null || now.difference(lastPressed!) > maxDuration;

        if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
          lastPressed =
              DateTime.now(); // Cập nhật thời gian của lần nhấn nút quay lại
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Nhấn lần nữa để thoát',
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              duration: maxDuration,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(
                  vertical: 10), // Điều chỉnh padding nếu cần
              margin: EdgeInsets.only(
                  bottom: 16, left: 16, right: 16), // Điều chỉnh margin nếu cần
            ),
          );

          return false; // Không thoát khỏi ứng dụng
        }
        return true; // Thoát khỏi ứng dụng
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _page, // Hiển thị chỉ một trang tại một thời điểm
          children: [
            FilmSelectionPage(),
            MyTicketsPage(),
            HistoryPage(),
            CheckUserPage(),
          ],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          items: _navigatorItems,
          height: 50,
          backgroundColor: bgColor,
          animationCurve: Curves.easeInOut,
          buttonBackgroundColor: Colors.white,
          animationDuration: Duration(milliseconds: 100),
          onTap: (index) {
            setState(() {
              _page = index;
              bgColor = _getPageBackgroundColor(index);
            });
          },
          letIndexChange: (index) => true,
        ),
      ),
    );
  }

  Color _getPageBackgroundColor(int index) {
    return Color(0XFFf2f2f2); // Sử dụng màu nền chung cho tất cả các trang
  }
}
