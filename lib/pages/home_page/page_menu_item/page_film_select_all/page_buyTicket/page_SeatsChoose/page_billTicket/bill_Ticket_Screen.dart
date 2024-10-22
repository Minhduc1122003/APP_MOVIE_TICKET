import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/Chair_modal.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:intl/intl.dart';

class BillTicketScreen extends StatefulWidget {
  final int movieID;
  final int cinemaRoomID;
  final int showTimeID;
  final String showtimeDate;
  final String startTime;
  final String endTime;

  const BillTicketScreen({
    Key? key,
    required this.movieID,
    required this.cinemaRoomID,
    required this.showTimeID,
    required this.showtimeDate,
    required this.startTime,
    required this.endTime,
  }) : super(key: key);

  @override
  _BillTicketScreenState createState() => _BillTicketScreenState();
}

class _BillTicketScreenState extends State<BillTicketScreen>
    with AutomaticKeepAliveClientMixin {
  late ApiService _apiService;
  late List<ChairModel> _chairs = [];
  MovieDetails? _movieDetails; // New variable for movie details
  late int selectedCount = 0; // This will track the number of selected seats
  List<Map<String, dynamic>> selectedChairsInfo =
      []; // List to store selected chair info
  List<int> seatIDList = [];
  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadChairs();
    _loadMovieDetails();
  }

  Future<void> _loadChairs() async {
    try {
      _chairs = await _apiService.getChairList(
        widget.cinemaRoomID,
        widget.showTimeID,
      );
      if (_chairs.isNotEmpty) {
        print('Đã tìm thấy ghế!');
        setState(() {});
      } else {
        print('Không tìm thấy ghế nào.');
      }
    } catch (e) {
      print('Lỗi khi tải ghế: $e');
    }
  }

  Future<void> _loadMovieDetails() async {
    try {
      _movieDetails = await _apiService.findByViewMovieID(
          widget.movieID, UserManager.instance.user?.userId ?? 0);
      if (_movieDetails != null) {
        print('Đã tìm thấy chi tiết phim!');
        setState(() {}); // Ensure the UI updates when movie details are loaded
      } else {
        print('Không tìm thấy chi tiết phim.');
      }
    } catch (e) {
      print('Lỗi khi tải chi tiết phim: $e');
    }
  }

  String formatPrice(double price) {
    final formatter = NumberFormat('#,###');
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      top: false,
      child: Scaffold(
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
        backgroundColor: Colors.white,
        body: _movieDetails == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  mainColor, // Đặt màu nền theo mainColor của bạn
                              borderRadius: BorderRadius.circular(8), // Bo góc
                            ),
                            padding: const EdgeInsets.all(
                                2), // Thêm padding để tạo khoảng cách giữa border và nội dung
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Thời gian còn lại',
                                  style: TextStyle(
                                    color: Colors
                                        .white, // Đổi màu chữ thành màu trắng
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 8),
                                  child: const Text(
                                    '8:23',
                                    style: TextStyle(
                                      color: Colors.purple,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: Row(
                              children: [
                                Image.network(
                                  'assets/images/postermada.jpg', // Replace with actual image URL
                                  width: 100,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Quái vật không gian',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text('2D Phụ đề'),
                                      Text('PANTHERS Tô Ký - Rap 2'),
                                      Text('17:30 - T5 12/09/2024'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(thickness: 1, color: Colors.grey),
                          // Transaction Information
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Thông tin giao dịch'),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('1x Vé xem phim - G7'),
                                    Text('60.000 VND'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('1x Combo solo - bắp nước'),
                                    Text('94.000 VND'),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Tổng cộng:'),
                                    Text('154.000 VND'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(thickness: 1, color: Colors.grey),
                          // Voucher Section
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.percent, color: Colors.purple),
                                    SizedBox(width: 8),
                                    Text('PANTHERs Voucher'),
                                  ],
                                ),
                                const Text('-30K',
                                    style: TextStyle(color: Colors.blue)),
                              ],
                            ),
                          ),
                          const Divider(thickness: 1, color: Colors.grey),
                          // Total Payment Information
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Tổng thanh toán'),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Tổng thanh toán:'),
                                    Text('154.000 VND'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Giảm giá voucher:'),
                                    Text('30.000 VND'),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Còn lại:',
                                        style: TextStyle(color: Colors.red)),
                                    Text('124.000 VND',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(thickness: 1, color: Colors.grey),
                          // Payment Methods
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Phương thức thanh toán'),
                                SizedBox(height: 8),
                                ListTile(
                                  leading: Icon(Icons.credit_card),
                                  title: Text('ATM/ VISA/ MASTER/ JCB/ QRCODE'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.qr_code),
                                  title: Text('VNPAY'),
                                ),
                                ListTile(
                                  leading: Icon(Icons.mobile_friendly),
                                  title: Text('MOMO'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 0,
                    thickness: 6,
                    color: Color(0xfff0f0f0),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: MyButton(
                      fontsize: 20,
                      paddingText: 10,
                      text: 'Thanh toán',
                      isBold: true,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
