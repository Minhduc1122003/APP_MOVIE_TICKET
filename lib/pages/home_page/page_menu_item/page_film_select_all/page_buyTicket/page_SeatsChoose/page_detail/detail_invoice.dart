import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/page_SeatsChoose/page_detail/detail_invoice2.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../../auth/api_service.dart';

class DetailInvoice extends StatefulWidget {
  final int showTimeID;
  final int quantity;
  final double sumPrice;
  final String idTicket;
  final double tongTienConLai;
  final List<Map<String, dynamic>> seatCodes;
  final double ticketPrice;
  final int quantityCombo;
  final double totalComboPrice;
  final List<Map<String, dynamic>> titleCombo;
  final int cinemaRoomID;
  final String showtimeDate;
  final String startTime;
  final String endTime;
  final MovieDetails? movieDetails;

  const DetailInvoice({
    Key? key,
    required this.quantity,
    required this.sumPrice,
    required this.showTimeID,
    required this.seatCodes,
    required this.idTicket,
    required this.tongTienConLai,
    required this.ticketPrice,
    required this.quantityCombo,
    required this.totalComboPrice,
    required this.titleCombo,
    required this.cinemaRoomID,
    required this.showtimeDate,
    required this.startTime,
    required this.endTime,
    required this.movieDetails,
  }) : super(key: key);

  @override
  DetailInvoiceState createState() => DetailInvoiceState();
}

class DetailInvoiceState extends State<DetailInvoice>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late ApiService _apiService;
  String? _payUrl;
  String? status;
  bool _isScrolled = false;
  late int _remainingTime; // Thời gian còn lại tính bằng giây
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _remainingTime = 15 * 60;

    WidgetsBinding.instance.addObserver(this); // Thêm observer
    _startTimer();
    _createMomoPayment();
    _startPeriodicCheck();
  }

  String _formatRemainingTime() {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer?.cancel(); // Hủy timer trước khi khởi tạo mới
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
        _deleteOneBuyTicketById();
      }
    });
  }

  void _startPeriodicCheck() {
    _timer?.cancel();
    _timer =
        Timer.periodic(const Duration(seconds: 5), (_) => _checkStatusAuto());
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

  Future<void> _createMomoPayment() async {
    try {
      final payUrl = await _apiService.createMomoPayment(
        widget.tongTienConLai,
        widget.idTicket,
        'Thanh toán hóa đơn ${UserManager.instance.user?.fullName}',
      );

      setState(() => _payUrl = payUrl);
      await _launchInWebView(Uri.parse(payUrl));
    } catch (e) {
      print("Lỗi khi gọi API thanh toán MoMo: $e");
    }
  }

  Future<void> _deleteOneBuyTicketById() async {
    try {
      EasyLoading.show(status: 'Đang xử lý...'); // Hiển thị loading
      print(widget.idTicket);

      // Gửi yêu cầu xóa
      final String statusMessage =
          await _apiService.deleteOneBuyTicketById(widget.idTicket);
      print("Status message: $statusMessage");

      if (statusMessage == "Successfully") {
        // Nếu trả về Successfully, gọi API cập nhật trạng thái

        EasyLoading.dismiss();
        EasyLoading.showError('Thanh toán Đã bị hủy!',
            duration: const Duration(seconds: 5));

        setState(() {
          status = 'Đã bị hủy!';
        });
        Navigator.pushAndRemoveUntil(
          context,
          SlideFromLeftPageRoute(page: HomePage()),
          (Route<dynamic> route) => false, // Xóa tất cả các route trước đó
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

  Future<void> _checkStatus() async {
    try {
      EasyLoading.show();
      print(widget.idTicket);
      final statusMessage =
          await _apiService.checkTransactionStatus(widget.idTicket);
      print(statusMessage);

      if (statusMessage ==
          "Transaction is initiated, waiting for user confirmation.") {
        EasyLoading.dismiss();

        EasyLoading.showInfo('Đang đợi thanh toán...',
            duration: const Duration(seconds: 2));
        setState(() {
          status = 'Đang thanh toán...';
        });
      } else if (statusMessage == "Successful.") {
        String result =
            await _apiService.updateStatusBuyTicketInfo(widget.idTicket);
        EasyLoading.dismiss();
        print('result: $result');
        EasyLoading.showSuccess('Thanh toán thành công!',
            duration: const Duration(seconds: 2));
        setState(() {
          status = 'Thành công!';
        });

        Navigator.push(
          context,
          SlideFromRightPageRoute(
              page: DetailInvoice2(
            quantity: widget.quantity,
            sumPrice: widget.sumPrice,
            showTimeID: widget.showTimeID,
            seatCodes: widget.seatCodes,
            idTicket: widget.idTicket,
            tongTienConLai: widget.tongTienConLai,
            quantityCombo: widget.quantityCombo,
            ticketPrice: widget.ticketPrice,
            titleCombo: widget.titleCombo,
            totalComboPrice: widget.totalComboPrice,
            showtimeDate: widget.showtimeDate,
            cinemaRoomID: widget.cinemaRoomID,
            startTime: widget.startTime,
            endTime: widget.endTime,
            movieDetails: widget.movieDetails,
          )),
        );
      } else {
        EasyLoading.dismiss();
      }
    } catch (e) {}
  }

  Future<void> _checkStatusAuto() async {
    try {
      if (status == 'Thành công!') {
        // Nếu trạng thái đã thành công, dừng việc kiểm tra tiếp
        _timer?.cancel(); // Hủy timer để không gọi lại mỗi 5 giây nữa

        // Đóng WebView nếu đang mở
        try {
          closeInAppWebView();
        } catch (e) {
          print("Lỗi khi đóng WebView: $e");
        }

        return; // Dừng hàm
      }

      print(widget.idTicket);
      final statusMessage =
          await _apiService.checkTransactionStatus(widget.idTicket);

      if (statusMessage ==
          "Transaction is initiated, waiting for user confirmation.") {
        setState(() {
          status = 'Đang thanh toán...';
        });
      } else if (statusMessage == "Successful.") {
        String result =
            await _apiService.updateStatusBuyTicketInfo(widget.idTicket);
        setState(() {
          status = 'Thành công!';
        });

        // Đóng WebView sau khi cập nhật trạng thái thành công
        try {
          closeInAppWebView();
        } catch (e) {
          print("Lỗi khi đóng WebView: $e");
        }

        Navigator.push(
          context,
          SlideFromRightPageRoute(
              page: DetailInvoice2(
            quantity: widget.quantity,
            sumPrice: widget.sumPrice,
            showTimeID: widget.showTimeID,
            seatCodes: widget.seatCodes,
            idTicket: widget.idTicket,
            tongTienConLai: widget.tongTienConLai,
            quantityCombo: widget.quantityCombo,
            ticketPrice: widget.ticketPrice,
            titleCombo: widget.titleCombo,
            totalComboPrice: widget.totalComboPrice,
            showtimeDate: widget.showtimeDate,
            cinemaRoomID: widget.cinemaRoomID,
            startTime: widget.startTime,
            endTime: widget.endTime,
            movieDetails: widget.movieDetails,
          )),
        );
      }
    } catch (e) {
      print("Lỗi khi kiểm tra trạng thái giao dịch: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance
        .removeObserver(this); // Gỡ observer khi widget bị huỷ
    _timer?.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Ứng dụng quay lại foreground
      _checkPaymentStatus();
    }
  }

  Future<void> _checkPaymentStatus() async {
    print('Người dùng đã quay lại app');
    _checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
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
          'Thanh toán',
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
                            color: const Color(
                                0xffd7e3fa), // Màu nền của thẻ ticket
                            borderRadius: BorderRadius.circular(
                                15), // Làm tròn góc với bán kính 15
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
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
                                ],
                              ),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'Vui lòng quét mã để thực hiện thanh toán',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
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
                                          Text('Rạp ${widget.cinemaRoomID}'),
                                          Text(
                                            ' - ${widget.showtimeDate}',
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
                                            '${widget.startTime}',
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
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        10), // Bo góc cho QR code
                                  ),
                                  child: _payUrl == null
                                      ? const Center(
                                          child:
                                              CircularProgressIndicator()) // Hiển thị loading nếu URL chưa sẵn sàng
                                      : QrImageView(
                                          data: _payUrl.toString(),
                                          version: QrVersions.auto,
                                          size: 200.0,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'Thạng thái: ',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  Text(
                                    '$status',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
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
                              const SizedBox(height: 20),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Căn theo chiều dọc ở vị trí đầu (top)
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Align(
                                          alignment: Alignment
                                              .topCenter, // Đặt text ở góc trên bên trái
                                          child: Text('  Ghế: '),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Align(
                                          alignment: Alignment
                                              .topLeft, // Đặt text ở góc trên bên trái
                                          child: Text(
                                            ' ${widget.seatCodes.map((seat) => seat['code']).join(', ')}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
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
                                            '${formatPrice(widget.ticketPrice)}đ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign
                                                .left, // Căn văn bản sang trái
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey, // Màu của đường kẻ
                                    thickness: 1, // Độ dày của đường kẻ
                                    indent: 10, // Khoảng cách từ trái
                                    endIndent: 10, // Khoảng cách từ phải
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Căn theo chiều dọc ở vị trí đầu (top)
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Align(
                                          alignment: Alignment
                                              .topCenter, // Đặt text ở góc trên bên trái
                                          child: Text(
                                              '   ${widget.quantityCombo}  - '),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Align(
                                          alignment: Alignment
                                              .topLeft, // Đặt text ở góc trên bên trái
                                          child: AutoSizeText(
                                            '${widget.titleCombo.isEmpty ? 'Không có combo' : widget.titleCombo.map((combo) => combo['title']).join(', ')}', // Kiểm tra nếu không có combo
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                                            '${formatPrice(widget.totalComboPrice)}đ', // Giá combo = 0
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
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
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Mã vé: ${widget.idTicket}'),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Căn theo chiều dọc ở vị trí đầu (top)
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment
                                          .topLeft, // Đặt text ở góc trên bên trái
                                      child: Text('Tổng tiền: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment
                                          .topRight, // Đặt text ở góc trên bên trái
                                      child: Text(
                                        '${formatPrice(widget.tongTienConLai)}đ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            color: Colors
                                                .red), // Căn văn bản sang trái
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.deepOrangeAccent, // Màu của nút
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          8), // Bo tròn góc
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                  ),
                                  onPressed: () async {
                                    await _launchInWebView(Uri.parse(_payUrl!));
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
                              SizedBox(
                                height: 10,
                              ),
                              const Divider(
                                color: Colors.grey, // Màu của đường kẻ
                                thickness: 1, // Độ dày của đường kẻ
                                indent: 10, // Khoảng cách từ trái
                                endIndent: 10, // Khoảng cách từ phải
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex:
                                          1, // Hủy chiếm 1 phần trong tổng 3 phần
                                      child: MyButton(
                                        fontsize: 18,
                                        paddingText: 8,
                                        text: 'Hủy',
                                        isBold: true,
                                        color: Colors.red,
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Hủy thanh toán!'),
                                                content: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            'Bạn có chắc muốn',
                                                        style:
                                                            DefaultTextStyle.of(
                                                                    context)
                                                                .style,
                                                      ),
                                                      const TextSpan(
                                                        text:
                                                            ' hủy thanh toán?',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: mainColor,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            ' Nếu bấm hủy ghế của bạn sẽ được trả về trạng thái chưa đặt!',
                                                        style:
                                                            DefaultTextStyle.of(
                                                                    context)
                                                                .style,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text(
                                                        'Tiếp tục thanh toán',
                                                        style: TextStyle(
                                                            color: mainColor)),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      _deleteOneBuyTicketById();
                                                    },
                                                    child: const Text(
                                                      'Xác nhận hủy',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      flex:
                                          2, // Thanh toán chiếm 2 phần trong tổng 3 phần
                                      child: MyButton(
                                          fontsize: 18,
                                          paddingText: 10,
                                          text: 'Kiểm tra thanh toán',
                                          onTap: () {
                                            _checkStatus();
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
