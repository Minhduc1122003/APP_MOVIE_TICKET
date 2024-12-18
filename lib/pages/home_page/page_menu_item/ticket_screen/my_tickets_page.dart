import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/BuyTicket_model.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/film_hayDangChieu_screen.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/ticket_screen/infoTicket_page.dart';
import 'package:flutter_app_chat/pages/login_page/login_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:intl/intl.dart';

import 'history_tickets_page.dart';

final myTicketsPage = GlobalKey<_MyTicketsPageState>();

class MyTicketsPage extends StatefulWidget {
  final Function? onRefresh;
  MyTicketsPage({this.onRefresh, Key? key}) : super(key: key ?? myTicketsPage);

  @override
  _MyTicketsPageState createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  late ApiService _apiService;
  late Future<List<BuyTicket>> _futureBuyTickets1;
  late Future<List<BuyTicket>> _futureBuyTickets2;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    if (UserManager.instance.user != null) {
      _futureBuyTickets1 = _fetchBuyticket1();
      _futureBuyTickets2 = _fetchBuyticket2();
    }
  }

  Future<List<BuyTicket>> _fetchBuyticket1() async {
    print('đã gọi load data');
    try {
      // Lấy tất cả danh sách BuyTicket từ API
      List<BuyTicket> buyticket = await _apiService
          .findAllBuyTicketByUserId(UserManager.instance.user!.userId);

      // Lọc ra các mục có isCheckIn = false và status = 'Đã thanh toán'
      List<BuyTicket> filteredBuyTickets = buyticket.where((ticket) {
        return ticket.isCheckIn == false &&
            (ticket.status == 'Đã thanh toán' ||
                ticket.status == 'Ðã thanh toán');
      }).toList();

      widget.onRefresh?.call();

      return filteredBuyTickets; // Trả về danh sách đã lọc
    } catch (e) {
      print('Error fetching buy tickets: $e');
      return [];
    }
  }

  Future<List<BuyTicket>> _fetchBuyticket2() async {
    print('đã gọi load data');
    try {
      // Lấy tất cả danh sách BuyTicket từ API
      List<BuyTicket> buyticket = await _apiService
          .findAllBuyTicketByUserId(UserManager.instance.user!.userId);

      // Lọc ra các mục có isCheckIn = false và status = 'Đã thanh toán'
      List<BuyTicket> filteredBuyTickets = buyticket.where((ticket) {
        return ticket.isCheckIn == true &&
            (ticket.status == 'Đã thanh toán' ||
                ticket.status == 'Ðã thanh toán');
      }).toList();

      widget.onRefresh?.call();

      return filteredBuyTickets; // Trả về danh sách đã lọc
    } catch (e) {
      print('Error fetching buy tickets: $e');
      return [];
    }
  }

  void refreshBuyticket() {
    if (UserManager.instance.user != null) {
      setState(() {
        _futureBuyTickets1 = _fetchBuyticket1();
        _futureBuyTickets2 = _fetchBuyticket2();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
          automaticallyImplyLeading: false,
          title: Text(
            'Vé chưa sử dụng',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Nền mờ
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
            // Nội dung chính
            UserManager.instance.user == null
                ? _buildLoginPromptCard() // Hiển thị thông báo đăng nhập nếu user null
                : FutureBuilder<List<BuyTicket>>(
                    future: _combineFutureLists(), // Method to combine lists
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error loading tickets'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildNoTicketsCard();
                      } else {
                        return _buildTicketsList(snapshot.data!);
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Future<List<BuyTicket>> _combineFutureLists() async {
    final results = await Future.wait([
      _futureBuyTickets1,
      _futureBuyTickets2,
    ]);

    return [...results[0], ...results[1]];
  }

  Widget _buildLoginPromptCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                size: 70,
                color: Colors.deepOrangeAccent,
              ),
              SizedBox(height: 16),
              Text(
                'Bạn chưa đăng nhập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Vui lòng đăng nhập để xem lịch sử',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: MyButton(
                  fontsize: 16,
                  paddingText: 16,
                  text: 'ĐĂNG NHẬP',
                  onTap: () {
                    Navigator.push(
                      context,
                      SlideFromRightPageRoute(
                          page: LoginPage(
                        isBack: true,
                        onPopCallback: () {
                          refreshBuyticket();
                        },
                      )),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoTicketsCard() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.deepOrangeAccent,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 20,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                SlideFromRightPageRoute(page: HistoryTicketsPage()),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  color: Colors.deepOrangeAccent,
                  size: 25,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Lịch sử đặt vé',
                      style: TextStyle(
                        color: Colors.deepOrangeAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.deepOrangeAccent,
                  size: 15,
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 40),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 5),
                    ColorFiltered(
                      colorFilter:
                          ColorFilter.mode(Colors.black, BlendMode.srcIn),
                      child: Image.asset(
                        'assets/images/logoText.png',
                        width: 280,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Bạn không có vé nào chưa sử dụng',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Đặt ngay để không bỏ lỡ những phim hot nhất nhé!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: MyButton(
                        fontsize: 16,
                        paddingText: 16,
                        text: 'Đặt vé ngay',
                        isBold: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            SlideFromRightPageRoute(
                                page: FilmHaydangchieuScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketsList(List<BuyTicket> tickets) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Colors.deepOrangeAccent,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  SlideFromRightPageRoute(page: HistoryTicketsPage()),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    color: Colors.deepOrangeAccent,
                    size: 25,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Lịch sử đặt vé',
                        style: TextStyle(
                          color: Colors.deepOrangeAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.deepOrangeAccent,
                    size: 15,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Flexible(
              child: ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return GestureDetector(
                    onTap: () {
                      if (ticket.status == 'Ðã hủy') {
                        print('Đã hủy không thể mở');
                      } else {
                        // In ra posterUrl khi nhấn vào Card
                        print(ticket.buyTicketId);
                        Navigator.push(
                          context,
                          SlideFromRightPageRoute(
                            page:
                                InfoticketPage(buyTicketID: ticket.buyTicketId),
                          ),
                        );
                      }
                    },
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: ticket.posterUrl,
                                height: 110,
                                width: 80,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                // Hiển thị icon lỗi nếu tải ảnh không thành công
                                fadeInDuration: const Duration(
                                    seconds: 1), // Thời gian hiệu ứng fade-in
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    ticket.movieName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    minFontSize: 14, // Kích thước chữ tối thiểu
                                    maxFontSize: 16, // Kích thước chữ tối đa
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 14),
                                      const SizedBox(width: 5),
                                      AutoSizeText(
                                        '${ticket.startTime} - ${getDayOfWeek(ticket.showtimeDate)}, ${ticket.showtimeDate}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 8,
                                        maxFontSize: 12,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_month_outlined,
                                          size: 14),
                                      const SizedBox(width: 5),
                                      AutoSizeText(
                                        'Ngày tạo: ${formatDateTime(ticket.createDate)}',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.black),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 8,
                                        maxFontSize: 12,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline_rounded,
                                          size: 14),
                                      const SizedBox(width: 5),
                                      AutoSizeText(
                                        '${ticket.status}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: ticket.status ==
                                                  'Chưa thanh toán'
                                              ? Colors.orange
                                              : ticket.status ==
                                                          'Đã thanh toán' ||
                                                      ticket.status ==
                                                          'Ðã thanh toán'
                                                  ? Colors.green
                                                  : ticket.status == 'Ðã hủy'
                                                      ? Colors.redAccent
                                                      : Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 8,
                                        maxFontSize: 12,
                                      ),
                                      if (ticket.status != 'Ðã hủy' &&
                                          ticket.status != 'Chưa thanh toán')
                                        // Hiển thị isCheckIn nếu trạng thái không phải "Đã hủy"
                                        Row(
                                          children: [
                                            Text(
                                              ' - ',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            AutoSizeText(
                                              '${ticket.isCheckIn == false ? 'Chưa sử dụng' : 'Đã sử dụng'}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: ticket.isCheckIn == false
                                                    ? Colors.green
                                                    : Colors.redAccent,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              minFontSize: 8,
                                              maxFontSize: 12,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text(
                                        'Tổng thanh toán: ',
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      AutoSizeText(
                                        '${formatPrice(ticket.totalPrice)}đ',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepOrangeAccent,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 8,
                                        maxFontSize: 12,
                                      ),
                                    ],
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatPrice(double price) {
  final formatter = NumberFormat('#,###', 'vi');
  return formatter.format(price);
}

String getDayOfWeek(String dateStr) {
  DateFormat format = DateFormat("dd/MM/yyyy");
  DateTime date = format.parse(dateStr);

  int weekday = date.weekday;

  List<String> weekdays = [
    "CN",
    "Thứ 2",
    "Thứ 3",
    "Thứ 4",
    "Thứ 5",
    "Thứ 6",
    "Thứ 7"
  ];

  return weekdays[weekday % 7];
}
