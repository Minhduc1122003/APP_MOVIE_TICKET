import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/models/BuyTicket_model.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
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
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (snapshot.hasData) {
                                  // Đã có dữ liệu
                                  BuyTicket ticket = snapshot.data!;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3, // Chiều rộng bằng 50% màn hình
                                            // Chiều cao bằng 30% màn hình
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(
                                                  10), // Làm tròn góc cho ảnh
                                              child: Image.network(
                                                ticket.posterUrl,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          // Sử dụng Container để điều chỉnh chiều cao
                                          Expanded(
                                            child: Container(
                                              // Giới hạn chiều cao để căn chỉnh phần tử lên trên
                                              constraints: const BoxConstraints(
                                                  maxHeight:
                                                      130), // Giới hạn chiều cao
                                              alignment: Alignment
                                                  .topLeft, // Căn chỉnh ở trên cùng bên trái
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  AutoSizeText(
                                                    '${ticket.movieName}', // Đảm bảo xử lý null safety
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .bold, // Font đậm
                                                    ),
                                                    maxLines:
                                                        2, // Giới hạn tối đa 2 dòng
                                                    minFontSize:
                                                        16, // Kích thước font nhỏ nhất
                                                    maxFontSize:
                                                        18, // Kích thước font lớn nhất
                                                    overflow: TextOverflow
                                                        .clip, // Văn bản bị cắt nếu vượt quá không gian
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
                                              Expanded(
                                                flex: 2,
                                                child: Align(
                                                  alignment: Alignment
                                                      .topRight, // Đặt text ở góc trên bên trái
                                                  child: Text(
                                                    '${formatPrice(ticket.totalTicketPrice)}đ',
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
                                          Divider(
                                            color:
                                                Colors.grey, // Màu của đường kẻ
                                            thickness: 1, // Độ dày của đường kẻ
                                            indent: 10, // Khoảng cách từ trái
                                            endIndent:
                                                10, // Khoảng cách từ phải
                                          ),
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
                                                  child: Text('Combo:'),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Align(
                                                  alignment: Alignment
                                                      .topLeft, // Đặt text ở góc trên bên trái
                                                  child: AutoSizeText(
                                                    '${ticket.comboDetails}', // Kiểm tra nếu không có combo
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    minFontSize: 11,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Align(
                                                  alignment: Alignment
                                                      .topRight, // Đặt text ở góc trên bên trái
                                                  child: Text(
                                                    '${formatPrice(ticket.totalComboPrice)}đ', // Giá combo = 0
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign
                                                        .left, // Căn văn bản sang trái
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
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
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start, // Căn theo chiều dọc ở vị trí đầu (top)
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment
                                                    .topLeft, // Đặt text ở góc trên bên trái
                                                child: Text('Thanh toán: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18)),
                                              ),
                                            ),
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment
                                                    .topRight, // Đặt text ở góc trên bên trái
                                                child: Text(
                                                  '${formatPrice(ticket.totalPrice)}đ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: Colors
                                                          .red), // Căn văn bản sang trái
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                } else {
                                  return Center(
                                      child: Text('No data available.'));
                                }
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Nút Đóng nằm cố định ở dưới cùng của màn hình hoặc cuộn
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F75FF), // Nền màu cam
                    borderRadius: BorderRadius.circular(5), // Làm tròn góc nút
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        SlideFromLeftPageRoute(page: HomePage()),
                        (Route<dynamic> route) =>
                            false, // Xóa tất cả các route trước đó
                      );
                    },
                    child: const Text(
                      'Về trang chủ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
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
