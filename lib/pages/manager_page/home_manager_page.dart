import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/buyTicket_page.dart';
import 'package:flutter_app_chat/pages/manager_page/bloc/hometab_bloc.dart';
import 'package:flutter_app_chat/pages/manager_page/movie_manager_page/movie_manager_page.dart';
import 'package:flutter_app_chat/pages/manager_page/personnel_manager_page/personnel_manager_page.dart';
import 'package:flutter_app_chat/pages/manager_page/scan_code_manager/scan_QRcode.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/shift_manager_page.dart';
import 'package:flutter_app_chat/pages/manager_page/showtime_manager_page/showtime_manager_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:auto_size_text/auto_size_text.dart'; // Import package

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

@override
class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeTabBloc()
        ..add(LoadHomeTabData(
            UserManager.instance.user!.fullName, '5', '3', '90', '20')),
      child: FutureBuilder(
        future: initializeDateFormatting('vi_VN', null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              backgroundColor: Colors.blue,
              body: SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(),
                    _buildDateTimeDisplay(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              _buildGridView(),
                              const SizedBox(height: 20),
                              FilmSlideshow(
                                imageList: const [
                                  'assets/images/slide1.png',
                                  'assets/images/slide2.jpg',
                                  'assets/images/slide3.jpg',
                                ],
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              BlocBuilder<HomeTabBloc, HomeTabState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Đăng xuất"),
                                content: Text(
                                    "Bạn có chắc chắn muốn đăng xuất không?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Đóng dialog
                                    },
                                    child: Text("Hủy"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Xử lý đăng xuất tại đây
                                      UserManager.instance.clearUser();
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        ZoomPageRoute(page: HomePage()),
                                        (Route<dynamic> route) =>
                                            false, // Xóa tất cả các route trước đó
                                      );
                                    },
                                    child: Text("Đăng xuất"),
                                  )
                                ],
                              );
                            },
                          );
                        },
                        child: CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/profile.png'),
                          radius: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.greeting,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                          Text(
                            state.userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
// Handle search icon press
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () async {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final cardWidth = screenWidth * 0.95;

          return Container(
            width: screenWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [Colors.blue, Colors.white],
                stops: const [0.3, 0.3],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                color: Colors.white,
                child: SizedBox(
                  width: cardWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
// Date Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: BlocBuilder<HomeTabBloc, HomeTabState>(
                            builder: (context, state) {
                              return Column(
                                children: [
                                  Text(
                                    state.dayOfWeek,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.dayMonth,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
// Attendance Status
                        const Flexible(
                          child: Padding(
                            padding: EdgeInsets.all(1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  'Hôm nay bạn chưa chấm công',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.left,

                                  maxLines: 1, // Giới hạn số dòng hiển thị là 2

                                  minFontSize:
                                      12, // Kích thước font tối thiểu khi tự động điều chỉnh
                                ),
                                SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'SA 8:30',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.check_circle,
                                            color: Colors.green, size: 16),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'CH 13:30',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.remove_circle,
                                            color: Colors.red, size: 16),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
// Location Badge
                        // Action Icon (Right side)
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                                icon: const Icon(
                                  Icons.fullscreen,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                onPressed: () {}),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView() {
    return BlocBuilder<HomeTabBloc, HomeTabState>(
      builder: (context, state) {
        return GridView.count(
          crossAxisCount: 3,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildGridItem('Đặt vé', 'Đặt vé', state.nhanSu, Icons.local_movies,
                Colors.blue, () {}),
            _buildGridItem('Đặt combo', 'Thêm bắp/nước', state.tuyenDung,
                Icons.fastfood, Colors.green, () {
              // Thêm sự kiện khi tap vào Tuyển dụng
              print('Tuyển dụng pressed');
            }),
            _buildGridItem('Quét mã', 'QR vào cổng', state.donTu,
                Icons.qr_code_scanner, Colors.orange, () {
              Navigator.push(
                  context, SlideFromRightPageRoute(page: ScanQrcode()));
              // Thêm sự kiện khi tap vào Đơn từ
            }),
            _buildGridItem('Lịch sử', 'Lịch sử đặt vé/combo', state.count,
                Icons.history, Colors.blue, () {
              // Thêm sự kiện khi tap vào Cuộc họp
            }),
            _buildGridItem('Cài đặt', 'Thiết lập ca làm', state.count,
                Icons.settings, Colors.purple, () {
              Navigator.push(
                  context, SlideFromRightPageRoute(page: ShiftManagerPage()));
            }),
            _buildGridItem('Nhân Sự', 'Quản lý nhân sự', state.count,
                Icons.people_alt_outlined, Colors.purple, () {
              Navigator.push(context,
                  SlideFromRightPageRoute(page: PersonnelManagerPage()));
              // Thêm sự kiện khi tap vào Cuộc họp
            }),
            _buildGridItem('Phim', 'Quản lý phim', state.count,
                Icons.local_movies_outlined, Colors.purple, () {
              Navigator.push(
                  context, SlideFromRightPageRoute(page: MovieManagerPage()));
            }),
            _buildGridItem('Lịch chiếu', 'Quản lý lịch chiếu', state.count,
                Icons.calendar_month_outlined, Colors.purple, () {
              Navigator.push(context,
                  SlideFromRightPageRoute(page: ShowtimeManagerPage()));
            }),
            _buildGridItem('Thống kê', 'Thống kê doanh thu', state.count,
                Icons.bar_chart, Colors.purple, () {
              // Thêm sự kiện khi tap vào Cuộc họp
            }),
          ],
        );
      },
    );
  }

  Widget _buildGridItem(String title, String title2, String count,
      IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate the icon size as a fraction of the container's width
            double iconSize =
                constraints.maxWidth * 0.35; // 20% of the container's width

            return Stack(
              children: [
                Positioned(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontSize: 16,
                          ),
                          minFontSize: 14,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AutoSizeText(
                          title2,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          minFontSize: 10,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: AutoSizeText(
                              count.length < 2 ? ' $count ' : count,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              minFontSize: 10,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      icon,
                      color: color,
                      size: iconSize, // Use calculated icon size
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class FilmSlideshow extends StatefulWidget {
  final List<String> imageList;

  FilmSlideshow({required this.imageList});

  @override
  _FilmSlideshowState createState() => _FilmSlideshowState();
}

class _FilmSlideshowState extends State<FilmSlideshow> {
  late PageController _pageController;
  late int _currentPage;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentPage =
        widget.imageList.length * 100; // Start from the middle of the list
    _pageController = PageController(initialPage: _currentPage);
    _startSlideshow();
  }

  void _startSlideshow() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // Set the height to 150
      width: double.infinity, // Set width to full screen
      padding: EdgeInsets.all(10), // Add padding
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: widget.imageList.length * 1000, // Infinite loop
            itemBuilder: (context, index) {
              // Loop through the image list
              final imageIndex = index % widget.imageList.length;
              return AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Border radius
                  child: Image.asset(
                    widget.imageList[imageIndex],
                    fit: BoxFit.cover, // Full-screen fit
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 10, // Adjusted to be within the container
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageList.length, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width:
                      _currentPage % widget.imageList.length == index ? 8 : 4,
                  height:
                      _currentPage % widget.imageList.length == index ? 8 : 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage % widget.imageList.length == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
