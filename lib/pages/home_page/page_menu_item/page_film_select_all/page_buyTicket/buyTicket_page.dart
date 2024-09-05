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
      child: BlocBuilder<BuyticketBloc, BuyticketBlocState>(
        builder: (context, state) {
          return Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8, // Khoảng cách ngang giữa các button
                    runSpacing: 8, // Khoảng cách dọc giữa các hàng của button
                    children: state.daysList
                        .take(
                            state.daysList.length) // Chỉ hiển thị tối đa 8 ngày
                        .map((dayInfo) {
                      int index = state.daysList.indexOf(dayInfo);
                      bool isSelected = index == 0; // Ví dụ: chọn ngày đầu tiên

                      return _buildDateItem(
                        dayInfo['dayMonth'] ?? '',
                        dayInfo['dayOfWeek'] ?? '',
                        isSelected: isSelected,
                        onTap: () {
                          // Cập nhật logic chọn ngày ở đây
                          print("Chọn ngày: ${dayInfo['dayMonth']}");
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
    );
  }

  Widget _buildDateItem(String day, String weekday,
      {bool isSelected = false, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(5), // Padding 10
        decoration: BoxDecoration(
          color: isSelected ? Color(0XFF6F3CD7) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey,
          ),
        ),
        // Sử dụng constraints để bọc nội dung
        constraints: BoxConstraints(
          minWidth: 50, // Đặt minWidth để tạo kích thước tối thiểu
          minHeight: 50, // Đặt minHeight để tạo kích thước tối thiểu
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Để cột bọc chặt nội dung
          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa các text
          children: [
            Text(day,
                style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.black)),
            SizedBox(height: 4), // Khoảng cách giữa các dòng text
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
