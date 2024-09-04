import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_listViewCardIteam.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/film_hayDangChieu_screen.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/film_sapChieu_screen.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FilmSelectionPage extends StatefulWidget {
  const FilmSelectionPage({super.key});

  @override
  _FilmSelectionPageState createState() => _FilmSelectionPageState();
}

class _FilmSelectionPageState extends State<FilmSelectionPage> {
  int _currentPage = 0;
  int _currentPage2 = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSlideshow();
  }

  void _startSlideshow() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      setState(() {
        _currentPage++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<SendCodeBloc, SendCodeState>(
        listener: (context, state) async {
          if (state is SendCodeError) {
            print('login LoginError');
            EasyLoading.showError('Sai tài khoản hoặc mật khẩu');
          } else if (state is SendCodeWaiting) {
            EasyLoading.show(status: 'Loading...');
          } else if (state is SendCodeSuccess) {
            await Future.delayed(Duration(milliseconds: 150));
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.7),
                  BlendMode.srcOver,
                ),
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: statusBarHeight,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: [
                    const Text(
                      'PANTHERs CINEMA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        // Implement your search action here
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 90, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            FilmSlideshow(
                              imageList: [
                                'assets/images/slide1.png',
                                'assets/images/slide2.jpg',
                                'assets/images/slide3.jpg',
                              ],
                            ),
                            SizedBox(height: 20),

                            const Text(
                              'PHIM NỔI BẬT',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            SizedBox(height: 10),
                            FilmCarousel(
                              filmList: const [
                                {
                                  'image': 'assets/images/slide1.png',
                                  'title': 'Slide 1 Title',
                                  'rating': 4.5,
                                  'releaseDate': '2023-05-01',
                                },
                                {
                                  'image': 'assets/images/slide2.jpg',
                                  'title': 'Slide 2 Title',
                                  'rating': 4.0,
                                  'releaseDate': '2023-06-15',
                                },
                                {
                                  'image': 'assets/images/slide3.jpg',
                                  'title': 'Slide 3 Title',
                                  'rating': 4.7,
                                  'releaseDate': '2023-07-22',
                                },
                                {
                                  'image': 'assets/images/postermada.jpg',
                                  'title': 'Poster Mada',
                                  'rating': 4.9,
                                  'releaseDate': '2023-08-05',
                                },
                              ],
                            ),
                            SizedBox(height: 20),
                            const Divider(
                              height: 0,
                              thickness: 6,
                              indent: 0,
                              endIndent: 0,
                              color: Colors.white,
                            ),

                            // Đặt đoạn text vào góc trái
                            Align(
                              alignment: Alignment
                                  .centerLeft, // Căn trái giữa theo chiều dọc
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // Căn giữa khoảng cách giữa các phần tử trong Row
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF6F3CD7), // Màu nền
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(
                                            10), // Bo góc dưới bên phải
                                      ),
                                    ),
                                    child: const Text(
                                      'Phim hay đang chiếu',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors
                                            .white, // Màu chữ trắng để nổi bật trên nền màu
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          SlideFromRightPageRoute(
                                              page: FilmHaydangchieuScreen()));
                                    },
                                    child: const Row(
                                      children: [
                                        Text(
                                          'Xem tất cả',
                                          style: TextStyle(
                                            color: Color(0xFF6F3CD7), // Màu nền
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 10),

                            const MyListviewcarditeam(
                              filmList: [
                                {
                                  'image': 'assets/images/slide1.png',
                                  'title': 'Slide 1 Title',
                                  'rating': 4.5,
                                  'releaseDate': '2023-05-01',
                                },
                                {
                                  'image': 'assets/images/postermada.jpg',
                                  'title': 'Poster Mada',
                                  'rating': 4.9,
                                  'releaseDate': '2023-08-05',
                                },
                                {
                                  'image': 'assets/images/slide3.jpg',
                                  'title': 'Slide 3 Title',
                                  'rating': 4.7,
                                  'releaseDate': '2023-07-22',
                                },
                                {
                                  'image': 'assets/images/slide2.jpg',
                                  'title': 'Slide 2 Title',
                                  'rating': 4.0,
                                  'releaseDate': '2023-06-15',
                                },
                                {
                                  'image': 'assets/images/postermada.jpg',
                                  'title': 'Poster Mada',
                                  'rating': 4.9,
                                  'releaseDate': '2023-08-05',
                                },
                                {
                                  'image': 'assets/images/slide3.jpg',
                                  'title': 'Slide 3 Title',
                                  'rating': 4.7,
                                  'releaseDate': '2023-07-22',
                                },
                                {
                                  'image': 'assets/images/postermada.jpg',
                                  'title': 'Poster Mada',
                                  'rating': 4.9,
                                  'releaseDate': '2023-08-05',
                                },
                              ],
                            ),
                            SizedBox(height: 20),
                            const Divider(
                              height: 0,
                              thickness: 6,
                              indent: 0,
                              endIndent: 0,
                              color: Colors.white,
                            ),

                            // Đặt đoạn text vào góc trái
                            Align(
                              alignment: Alignment
                                  .centerLeft, // Căn trái giữa theo chiều dọc
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // Căn giữa khoảng cách giữa các phần tử trong Row
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF6F3CD7), // Màu nền
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(
                                            10), // Bo góc dưới bên phải
                                      ),
                                    ),
                                    child: const Text(
                                      'Phim sắp chiếu',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors
                                            .white, // Màu chữ trắng để nổi bật trên nền màu
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          SlideFromRightPageRoute(
                                              page: FilmSapchieuScreen()));
                                    },
                                    child: const Row(
                                      children: [
                                        Text(
                                          'Xem tất cả',
                                          style: TextStyle(
                                            color: Color(0xFF6F3CD7), // Màu nền
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 10),

                            const MyListviewcarditeam(
                              filmList: [
                                {
                                  'image': 'assets/images/slide1.png',
                                  'title': 'Slide 1 Title',
                                  'rating': 4.5,
                                  'releaseDate': '2023-05-01',
                                },
                                {
                                  'image': 'assets/images/postermada.jpg',
                                  'title': 'Poster Mada',
                                  'rating': 4.9,
                                  'releaseDate': '2023-08-05',
                                },
                                {
                                  'image': 'assets/images/slide3.jpg',
                                  'title': 'Slide 3 Title',
                                  'rating': 4.7,
                                  'releaseDate': '2023-07-22',
                                },
                                {
                                  'image': 'assets/images/slide2.jpg',
                                  'title': 'Slide 2 Title',
                                  'rating': 4.0,
                                  'releaseDate': '2023-06-15',
                                },
                                {
                                  'image': 'assets/images/postermada.jpg',
                                  'title': 'Poster Mada',
                                  'rating': 4.9,
                                  'releaseDate': '2023-08-05',
                                },
                                {
                                  'image': 'assets/images/slide3.jpg',
                                  'title': 'Slide 3 Title',
                                  'rating': 4.7,
                                  'releaseDate': '2023-07-22',
                                },
                                {
                                  'image': 'assets/images/postermada.jpg',
                                  'title': 'Poster Mada',
                                  'rating': 4.9,
                                  'releaseDate': '2023-08-05',
                                },
                              ],
                            ),

                            // Các widget khác có thể được thêm vào dưới đây
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      height: 200,
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
                child: Image.asset(
                  widget.imageList[imageIndex],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 130,
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

class FilmCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> filmList;

  FilmCarousel({required this.filmList});

  @override
  _FilmCarouselState createState() => _FilmCarouselState();
}

class _FilmCarouselState extends State<FilmCarousel> {
  late PageController _pageController;
  late int _currentPage;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.filmList.length * 100;
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.5,
    );
    _startSlideshow();
  }

  void _startSlideshow() {
    _timer = Timer.periodic(Duration(seconds: 7), (Timer timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 1000),
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
      height: 350, // Tăng chiều cao để có đủ không gian cho thông tin phim
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.filmList.length * 1000,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemBuilder: (context, index) {
          final filmIndex = index % widget.filmList.length;
          final film = widget.filmList[filmIndex];

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double scale = 1.0;
              if (_pageController.position.haveDimensions) {
                double pageOffset = _pageController.page! - index;
                scale = (1 - (pageOffset.abs() * 0.3)).clamp(0.8, 1.0);
              }
              return Transform.scale(
                scale: scale,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Bỏ Border.all()
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                film['image'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0XFFffd700),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  'TOP ${filmIndex + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Căn giữa các phần tử trong cột
                          children: [
                            Text(
                              film['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign:
                                  TextAlign.center, // Căn giữa nội dung text
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // Căn giữa các phần tử trong hàng
                              children: [
                                Icon(Icons.star,
                                    color: Colors.yellow, size: 18),
                                SizedBox(width: 5),
                                Text(
                                  '${film['rating']}/5',
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  '(${film['rating']} lượt đánh giá)',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFFA69E9E)),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Ngày phát hành: ${film['releaseDate']}',
                              style: TextStyle(fontSize: 14),
                              textAlign:
                                  TextAlign.center, // Căn giữa nội dung text
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
