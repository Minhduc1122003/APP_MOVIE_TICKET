import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/models/BuyTicket_model.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/ticket_screen/rate_page/rate_screen.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../../../auth/api_service.dart';

class InfoticketPage extends StatefulWidget {
  final String buyTicketID;

  const InfoticketPage({Key? key, required this.buyTicketID}) : super(key: key);

  @override
  InfoticketPageState createState() => InfoticketPageState();
}

class InfoticketPageState extends State<InfoticketPage>
    with AutomaticKeepAliveClientMixin {
  late ApiService _apiService;
  late String qrText = '';
  late Future<BuyTicket> _futureBuyTickets;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _futureBuyTickets = _apiService.FindOneBuyTicketById(widget.buyTicketID);
    qrText = '';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: basicColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 16,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Thông tin vé',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return FutureBuilder<BuyTicket>(
            future: _futureBuyTickets,
            builder: (BuildContext context, AsyncSnapshot<BuyTicket> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                BuyTicket ticket = snapshot.data!;
                return Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        ticket.posterUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(maxHeight: 130),
                                      alignment: Alignment.topLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AutoSizeText(
                                            '${ticket.movieName}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            maxLines: 2,
                                            minFontSize: 16,
                                            maxFontSize: 18,
                                            overflow: TextOverflow.clip,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${ticket.cinemaName}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.deepOrange),
                                      ),
                                      Text(
                                        ' - ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Rạp ${ticket.cinemaRoomId}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text('Ngày: '),
                                          Text(
                                            '${getDayOfWeek(ticket.showtimeDate)}, ${ticket.showtimeDate}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text('Suất chiếu: '),
                                          Text(
                                            '${ticket.startTime}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: basicColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: QrImageView(
                                    data: ticket.buyTicketId,
                                    version: QrVersions.auto,
                                    size: 200.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Đưa mã này cho nhân viên soát vé để vào rạp',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepOrangeAccent),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Text('Ghế: '),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            ' ${ticket.seatNumbers}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Text(
                                            '${formatPrice(ticket.totalTicketPrice)}đ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                    indent: 10,
                                    endIndent: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Text('Combo:'),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: AutoSizeText(
                                            '${ticket.comboDetails}',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            minFontSize: 11,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Text(
                                            '${formatPrice(ticket.totalComboPrice)}đ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const Divider(
                                color: Colors.grey,
                                thickness: 1,
                                indent: 10,
                                endIndent: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 5, 20, 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Mã vé:'),
                                    Text(
                                      '${ticket.buyTicketId}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 5, 20, 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Ngày tạo:'),
                                    Text(
                                      '${formatDateTime(ticket.createDate)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 5, 20, 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Trạng thái:'),
                                    Row(
                                      children: [
                                        AutoSizeText(
                                          '${ticket.status}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: ticket.status ==
                                                    'Chưa thanh toán'
                                                ? Colors.orange
                                                : ticket.status ==
                                                        'Ðã thanh toán'
                                                    ? Colors.green
                                                    : ticket.status == 'Đã hủy'
                                                        ? Colors.redAccent
                                                        : Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          minFontSize: 8,
                                          maxFontSize: 14,
                                        ),
                                        Text(
                                          ' - ',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        AutoSizeText(
                                          '${ticket.isCheckIn == false ? 'Chưa sử dụng' : 'Đã sử dụng'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: ticket.isCheckIn == false
                                                ? Colors.green
                                                : Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          minFontSize: 8,
                                          maxFontSize: 14,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text('Thanh toán: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18)),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Text(
                                          '${formatPrice(ticket.totalPrice)}đ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (ticket.isCheckIn)
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrangeAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 20),
                                    ),
                                    onPressed: () async {
                                      print('object');
                                      print(ticket.movieID);
                                      Navigator.push(
                                        context,
                                        SlideFromRightPageRoute(
                                          page: RateScreen(
                                            buyTicket: ticket,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Đánh giá phim',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ],
                                    )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (ticket.isCheckIn)
                      Center(
                        child: Transform.rotate(
                          angle: -0.3, // Góc xoay -45 độ (bằng radian)
                          child: Opacity(
                            opacity: 0.5, // Đặt mức độ trong suốt (20%)
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.red, // Màu viền đỏ
                                  width: 3, // Độ dày viền
                                ),
                              ),
                              child: Text(
                                'VÉ ĐÃ SỬ DỤNG',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              } else {
                return Center(child: Text('No data available.'));
              }
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

String formatPrice(double price) {
  final formatter = NumberFormat('#,###', 'vi');
  return formatter.format(price);
}

String formatDateTime(String inputDate) {
  DateTime dateTime = DateTime.parse(inputDate);
  String formattedDate =
      "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} - "
      "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";

  return formattedDate;
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
