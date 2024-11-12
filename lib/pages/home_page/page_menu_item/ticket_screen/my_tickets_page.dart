import 'package:flutter/material.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/ticket_screen/ticket_tab.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MyTicketsPage extends StatefulWidget {
  @override
  _MyTicketsPageState createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    List<String> tabTitles = [
      'Vé đã mua',
      'Lịch sử đặt chỗ',
    ];

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
          automaticallyImplyLeading: false,
          title: Text(
            'Lịch sử giao dịch',
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
