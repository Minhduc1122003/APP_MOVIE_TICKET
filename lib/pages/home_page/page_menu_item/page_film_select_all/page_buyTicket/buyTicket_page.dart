import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/fim_info/bloc/film_info_Bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuyTicketPage extends StatefulWidget {
  final int movieId;

  const BuyTicketPage({super.key, required this.movieId});

  @override
  _BuyTicketPageState createState() => _BuyTicketPageState();
}

class _BuyTicketPageState extends State<BuyTicketPage>
    with AutomaticKeepAliveClientMixin {
  late ApiService _APIService;

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
  }

  Future<MovieDetails?> _loadMovieDetails() async {
    return await _APIService.findByViewMovieID(
        widget.movieId, UserManager.instance.user?.userId ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<MovieDetails?>(
      future: _loadMovieDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final movie = snapshot.data;
          return BlocProvider(
            create: (context) => FilmInfoBloc()..add(LoadData(movie)),
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
                  'Mua vé phim',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                centerTitle: true,
              ),
              backgroundColor: Colors.white,
              body: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    delegate: _PersistentHeaderDelegate(
                      child: Column(
                        children: [
                          DateSelector(),
                          TimeSelector(),
                        ],
                      ),
                    ),
                    pinned: true, // Giữ phần header cố định khi cuộn
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        CinemaList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
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

class DateSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8, // Khoảng cách ngang giữa các button
                runSpacing: 8, // Khoảng cách dọc giữa các hàng của button
                children: List.generate(30, (index) {
                  // Giả sử bạn có 30 button để hiển thị
                  return _buildDateItem('29', 'T3', isSelected: index == 0,
                      onTap: () {
                    // Update selected date logic here
                  });
                }).take(8).toList(), // Chỉ lấy tối đa 8 button
              ),
            ),
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
        width: 60, // Điều chỉnh chiều rộng của button
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0XFF6F3CD7) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa các text
          children: [
            Text(day,
                style: TextStyle(
                    fontSize: 18,
                    color: isSelected ? Colors.white : Colors.black)),
            Text(weekday,
                style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class TimeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Căn đều các button
                children: List.generate(5, (index) {
                  return _buildTimeSlot('9:00-12:00', isSelected: index == 0,
                      onTap: () {
                    // Update selected time logic here
                  });
                }),
              ),
            ),
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

class CinemaList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics:
          NeverScrollableScrollPhysics(), // Ngăn chặn cuộn của ListView bên trong SingleChildScrollView
      children: [
        _buildCinemaItem(
            'Cinema A', '12 km', ['9:00', '11:00', '13:30', '15:30', '17:30']),
        _buildCinemaItem(
            'Cinema B', '4.2 km', ['9:00', '11:00', '13:30', '15:30', '17:30']),
        _buildCinemaItem(
            'Cinema C', '9.1 km', ['9:00', '11:00', '13:30', '15:30', '17:30']),
        _buildCinemaItem(
            'Cinema C', '9.1 km', ['9:00', '11:00', '13:30', '15:30', '17:30']),
        _buildCinemaItem('Cinema C', '9.1 km', ['9:00']),
        _buildCinemaItem('Cinema C', '9.1 km', []),
        _buildCinemaItem('Cinema C', '9.1 km', []),
      ],
    );
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
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.black)),
        ),
      ),
    );
  }
}
