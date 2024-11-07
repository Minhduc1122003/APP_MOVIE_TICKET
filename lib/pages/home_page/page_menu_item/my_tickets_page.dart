import 'package:flutter/material.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MyTicketsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    List<String> tabTitles = [
      'Vé chưa sử dụng',
      'a',
      'b',
    ];

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
          automaticallyImplyLeading: false,
          title: Text(
            'Vé của tôi',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
        ),
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
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: DefaultTabController(
                    length: tabTitles.length,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: TabBar(
                            isScrollable: false, // Set isScrollable to false
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.blue,
                            tabs: tabTitles
                                .map((title) => Tab(text: title))
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: tabTitles.map((title) {
                              return TicketsTabContent(tabName: title);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketsTabContent extends StatefulWidget {
  final String tabName;

  TicketsTabContent({required this.tabName});

  @override
  _TicketsTabContentState createState() => _TicketsTabContentState();
}

class _TicketsTabContentState extends State<TicketsTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    Map<String, List<Map<String, String>>> ticketsByTab = {
      'Vé chưa sử dụng': [
        {
          "title": "Thám tử lừng danh Conan: Ngôi sao nằm trên bầu trời đỏ",
          "rating": "9.5/10 (9.6K đánh giá)",
          "genre": "Hoạt hình, Hành sự, Bí ẩn, Hành động",
          "cinema": "Panthers Tô Ký",
          "duration": "111p",
          "showtime": "23:45 | 13/08/2024",
          "seat": "F6, F7",
          "status": "Đã thanh toán",
          "price": "150.000 VND",
          "image": "assets/images/postermada.jpg",
        },
        // Add more tickets here
      ],
      'a': [
        {
          "title": "Phim hủy 1",
          "rating": "8.0/10 (1K đánh giá)",
          "genre": "Kinh dị, Hài",
          "cinema": "Galaxy Cinema",
          "duration": "95p",
          "showtime": "20:00 | 15/08/2024",
          "seat": "A1, A2",
          "status": "Đã hủy",
          "price": "120.000 VND",
          "image": "assets/images/slide2.jpg",
        },
        // Add more tickets here
      ],
      'b': [
        {
          "title": "Phim chưa thanh toán 1",
          "rating": "7.5/10 (500 đánh giá)",
          "genre": "Hành động, Phiêu lưu",
          "cinema": "CineStar",
          "duration": "110p",
          "showtime": "18:00 | 16/08/2024",
          "seat": "B5, B6",
          "status": "Chưa thanh toán",
          "price": "130.000 VND",
          "image": "assets/images/slide3.jpg",
        },
      ],
    };

    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            padding: EdgeInsets.all(8),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: ticketsByTab[widget.tabName]?.length ?? 0,
            itemBuilder: (context, index) {
              final ticket = ticketsByTab[widget.tabName]![index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              8.0), // Adjust border radius
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              8.0), // Ensure the image has rounded corners
                          child: Image.asset(
                            ticket['image']!,
                            width: 80,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket['title']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              ticket['rating']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              ticket['genre']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              ticket['cinema']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              ticket['duration']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              ticket['showtime']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Chỗ ngồi: ${ticket['seat']}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Trạng thái: ${ticket['status']}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Tổng thanh toán: ${ticket['price']}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
