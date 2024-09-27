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
  final List<MovieDetails> filmDangChieu;
  final List<MovieDetails> filmSapChieu;

  HomePage({
    this.initialPageIndex = 0,
    List<MovieDetails>? filmDangChieu, // Làm cho nó có thể null
    List<MovieDetails>? filmSapChieu, // Làm cho nó có thể null
  })  : filmDangChieu =
            filmDangChieu ?? [], // Mặc định là danh sách rỗng nếu null
        filmSapChieu =
            filmSapChieu ?? []; // Mặc định là danh sách rỗng nếu null

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  int _page = 0;
  Color bgColor = Color(0XFFf2f2f2);
  late final PageController _pageController;
  DateTime? lastPressed; // Thời gian của lần nhấn nút quay lại gần nhất
  bool _isLoading = true; // Trạng thái loading
  List<MovieDetails> _filmDangChieu = [];
  List<MovieDetails> _filmSapChieu = [];

  @override
  void initState() {
    super.initState();
    _page = widget.initialPageIndex;
    _pageController = PageController(initialPage: _page);

    // Gán dữ liệu từ widget vào các danh sách nội bộ
    _filmDangChieu = List.from(widget.filmDangChieu);
    _filmSapChieu = List.from(widget.filmSapChieu);

    // Kiểm tra nếu dữ liệu phim đang chiếu và sắp chiếu rỗng
    if (_filmDangChieu.isEmpty && _filmSapChieu.isEmpty) {
      _fetchMovies(); // Gọi hàm lấy phim từ API
    } else {
      setState(() {
        _isLoading = false; // Nếu có dữ liệu, tắt trạng thái loading
      });
    }
  }

  Future<void> _fetchMovies() async {
    ApiService apiService = ApiService();
    try {
      setState(() {
        _isLoading = true; // Bắt đầu trạng thái loading
      });

      // Lấy phim đang chiếu và sắp chiếu
      final moviesDangChieu = await apiService.getMoviesDangChieu();
      final moviesSapChieu = await apiService.getMoviesSapChieu();

      // Cập nhật danh sách phim và tắt trạng thái loading
      setState(() {
        _filmDangChieu = moviesDangChieu;
        _filmSapChieu = moviesSapChieu;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching movies: $e');
      setState(() {
        _isLoading = false; // Dù có lỗi cũng tắt trạng thái loading
      });
    }
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
          size: isSelected ? 20 : 18, // Giảm kích thước biểu tượng
          color: isSelected ? Color(0XFF6F3CD7) : Colors.black,
        ),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isSelected ? 10 : 8, // Giảm kích thước chữ
            color: isSelected ? Color(0XFF6F3CD7) : Colors.black,
          ),
        ),
      ],
    );
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
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              duration: maxDuration,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 10),
              margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
            ),
          );

          return false; // Không thoát khỏi ứng dụng
        }
        return true; // Thoát khỏi ứng dụng
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _isLoading
            ? Center(
                child:
                    CircularProgressIndicator()) // Hiển thị vòng xoay loading
            : IndexedStack(
                index: _page, // Chỉ hiển thị một trang tại một thời điểm
                children: [
                  FilmSelectionPage(
                    filmDangChieu:
                        _filmDangChieu, // Truyền dữ liệu từ danh sách nội bộ
                    filmSapChieu: _filmSapChieu,
                  ),
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
