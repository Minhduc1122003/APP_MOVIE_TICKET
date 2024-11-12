import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
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
  final int movieID;
  final int showTimeID;
  final List<int> seatCodes;
  final int quantity;
  final double sumPrice;
  final String idTicket;
  final double tongTienConLai;

  const DetailInvoice({
    Key? key,
    required this.movieID,
    required this.quantity,
    required this.sumPrice,
    required this.showTimeID,
    required this.seatCodes,
    required this.idTicket,
    required this.tongTienConLai,
  }) : super(key: key);

  @override
  DetailInvoiceState createState() => DetailInvoiceState();
}

class DetailInvoiceState extends State<DetailInvoice>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late ApiService _apiService;
  String? _payUrl;
  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    // _insertBuyTicket();
    _createMomoPayment();
    WidgetsBinding.instance.addObserver(this); // Thêm observer
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _createMomoPayment() async {
    try {
      String formattedDate = DateFormat('MMddHHmmss').format(DateTime.now());

      // Gọi API để tạo URL thanh toán
      final payUrl = await _apiService.createMomoPayment(
        widget.tongTienConLai,
        widget.idTicket,
        'Thanh toán vé xem phim ${UserManager.instance.user?.fullName}', // Thông tin đơn hàng
      );

      // Lưu URL thanh toán vào biến và cập nhật giao diện
      setState(() {
        _payUrl = payUrl;
      });
      await _launchUrl(Uri.parse(payUrl));
    } catch (e) {
      print("Lỗi khi gọi API thanh toán MoMo: $e");
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
      } else if (statusMessage == "Successful.") {
        EasyLoading.dismiss();

        EasyLoading.showSuccess('Thanh toán thành công!',
            duration: const Duration(seconds: 2));
        Navigator.push(
          context,
          SlideFromRightPageRoute(
              page: DetailInvoice2(
            movieID: widget.movieID,
            quantity: widget.quantity,
            sumPrice: widget.sumPrice,
            showTimeID: widget.showTimeID,
            seatCodes: widget.seatCodes,
          )),
        );
      } else {
        EasyLoading.dismiss();

        EasyLoading.showError('Lỗi: $statusMessage',
            duration: const Duration(seconds: 2));
      }
    } catch (e) {
      print("Lỗi khi kiểm tra trạng thái giao dịch: $e");
      EasyLoading.showError('Lỗi khi kiểm tra trạng thái giao dịch',
          duration: const Duration(seconds: 3));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance
        .removeObserver(this); // Gỡ observer khi widget bị huỷ
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
                                          Text('Thứ 6, '),
                                          Text(
                                            '30/08/2024',
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
                                            '22:00',
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
                              const SizedBox(height: 20),
                              const Column(
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
                                          child: Text('Ghế: '),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Align(
                                          alignment: Alignment
                                              .topLeft, // Đặt text ở góc trên bên trái
                                          child: Text(
                                            'G5, G4 ',
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
                                            '110,000đ',
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
                                          child: Text('1x '),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Align(
                                          alignment: Alignment
                                              .topLeft, // Đặt text ở góc trên bên trái
                                          child: Text(
                                            'iCombo 1 Big STD',
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
                                            '69,000đ',
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
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Căn theo chiều dọc ở vị trí đầu (top)
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment
                                          .topLeft, // Đặt text ở góc trên bên trái
                                      child: Text('Thanh toán: ',
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
                                        '179,000đ',
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
                                height: 20,
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
                                    await _launchUrl(Uri.parse(_payUrl!));
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
                              MyButton(
                                  fontsize: 18,
                                  paddingText: 14,
                                  text: 'Kiểm tra thanh toán',
                                  onTap: () {
                                    _checkStatus();
                                  }),
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
