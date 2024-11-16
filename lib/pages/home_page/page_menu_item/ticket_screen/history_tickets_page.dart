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

class HistoryTicketsPage extends StatefulWidget {
  final Function? onRefresh;
  HistoryTicketsPage({this.onRefresh, Key? key}) : super(key: key);

  @override
  _HistoryTicketsPageState createState() => _HistoryTicketsPageState();
}

class _HistoryTicketsPageState extends State<HistoryTicketsPage> {
  late ApiService _apiService;
  List<BuyTicket> listBuyTicket = [];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    if (UserManager.instance.user != null) {
      _fetchBuyticket();
    }
  }

  Future<void> _fetchBuyticket() async {
    print('đã gọi load data');
    try {
      List<BuyTicket> buyticket = await _apiService
          .findAllBuyTicketByUserId(UserManager.instance.user!.userId);
      setState(() {
        listBuyTicket = buyticket;
      });
      // Gọi callback onRefresh nếu có
      widget.onRefresh?.call();
    } catch (e) {
      print('Error fetching favorite films: $e');
    }
  }

  void refreshBuyticket() {
    listBuyTicket = [];

    if (UserManager.instance.user != null) {
      _fetchBuyticket();
    }
  }

  bool isLoading = false; // Biến trạng thái loading

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined,
                color: Colors.white, size: 16),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Lịch sử đặt vé',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Stack(
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
            if (UserManager.instance.user == null)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Bo góc card
                  side: BorderSide(
                      color: Colors.grey[300]!, width: 1), // Viền xám
                ),
                elevation: 5, // Độ đổ bóng nhẹ
                margin: const EdgeInsets.symmetric(
                    vertical: 100,
                    horizontal: 40), // Khoảng cách xung quanh card
                child: Padding(
                  padding: const EdgeInsets.all(20.0), // Padding trong card
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
                          'Vui lòng đăng nhập để xem phim yêu thích',
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
                                )),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (UserManager.instance.user != null)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 5),
                      isLoading // Kiểm tra trạng thái loading
                          ? Center(
                              child:
                                  CircularProgressIndicator(), // Vòng xoay loading
                            )
                          : listBuyTicket.isEmpty
                              ? Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Bo góc card
                                    side: BorderSide(
                                        color: Colors.grey[300]!,
                                        width: 1), // Viền xám
                                  ),
                                  elevation: 5, // Độ đổ bóng nhẹ
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 50,
                                      horizontal:
                                          40), // Khoảng cách xung quanh card
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        20.0), // Padding trong card
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                                Colors.black, BlendMode.srcIn),
                                            child: Image.asset(
                                              'assets/images/logoText.png',
                                              width: 280,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Chưa có lịch sử',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Có vẻ bạn chưa đặt vé nào!',
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
                                              text: 'Đặt vé ngay',
                                              isBold: true,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  SlideFromRightPageRoute(
                                                      page:
                                                          FilmHaydangchieuScreen()),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Flexible(
                                  child: ListView.builder(
                                    itemCount: listBuyTicket.length,
                                    itemBuilder: (context, index) {
                                      final ticket = listBuyTicket[index];
                                      return GestureDetector(
                                        onTap: () {
                                          // In ra posterUrl khi nhấn vào Card
                                          print(ticket.buyTicketId);
                                          Navigator.push(
                                            context,
                                            SlideFromRightPageRoute(
                                              page: InfoticketPage(
                                                  buyTicketID:
                                                      ticket.buyTicketId),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          color: Colors.white,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          elevation: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: CachedNetworkImage(
                                                    imageUrl: ticket.posterUrl,
                                                    height: 80,
                                                    width: 60,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.error),
                                                    // Hiển thị icon lỗi nếu tải ảnh không thành công
                                                    fadeInDuration: const Duration(
                                                        seconds:
                                                            1), // Thời gian hiệu ứng fade-in
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      AutoSizeText(
                                                        ticket.movieName,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        minFontSize:
                                                            14, // Kích thước chữ tối thiểu
                                                        maxFontSize:
                                                            16, // Kích thước chữ tối đa
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                              Icons.access_time,
                                                              size: 14),
                                                          const SizedBox(
                                                              width: 5),
                                                          AutoSizeText(
                                                            '${ticket.startTime} - ${getDayOfWeek(ticket.showtimeDate)}, ${ticket.showtimeDate}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            minFontSize: 8,
                                                            maxFontSize: 12,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .info_outline_rounded,
                                                              size: 14),
                                                          const SizedBox(
                                                              width: 5),
                                                          AutoSizeText(
                                                            '${ticket.status}',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: ticket
                                                                          .status ==
                                                                      'Chưa thanh toán'
                                                                  ? Colors
                                                                      .orange
                                                                  : ticket.status ==
                                                                          'Ðã thanh toán'
                                                                      ? Colors
                                                                          .green
                                                                      : ticket.status ==
                                                                              'Đã hủy'
                                                                          ? Colors
                                                                              .redAccent
                                                                          : Colors
                                                                              .grey, // Màu mặc định nếu không khớp với các giá trị trên
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            minFontSize: 8,
                                                            maxFontSize: 12,
                                                          ),
                                                          Text(
                                                            ' - ',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                          AutoSizeText(
                                                            '${ticket.isCheckIn == false ? 'Chưa sử dụng' : 'Đã sử dụng'}',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: ticket
                                                                            .isCheckIn ==
                                                                        false
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .redAccent),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            minFontSize: 8,
                                                            maxFontSize: 12,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Tổng thanh toán: ',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          AutoSizeText(
                                                            '${formatPrice(ticket.totalPrice)}đ',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .deepOrangeAccent,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
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
