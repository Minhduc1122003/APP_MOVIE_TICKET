import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/models/BuyTicket_model.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/ticket_screen/rate_page/rate_screen.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../../auth/api_service.dart';

class InfoticketPage extends StatefulWidget {
  final String buyTicketID;
  final int? thanhToan;

  const InfoticketPage(
      {Key? key, required this.buyTicketID, this.thanhToan = 0})
      : super(key: key);

  @override
  InfoticketPageState createState() => InfoticketPageState();
}

class InfoticketPageState extends State<InfoticketPage>
    with AutomaticKeepAliveClientMixin {
  late ApiService _apiService;
  late String qrText = '';
  late Future<BuyTicket> _futureBuyTickets;
  String? _payUrl;
  late int _remainingTime; // Thời gian còn lại tính bằng giây
  bool _isScrolled = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _futureBuyTickets = _apiService.FindOneBuyTicketById(widget.buyTicketID);
    qrText = '';
    _remainingTime = 0; // Khởi tạo giá trị mặc định
    _updateRemainingTime(); // Cập nhật thời gian còn lại
    if (widget.thanhToan == 1) {
      _startTimer();
    }
  }

  Future<void> _updateRemainingTime() async {
    try {
      BuyTicket buyTicket = await _futureBuyTickets;

      // Parse the server timestamp
      DateTime createDate = DateTime.parse(buyTicket.createDate);

      // Get current time in UTC
      DateTime currentTime = DateTime.now().toUtc();

      // Calculate elapsed time
      Duration elapsedTime = currentTime.difference(createDate);

      // Assuming the ticket has a standard validity period (e.g., 30 minutes = 1800 seconds)
      int totalValiditySeconds = 1800;
      int elapsedSeconds = elapsedTime.inSeconds;

      // Calculate remaining time
      int remainingTime = totalValiditySeconds - elapsedSeconds;

      // Ensure remaining time is not negative
      remainingTime = remainingTime < 0 ? 0 : remainingTime;

      setState(() {
        _remainingTime = remainingTime;
      });

      print('Thời gian còn lại: $_remainingTime giây');
    } catch (e) {
      print('Lỗi khi tính thời gian còn lại: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cập nhật thời gian còn lại khi dữ liệu BuyTicket có sẵn
    _updateRemainingTime();
  }

  Future<void> _launchInWebView(Uri url) async {
    try {
      if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Lỗi khi mở WebView: $e');
    }
  }

  void _startTimer() {
    print("Starting timer. Initial remaining time: $_remainingTime");
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
          print("Updated remaining time: $_remainingTime");
        });
      } else {
        print("Timer completed. Cancelling and deleting ticket.");
        timer.cancel();
        _deleteOneBuyTicketById(widget.buyTicketID);
      }
    });
  }

  String _formatRemainingTime() {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteOneBuyTicketById(String idTicket) async {
    try {
      EasyLoading.show(status: 'Đang xử lý...'); // Hiển thị loading
      print(idTicket);

      // Gửi yêu cầu xóa
      final String statusMessage =
          await _apiService.deleteOneBuyTicketById(idTicket);
      print("Status message: $statusMessage");

      if (statusMessage == "Successfully") {
        // Nếu trả về Successfully, gọi API cập nhật trạng thái

        EasyLoading.dismiss();

        // Hiển thị dialog xác nhận
        showDialog(
          context: context,
          barrierDismissible:
              false, // Ngăn không cho đóng dialog bằng cách nhấn ra ngoài
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Thông báo"),
              content: const Text("Thanh toán đã bị hủy!"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.pop(context, true);
                  },
                  child: const Text("Xác nhận"),
                ),
              ],
            );
          },
        );
      } else {
        // Xử lý trường hợp không thành công
        EasyLoading.dismiss();
        EasyLoading.showError('Hủy thất bại! Vui lòng thử lại.',
            duration: const Duration(seconds: 2));
      }
    } catch (e) {
      // Xử lý lỗi
      EasyLoading.dismiss();
      EasyLoading.showError('Đã xảy ra lỗi: $e',
          duration: const Duration(seconds: 2));
      print("Lỗi khi kiểm tra trạng thái giao dịch: $e");
    }
  }

  Future<void> _createMomoPayment(
      double tongTienConLai, String idTicket) async {
    try {
      final payUrl = await _apiService.createMomoPayment(
        tongTienConLai,
        idTicket,
        'Thanh toán hóa đơn ${UserManager.instance.user?.fullName}',
      );

      setState(() => _payUrl = payUrl);
      await _launchInWebView(Uri.parse(payUrl));
    } catch (e) {
      print("Lỗi khi gọi API thanh toán MoMo: $e");
    }
  }

  @override
  void dispose() {
    // Hủy timer khi widget bị hủy
    _timer?.cancel();
    super.dispose();
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
                                child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 300),
                                  opacity: _isScrolled ? 0 : 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: mainColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Thời gian còn lại:',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 8),
                                          child: Text(
                                            _formatRemainingTime(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1,
                                thickness: 0,
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
                                        child: Text('Tổng thanh toán: ',
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
                              if (ticket.status == 'Chưa thanh toán')
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .deepOrangeAccent, // Màu của nút
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Bo tròn góc
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 20),
                                    ),
                                    onPressed: () async {
                                      _createMomoPayment(ticket.totalPrice,
                                          ticket.buyTicketId);
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
                                              'Tiếp tục thanh toán',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
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
