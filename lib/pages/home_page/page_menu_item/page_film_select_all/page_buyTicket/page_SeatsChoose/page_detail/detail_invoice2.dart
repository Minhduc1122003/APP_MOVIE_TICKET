import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../../../auth/api_service.dart';

class DetailInvoice2 extends StatefulWidget {
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

  const DetailInvoice2({
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
  DetailInvoice2State createState() => DetailInvoice2State();
}

class DetailInvoice2State extends State<DetailInvoice2>
    with AutomaticKeepAliveClientMixin {
  late ApiService _apiService;
  late String qrText = '';

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    qrText =
        '${widget.movieDetails!.title} ${widget.cinemaRoomID} ${widget.startTime}';
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
                            color: Colors.white, // Màu nền của thẻ ticket
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
                                      child: Image.network(
                                        widget.movieDetails!.posterUrl,
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
                                          maxHeight: 130), // Giới hạn chiều cao
                                      alignment: Alignment
                                          .topLeft, // Căn chỉnh ở trên cùng bên trái
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AutoSizeText(
                                            '${widget.movieDetails?.title}', // Đảm bảo xử lý null safety
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold, // Font đậm
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
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            '${(widget.movieDetails?.voiceover == true) ? 'Lồng tiếng' : ''}'
                                            '${(widget.movieDetails?.voiceover == true && widget.movieDetails?.subTitle == true) ? ' - ' : ''}'
                                            '${(widget.movieDetails?.subTitle == true) ? 'Phụ Đề' : ''}',
                                            style: TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 3,
                                                horizontal:
                                                    5), // Tạo khoảng trống xung quanh chữ
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .deepOrange, // Nền màu vàng
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10), // Bo góc tròn
                                            ),
                                            child: Text(
                                              widget.movieDetails!
                                                  .age, // Nội dung chữ
                                              style: const TextStyle(
                                                color: Colors
                                                    .white, // Màu chữ trắng
                                                fontSize:
                                                    13, // Kích thước chữ lớn hơn
                                                fontWeight: FontWeight
                                                    .bold, // Tùy chọn: Chữ đậm hơn
                                              ),
                                            ),
                                          )
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
                                        '${widget.movieDetails?.cinemaName}',
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
                                        'Rạp ${widget.cinemaRoomID}',
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
                                            '${widget.showtimeDate}',
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
                                    color: basicColor,
                                    borderRadius: BorderRadius.circular(
                                        10), // Bo góc cho QR code
                                  ),
                                  child: qrText == ''
                                      ? const Center(
                                          child:
                                              CircularProgressIndicator()) // Hiển thị loading nếu URL chưa sẵn sàng
                                      : QrImageView(
                                          data: qrText.toString(),
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
                              SizedBox(
                                height: 20,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                              Row(
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

String formatPrice(double price) {
  final formatter = NumberFormat('#,###', 'vi');
  return formatter.format(price);
}
