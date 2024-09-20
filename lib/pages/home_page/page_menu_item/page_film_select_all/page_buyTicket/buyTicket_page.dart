import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/fim_info/bloc/film_info_Bloc.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/bloc/buyTicket_Bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuyTicketPage extends StatefulWidget {
  final int movieId;

  const BuyTicketPage({super.key, required this.movieId});

  @override
  _BuyTicketPageState createState() => _BuyTicketPageState();
}

class _BuyTicketPageState extends State<BuyTicketPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BuyticketBloc()..add(LoadData1([])),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0XFF6F3CD7),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.white,
              size: 16,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Trung Tâm Đặt Vé',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MovieHeader(movieId: widget.movieId),
              SizedBox(
                height: 20,
              ),
              Divider(
                height: 0,
                thickness: 6,
                color: Color(0xfff0f0f0),
              ),
              DateSelector(),
              SizedBox(
                height: 10,
              ),
              TimeSelector(),
              _buildCinemaItem('Cinema A', '12 km',
                  ['9:00', '11:00', '13:30', '15:30', '17:30']),
              _buildCinemaItem('Cinema B', '4.2 km',
                  ['9:00', '11:00', '13:30', '15:30', '17:30']),
              _buildCinemaItem('Cinema C', '9.1 km',
                  ['9:00', '11:00', '13:30', '15:30', '17:30']),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // Giữ trạng thái của trang
}

class _PersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _PersistentHeaderDelegate({required this.child});

  @override
  double get minExtent => _getHeight(child);

  @override
  double get maxExtent => _getHeight(child);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true; // Luôn tái xây dựng
  }

  double _getHeight(Widget widget) {
    // Tính chiều cao của widget bằng cách sử dụng GlobalKey
    final key = GlobalKey();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final height = renderBox.size.height;
        // Cập nhật kích thước nếu cần
      }
    });
    // Giá trị mặc định
    return 180.0; // Thay đổi thành chiều cao của widget
  }
}

class MovieHeader extends StatefulWidget {
  final int movieId;
  const MovieHeader({super.key, required this.movieId});

  @override
  _MovieHeaderState createState() => _MovieHeaderState();
}

class _MovieHeaderState extends State<MovieHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool isFavourite = false;
  late ApiService _APIService;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _APIService = ApiService();
  }

  Future<MovieDetails?> _loadMovieDetails() async {
    return await _APIService.findByViewMovieID(
        widget.movieId, UserManager.instance.user?.userId ?? 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      padding: EdgeInsets.all(10),
      child: FutureBuilder<MovieDetails?>(
        future: _loadMovieDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Không có dữ liệu'));
          }

          final movieDetails = snapshot.data!;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 10),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Image.asset(
                    'assets/images/${movieDetails.posterUrl}',
                    width: 130,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      '${movieDetails.title}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      minFontSize: 18,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${movieDetails.genres}',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      child: Text(
                        '${movieDetails.age}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: RatingSection(
                              movieDetails:
                                  movieDetails), // Truyền dữ liệu vào đây
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class RatingSection extends StatelessWidget {
  final MovieDetails movieDetails;

  const RatingSection({Key? key, required this.movieDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: BlocBuilder<FilmInfoBloc, FilmInfoBlocState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: Row(
                    children: [
                      // Phần tử chiếm 40% chiều rộng
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star,
                                    color: Colors.orange, size: 30),
                                Text('${movieDetails.averageRating}',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange)),
                                Text(' /10',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16)),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text('(${movieDetails.reviewCount} đánh giá)',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12)),
                          ],
                        ),
                      ),
                      // Phần tử chiếm 60% chiều rộng
                      Expanded(
                        flex: 6,
                        child: _buildRatingBar(
                            movieDetails), // Gọi hàm với dữ liệu phim
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildRatingBar(MovieDetails movieDetails) {
    int totalReviews = movieDetails.reviewCount;
    if (totalReviews == 0) {
      return Center(child: Text('No reviews yet.'));
    }

    return Column(
      children: [
        _buildRatingRow('9-10', movieDetails.rating9_10, totalReviews),
        _buildRatingRow('7-8', movieDetails.rating7_8, totalReviews),
        _buildRatingRow('5-6', movieDetails.rating5_6, totalReviews),
        _buildRatingRow('3-4', movieDetails.rating3_4, totalReviews),
        _buildRatingRow('1-2', movieDetails.rating1_2, totalReviews),
      ],
    );
  }

  Widget _buildRatingRow(String label, int count, int totalReviews) {
    double percentage = totalReviews > 0 ? count / totalReviews : 0;

    return Row(
      children: [
        SizedBox(
          width: 40,
          child:
              Text(label, style: TextStyle(fontSize: 12, color: Colors.black)),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
        SizedBox(width: 10), // Khoảng cách giữa thanh và số lượng
        Text(
          '($count)', // Hiển thị số lượng đánh giá
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }
}

class DateSelector extends StatefulWidget {
  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  int _selectedIndex = 0; // Lưu trữ chỉ số của item được chọn

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Đặt tiêu đề ở góc trên bên trái
        children: [
          SizedBox(height: 10), // Khoảng cách giữa tiêu đề và danh sách ngày

          Text(
            'Chọn ngày',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10), // Khoảng cách giữa tiêu đề và danh sách ngày

          BlocBuilder<BuyticketBloc, BuyticketBlocState>(
            builder: (context, state) {
              return Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8, // Khoảng cách ngang giữa các button
                        runSpacing:
                            8, // Khoảng cách dọc giữa các hàng của button
                        children: state.daysList
                            .asMap() // Sử dụng asMap để lấy chỉ số của item
                            .entries
                            .map((entry) {
                          int index = entry.key;
                          var dayInfo = entry.value;
                          bool isSelected = index == _selectedIndex;

                          return _buildDateItem(
                            dayInfo['dayMonth'] ?? '',
                            dayInfo['dayOfWeek'] ?? '',
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedIndex =
                                    index; // Cập nhật chỉ số của item được chọn
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(String day, String weekday,
      {bool isSelected = false, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Color(0XFF6F3CD7) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey,
          ),
        ),
        constraints: BoxConstraints(
          minWidth: 50,
          minHeight: 50,
        ),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(weekday,
                    style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : Colors.grey)),
                SizedBox(height: 4), // Khoảng cách giữa các dòng text
                Text(day,
                    style: TextStyle(
                        fontSize: 15,
                        color: isSelected ? Colors.white : Colors.black)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Đặt tiêu đề ở góc trên bên trái
        children: [
          Text(
            'Lọc theo khung giờ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
              height: 5), // Khoảng cách giữa tiêu đề và danh sách thời gian
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly, // Căn đều các button
                    children: List.generate(5, (index) {
                      return _buildTimeSlot('9:00-12:00',
                          isSelected: index == 0, onTap: () {
                        // Update selected time logic here
                      });
                    }),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String time,
      {bool isSelected = false, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 8, 0),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0XFF6F3CD7) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey,
          ),
        ),
        child: Center(
          child: Text(time,
              style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.black)),
        ),
      ),
    );
  }
}

Widget _buildCinemaItem(
    String cinemaName, String distance, List<String> times) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.local_movies, size: 50, color: Color(0XFF6F3CD7)),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cinemaName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'You are near this cinema ($distance)',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 40, // Đặt chiều cao cho các phần tử
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(times.length, (index) {
                          return Expanded(
                            child: _buildTimeSlot(times[index], onTap: () {}),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.favorite_border_sharp),
                onPressed: () {},
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildTimeSlot(String time,
    {bool isSelected = false, required Function() onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Color(0XFF6F3CD7) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.grey,
        ),
      ),
      child: Center(
        child: Text(time,
            style: TextStyle(
                fontSize: 14, color: isSelected ? Colors.white : Colors.black)),
      ),
    ),
  );
}
