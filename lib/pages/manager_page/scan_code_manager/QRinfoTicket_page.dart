import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/models/BuyTicket_model.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/ticket_screen/rate_page/rate_screen.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../../../auth/api_service.dart';

class QrinfoticketPage extends StatefulWidget {
  final String buyTicketID;

  const QrinfoticketPage({Key? key, required this.buyTicketID})
      : super(key: key);

  @override
  QrinfoticketPageState createState() => QrinfoticketPageState();
}

class QrinfoticketPageState extends State<QrinfoticketPage>
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
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white, // Màu nền của thẻ ticket
                            borderRadius: BorderRadius.circular(
                                15), // Làm tròn góc với bán kính 15
                          ),
                          child: FutureBuilder<BuyTicket>(
                              future: _futureBuyTickets,
                              builder: (BuildContext context,
                                  AsyncSnapshot<BuyTicket> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError ||
                                    snapshot.data == null) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    Navigator.pop(context,
                                        'Không tồn tại'); // Truyền callback
                                  });
                                } else if (snapshot.hasData) {
                                  // Đã có dữ liệu
                                  BuyTicket ticket = snapshot.data!;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${ticket.movieName}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 23,
                                                    color: Colors.deepOrange),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                'Rạp ${ticket.cinemaRoomId}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                            borderRadius: BorderRadius.circular(
                                                10), // Bo góc cho QR code
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .deepOrangeAccent),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start, // Căn theo chiều dọc ở vị trí đầu (top)
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Align(
                                                  alignment: Alignment
                                                      .topCenter, // Đặt text ở góc trên bên trái
                                                  child: Text('Ghế: '),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Align(
                                                  alignment: Alignment
                                                      .topLeft, // Đặt text ở góc trên bên trái
                                                  child: Text(
                                                    ' ${ticket.seatNumbers}',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign
                                                        .left, // Căn văn bản sang trái
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                        color: Colors.grey, // Màu của đường kẻ
                                        thickness: 1, // Độ dày của đường kẻ
                                        indent: 10, // Khoảng cách từ trái
                                        endIndent: 10, // Khoảng cách từ phải
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 5, 20, 5),
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
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 5, 20, 5),
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
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 5, 20, 5),
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
                                                            : ticket.status ==
                                                                    'Đã hủy'
                                                                ? Colors
                                                                    .redAccent
                                                                : Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                    color: ticket.isCheckIn ==
                                                            false
                                                        ? Colors.green
                                                        : Colors.redAccent,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  minFontSize: 8,
                                                  maxFontSize: 14,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors
                                                .deepOrangeAccent, // Màu của nút
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8), // Bo tròn góc
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 20),
                                          ),
                                          onPressed: () async {
                                            if (ticket.isCheckIn) {
                                              EasyLoading.showError(
                                                  'Vé đã dược sử dụng');
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                Navigator.pop(context,
                                                    'Vé đã dược sử dụng'); // Truyền callback
                                              });
                                              return; // Thêm return để dừng xử lý
                                            }

                                            if (ticket.status !=
                                                'Ðã thanh toán') {
                                              EasyLoading.showError(
                                                  'Vé chưa thanh toán hoặc đã hủy!');
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                Navigator.pop(context,
                                                    'Vé chưa thanh toán hoặc đã hủy!'); // Truyền callback
                                              });
                                              return; // Thêm return để dừng xử lý
                                            }

                                            // Xử lý tiếp khi vé hợp lệ
                                            String buyTicketId =
                                                widget.buyTicketID;
                                            try {
                                              EasyLoading
                                                  .show(); // Hiển thị loading

                                              // Gọi API
                                              String result = await _apiService
                                                  .checkInBuyTicket(
                                                      buyTicketId);

                                              // Kiểm tra nếu server trả về "successfully"
                                              if (result
                                                  .toLowerCase()
                                                  .contains('successfully')) {
                                                EasyLoading
                                                    .dismiss(); // Ẩn loading
                                                EasyLoading.showSuccess(
                                                    'Check-in thành công!');
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  Navigator.pop(context,
                                                      'Check-in thành công!'); // Truyền callback
                                                });
                                              } else {
                                                EasyLoading
                                                    .dismiss(); // Ẩn loading
                                                EasyLoading.showError(
                                                    'Vé chưa thanh toán hoặc đã hủy!');
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  Navigator.pop(context,
                                                      'Vé chưa thanh toán hoặc đã hủy!'); // Truyền callback
                                                });
                                              }
                                            } catch (error) {
                                              EasyLoading
                                                  .dismiss(); // Ẩn loading
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Lỗi khi check-in: $error')),
                                              );
                                            }
                                          },
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center, // Căn giữa theo chiều ngang
                                            children: [
                                              Expanded(
                                                child: Align(
                                                  alignment: Alignment
                                                      .center, // Căn giữa văn bản
                                                  child: Text(
                                                    'Check in',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.white,
                                                size: 15,
                                              ), // Mũi tên bên phải
                                            ],
                                          )),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Nút Đóng nằm cố định ở dưới cùng của màn hình hoặc cuộn
            ],
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
  // Chuyển chuỗi đầu vào thành đối tượng DateTime
  DateTime dateTime = DateTime.parse(inputDate);
  // Định dạng ngày giờ thành 'HH:mm - dd/MM/yyyy'
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
