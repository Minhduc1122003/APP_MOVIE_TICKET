import 'dart:async';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_listViewCardIteam.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/film_hayDangChieu_screen.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/film_sapChieu_screen.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/fim_info/film_information.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilmSelectionPage extends StatefulWidget {
  const FilmSelectionPage({super.key});

  @override
  _FilmSelectionPageState createState() => _FilmSelectionPageState();
}

class _FilmSelectionPageState extends State<FilmSelectionPage>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  Timer? _timer;
  late Future<void> _dataFuture;
  late ApiService _apiService;
  List<MovieDetails> filmDangChieu = [];
  List<MovieDetails> filmSapChieu = [];
  late AnimationController _animationController;
  late Animation<double> _appBarHeightAnimation;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _dataFuture = _fetchData();
    _startSlideshow();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _appBarHeightAnimation =
        Tween<double>(begin: 120.0, end: 80.0).animate(_animationController);

    _scrollController.addListener(() {
      double scrollOffset = _scrollController.offset;
      if (scrollOffset < 10) {
        _animationController.animateTo(120.0);
      } else if (scrollOffset >= 10) {
        _animationController.animateTo(80.0);
      }
    });
  }

  Future<void> _fetchData() async {
    try {
      final moviesDangChieu = await _apiService.getMoviesDangChieu();
      final moviesSapChieu = await _apiService.getMoviesSapChieu();

      setState(() {
        filmDangChieu = moviesDangChieu;
        filmSapChieu = moviesSapChieu;
      });
    } catch (error) {
      print('Có lỗi xảy ra: $error');
    }
  }

  Future<void> _refreshData() async {
    await _fetchData();
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
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
          } else {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    backgroundColor: Color(0XFF6F3CD7),
                    expandedHeight: _appBarHeightAnimation.value,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(bottom: 16.0),
                      title: Align(
                        alignment:
                            Alignment.bottomCenter, // Căn giữa tiêu đề ở dưới
                        child: Text(
                          'PANTHERs CINEMA',
                          style: TextStyle(
                            color: _appBarHeightAnimation.value <= 100
                                ? Colors.white
                                : Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      centerTitle: true,
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/background.png',
                            fit: BoxFit.cover,
                            color: Colors.white.withOpacity(0.6),
                            colorBlendMode: BlendMode.dstATop,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      AnimatedBuilder(
                        animation: _appBarHeightAnimation,
                        builder: (context, child) {
                          bool isSearchIconVisible =
                              _appBarHeightAnimation.value > 80;
                          return isSearchIconVisible
                              ? Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: IconButton(
                                      icon: Icon(Icons.search,
                                          color: Colors.white, size: 27),
                                      onPressed: () {},
                                    ),
                                  ),
                                )
                              : SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(child: _buildContent()),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FilmSlideshow(
          imageList: [
            'assets/images/slide1.png',
            'assets/images/slide2.jpg',
            'assets/images/slide3.jpg',
          ],
        ),
        _buildSectionTitle('PHIM NỔI BẬT'),
        FilmCarousel(
          filmList: _mapMoviesToFilmList(filmDangChieu),
        ),
        SizedBox(
          height: 20,
        ),
        _buildSectionDivider(),
        _buildSectionHeader('Phim hay đang chiếu', FilmHaydangchieuScreen()),
        SizedBox(
          height: 20,
        ),
        MyListviewCardItem(
          filmList: _mapMoviesToFilmList(filmDangChieu),
        ),
        SizedBox(
          height: 20,
        ),
        _buildSectionDivider(),
        _buildSectionHeader('Phim sắp chiếu', FilmSapchieuScreen()),
        SizedBox(
          height: 20,
        ),
        MyListviewCardItem(
          filmList: _mapMoviesToFilmList(filmSapChieu),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _mapMoviesToFilmList(List<MovieDetails> movies) {
    return movies.map((movie) {
      return {
        'image': 'assets/images/${movie.posterUrl}',
        'title': movie.title,
        'rating': movie.averageRating,
        'genre': movie.genres,
        'movieID': movie.movieId
      };
    }).toList();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildSectionDivider() {
    return const Divider(
      height: 0,
      thickness: 6,
      color: Color(0xfff0f0f0),
    );
  }

  Widget _buildSectionHeader(String title, Widget page) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(13, 13, 13, 10),
            decoration: const BoxDecoration(
              color: Color(0xFF6F3CD7),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                SlideFromRightPageRoute(page: page),
              );
            },
            child: Text(
              'Xem tất cả',
              style: TextStyle(
                color: Color(0xFF6F3CD7),
                fontSize: 16,
              ),
            ),
          ),
        ],
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
      height: 170,
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
  Timer?
      _restartTimer; // Timer để khởi động lại sau khi người dùng ngừng thao tác

  @override
  void initState() {
    super.initState();

    _currentPage = 70; // Bắt đầu từ phần tử cuối cùng
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.5,
    );

    _startSlideshow();
  }

  void _startSlideshow() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
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

  // Dừng slideshow
  void _stopSlideshow() {
    _timer?.cancel();
    _timer = null;
  }

  // Khởi động lại slideshow sau 2 giây
  void _restartSlideshow() {
    _restartTimer?.cancel(); // Hủy nếu có timer trước đó
    _restartTimer = Timer(Duration(seconds: 2), () {
      _startSlideshow();
    });
  }

  void _goToNextPage() {
    _stopSlideshow();
    _currentPage = _currentPage + 1;
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    _restartSlideshow();
  }

  void _goToPreviousPage() {
    _stopSlideshow();
    _currentPage = _currentPage - 1;
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    _restartSlideshow();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              _stopSlideshow(); // Dừng slideshow khi người dùng vuốt

              setState(() {
                _currentPage = page;
              });
              _restartSlideshow(); // Khởi động lại slideshow sau 2 giây
            },
            itemBuilder: (context, index) {
              final filmIndex = index % widget.filmList.length;
              final film = widget.filmList[filmIndex];

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 1.0;
                  if (_pageController.position.haveDimensions) {
                    scale = 1 - (_pageController.page! - index).abs() * 0.2;
                    scale = scale.clamp(0.1, 1.0);
                  }
                  return Transform.scale(
                    scale: scale,
                    child: GestureDetector(
                      onTap: () {
                        // In ra ID của phần tử được bấm
                        Navigator.push(
                          context,
                          SlideFromRightPageRoute(
                            page: FilmInformation(movieId: film['movieID']),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            10), // Bỏ cong góc nếu cần
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withOpacity(0.5), // Màu bóng
                                            spreadRadius:
                                                10, // Kích thước mở rộng của bóng
                                            blurRadius: 5, // Độ mờ của bóng
                                            offset: Offset(0,
                                                10), // Vị trí bóng so với phần tử
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            10), // Bỏ cong góc nếu cần
                                        child: Image.asset(
                                          film['image'],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  AutoSizeText(
                                    film['title'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines:
                                        1, // Giới hạn số dòng hiển thị là 2
                                    overflow: TextOverflow
                                        .ellipsis, // Hiển thị "..." khi văn bản quá dài
                                    minFontSize:
                                        14, // Kích thước font tối thiểu khi tự động điều chỉnh
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.yellow, size: 18),
                                      SizedBox(width: 5),
                                      Text(
                                        '${film['rating']}/10',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        '(${film['rating']} lượt đánh giá)',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFA69E9E)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${film['genre']}',
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Positioned(
          left: 10,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: _goToPreviousPage,
          ),
        ),
        Positioned(
          right: 10,
          child: IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: _goToNextPage,
          ),
        ),
      ],
    );
  }
}