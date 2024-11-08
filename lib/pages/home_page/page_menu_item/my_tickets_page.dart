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
      'Vé đã mua',
      'Phim đã xem',
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
          "cinema": "Panthers Tô Ký",
          "showtime": "23:45 | 13/08/2024",
          "image": "assets/images/postermada.jpg",
        },
        // Add more tickets here
      ],
      'Vé đã mua': [
        {
          "title": "Thám tử lừng danh Conan: Ngôi sao nằm trên bầu trời đỏ",
          "cinema": "Panthers Tô Ký",
          "showtime": "23:45 | 13/08/2024",
          "image": "assets/images/postermada.jpg",
        },
        // Add more tickets here
      ],
      'Phim đã xem': [
        {
          "title": "Thám tử lừng danh Conan: Ngôi sao nằm trên bầu trời đỏ",
          "cinema": "Panthers Tô Ký",
          "showtime": "23:45 | 13/08/2024",
          "image": "assets/images/postermada.jpg",
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
                              ticket['cinema']!,
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
