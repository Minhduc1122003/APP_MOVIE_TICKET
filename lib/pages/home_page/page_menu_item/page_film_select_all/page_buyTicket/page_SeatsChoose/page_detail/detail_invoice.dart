import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../../auth/api_service.dart';

class DetailInvoice extends StatefulWidget {
  final int movieID;
  final int showTimeID;
  final List<int> seatCodes;
  final int quantity;
  final double sumPrice;

  const DetailInvoice({
    Key? key,
    required this.movieID,
    required this.quantity,
    required this.sumPrice,
    required this.showTimeID,
    required this.seatCodes,
  }) : super(key: key);

  @override
  DetailInvoiceState createState() => DetailInvoiceState();
}

class DetailInvoiceState extends State<DetailInvoice>
    with AutomaticKeepAliveClientMixin {
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    // _insertBuyTicket();
    _createMomoPayment();
  }

  Future<void> _insertBuyTicket() async {
    try {
      // Cộng các chuỗi từ userId, quantity, showTimeID
      String combinedString = UserManager.instance.user!.userId.toString() +
          widget.quantity.toString() +
          widget.showTimeID.toString();

      String firstSeatCode =
          widget.seatCodes.isNotEmpty ? widget.seatCodes[0].toString() : '';

      combinedString += firstSeatCode;

      int finalResult;
      try {
        finalResult = int.parse(combinedString);
        print("finalResult: $finalResult");
      } catch (e) {
        print("Error: $e");
        finalResult = 0; // Hoặc một giá trị mặc định khác
      }

// Gọi hàm insertBuyTicket với finalResult
      final response = await _apiService.insertBuyTicket(
        finalResult, // Sử dụng finalResult đã chuyển đổi
        '${UserManager.instance.user?.userId}',
        widget.movieID,
        widget.quantity,
        widget.sumPrice.toDouble(),
        widget.showTimeID,
        widget.seatCodes,
      );

      // Xử lý phản hồi
      // Có thể hiển thị thông báo hoặc thực hiện hành động nào đó với dữ liệu nhận được
      print("Thành công: $response");
    } catch (e) {
      print("Lỗi khi gọi API: $e");
    }
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _createMomoPayment() async {
    try {
      String formattedDate = DateFormat('MMddHHmmss').format(DateTime.now());
      print(
        "${UserManager.instance.user?.userId}${widget.movieID}${widget.showTimeID}$formattedDate",
      );

      // Gọi hàm tạo thanh toán MoMo từ ApiService
      final payUrl = await _apiService.createMomoPayment(
        200000, // Truyền số tiền cần thanh toán

        "${UserManager.instance.user?.userId}${widget.movieID}${widget.showTimeID}$formattedDate",
        'Thanh toán vé xem phim ${UserManager.instance.user?.fullName}', // Thông tin đơn hàng
      );

      // Mở URL thanh toán MoMo trong trình duyệt
      await _launchUrl(Uri.parse(payUrl));
    } catch (e) {
      print("Lỗi khi gọi API thanh toán MoMo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0XFF6F3CD7),
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
          'Hóa đơn vé',
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
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.3, // Chiều rộng bằng 50% màn hình
                                    // Chiều cao bằng 30% màn hình
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          10), // Làm tròn góc cho ảnh
                                      child: Image.asset(
                                        'assets/images/baothuditimchu.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  // Sử dụng Container để điều chỉnh chiều cao
                                  Container(
                                    // Giới hạn chiều cao để căn chỉnh phần tử lên trên
                                    constraints: const BoxConstraints(
                                        maxHeight: 130), // Giới hạn chiều cao
                                    alignment: Alignment
                                        .topLeft, // Căn chỉnh ở trên cùng bên trái
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Đất rừng phương nam',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Text('2D PHỤ ĐỀ',
                                            style: TextStyle(fontSize: 16)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3,
                                              horizontal:
                                                  5), // Tạo khoảng trống xung quanh chữ
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .deepOrange, // Nền màu vàng
                                            borderRadius: BorderRadius.circular(
                                                10), // Bo góc tròn
                                          ),
                                          child: const Text(
                                            'T13', // Nội dung chữ
                                            style: TextStyle(
                                              color:
                                                  Colors.white, // Màu chữ trắng
                                              fontSize:
                                                  14, // Kích thước chữ lớn hơn
                                              fontWeight: FontWeight
                                                  .bold, // Tùy chọn: Chữ đậm hơn
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'PANTHERs Tô Ký',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(' - '),
                                      Text(
                                        'Rạp 3',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
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
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(
                                        10), // QR code rounded corners
                                  ),
                                  child: const Center(
                                      child: Icon(Icons.qr_code_scanner)),
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
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Mã vé: 279942'),
                                ],
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
                              )
                            ],
                          ),
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
