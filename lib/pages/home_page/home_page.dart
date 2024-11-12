import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/ticket_screen/my_tickets_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/favorite_page.dart';
import 'package:flutter_app_chat/pages/home_page/check_user_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'dart:async';

import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/film_home_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';

class HomePage extends StatefulWidget {
  final int initialPageIndex;
  final List<MovieDetails> filmDangChieu;
  final List<MovieDetails> filmSapChieu;

  HomePage({
    this.initialPageIndex = 0,
    List<MovieDetails>? filmDangChieu,
    List<MovieDetails>? filmSapChieu,
  })  : filmDangChieu = filmDangChieu ?? [],
        filmSapChieu = filmSapChieu ?? [];

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
  bool _isBottomNavVisible = true; // Trạng thái của BottomNavigationBar
  final ValueNotifier<double> _scrollNotifier = ValueNotifier<double>(0.0);
  final double _maxBottomNavHeight = 50.0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _page = widget.initialPageIndex;
    _pageController = PageController(initialPage: _page);

    _filmDangChieu = List.from(widget.filmDangChieu);
    _filmSapChieu = List.from(widget.filmSapChieu);

    if (_filmDangChieu.isEmpty && _filmSapChieu.isEmpty) {
      _fetchMovies();
    } else {
      _setLoading(false);
    }

    _scrollController.addListener(_handleScroll);
  }

  Future<void> _fetchMovies() async {
    ApiService apiService = ApiService();
    _setLoading(true);

    try {
      final moviesDangChieu = await apiService.getMoviesDangChieu();
      final moviesSapChieu = await apiService.getMoviesSapChieu();

      setState(() {
        _filmDangChieu = moviesDangChieu;
        _filmSapChieu = moviesSapChieu;
      });
    } catch (e) {
      print('Error fetching movies: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      _setBottomNavVisible(false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      _setBottomNavVisible(true);
    }
  }

  void _setBottomNavVisible(bool isVisible) {
    setState(() {
      _isBottomNavVisible = isVisible;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: SafeArea(
        top: false, // Không áp dụng padding cho phần trên

        child: Scaffold(
          backgroundColor: Colors.white,
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : IndexedStack(
                  index: _page,
                  children: [
                    FilmSelectionPage(
                      filmDangChieu: _filmDangChieu,
                      filmSapChieu: _filmSapChieu,
                      scrollNotifier: _scrollNotifier,
                    ),
                    MyTicketsPage(),
                    FavoritePage(),
                    CheckUserPage(),
                  ],
                ),
          bottomNavigationBar: _buildAnimatedBottomNavBar(),
        ),
      ),
    );
  }

  Widget _buildAnimatedBottomNavBar() {
    return ValueListenableBuilder<double>(
      valueListenable: _scrollNotifier,
      builder: (context, scrollValue, child) {
        double navBarHeight =
            (_maxBottomNavHeight - scrollValue).clamp(0.0, _maxBottomNavHeight);
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          height: navBarHeight,
          child: navBarHeight > 0
              ? FractionallySizedBox(
                  heightFactor: navBarHeight / _maxBottomNavHeight,
                  child: _buildBottomNavBar(
                      navBarHeight), // Truyền chiều cao vào đây
                )
              : SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildBottomNavBar(double navBarHeight) {
    return CurvedNavigationBar(
      items: _navigatorItems,
      height: navBarHeight,
      backgroundColor: bgColor,
      animationCurve: Curves.easeInOut,
      buttonBackgroundColor: Colors.white,
      animationDuration: Duration(milliseconds: 100),
      onTap: (index) {
        setState(() {
          _page = index;
          bgColor = _getPageBackgroundColor(index);

          // Kiểm tra nếu đang chuyển đến tab "Chọn phim"
          if (index == 2) {
            _fetchMovies(); // Reload lại dữ liệu phim
          }
        });
      },
    );
  }

  Future<bool> _handleWillPop() async {
    final now = DateTime.now();
    const maxDuration = Duration(seconds: 2);

    if (lastPressed == null || now.difference(lastPressed!) > maxDuration) {
      lastPressed = now;
      _showExitSnackbar(context);
      return false;
    }

    return true;
  }

  void _showExitSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Nhấn lần nữa để thoát',
          style: TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 10),
        margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
      ),
    );
  }

  List<Widget> get _navigatorItems {
    return [
      _buildNavItem(Icons.movie, 'Chọn phim', 0, false),
      _buildNavItem(Icons.confirmation_number, 'Vé của tôi', 1, false),
      _buildNavItem(Icons.favorite, 'Yêu thích', 2, false),
      _buildNavItem(Icons.person, 'Tôi', 3, true),
    ];
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool? isLogin) {
    bool isSelected = index == _page;

    // Kiểm tra người dùng có tồn tại không
    bool isUserLoggedIn = UserManager.instance.user != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        (isUserLoggedIn && isLogin == true)
            ? Container(
                width: isSelected ? 30 : 25, // Kích thước cho avatar
                height: isSelected ? 30 : 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/${UserManager.instance.user!.photo ?? 'avatar.jpg'}'),
                    fit: BoxFit.cover, // Điều chỉnh hình ảnh
                  ),
                ),
              )
            : Icon(
                icon,
                size: isSelected ? 20 : 18,
                color: isSelected ? mainColor : Colors.black,
              ),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isSelected ? 10 : 8,
            color: isSelected ? mainColor : Colors.black,
          ),
        ),
      ],
    );
  }

  Color _getPageBackgroundColor(int index) {
    return Color(0XFFf2f2f2);
  }
}
