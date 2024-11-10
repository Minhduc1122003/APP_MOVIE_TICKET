import 'dart:async';

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
  final List<int> seatCodes;
  final int quantity;
  final double ticketPrice;
  final int quantityCombo;
  final double totalComboPrice;
  final List<String> titleCombo;
  const BillTicketScreen({
    Key? key,
    required this.movieID,
    required this.cinemaRoomID,
    required this.showTimeID,
    required this.showtimeDate,
    required this.startTime,
    required this.endTime,
    required this.quantity,
    required this.ticketPrice,
    required this.seatCodes,
    required this.quantityCombo,
    required this.totalComboPrice,
    required this.titleCombo,
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
  late Timer _timer;
  late int _remainingTime; // Thời gian còn lại tính bằng giây

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadChairs();
    _loadMovieDetails();
    print(widget.quantityCombo);
    _remainingTime = 15 * 60;
    _startTimer();
  }

  String _formatRemainingTime() {
    int minutes = _remainingTime ~/ 60;
    int seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer.cancel(); // Dừng khi thời gian còn lại bằng 0
      }
    });
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
  void dispose() {
    _timer.cancel();
    super.dispose();
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
                              color: mainColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Thời gian còn lại',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 8),
                                  child: Text(
                                    _formatRemainingTime(), // Hiển thị thời gian đếm ngược
                                    style: const TextStyle(
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
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Căn các phần tử từ đầu theo chiều dọc
                              children: [
                                // Hình ảnh
                                Image.asset(
                                  'assets/images/${_movieDetails!.posterUrl}',
                                  width: 100,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(width: 16),
                                // Phần thông tin
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .start, // Căn các phần tử từ đầu
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AutoSizeText(
                                        _movieDetails!.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 14,
                                      ),
                                      SizedBox(height: 8),
                                      AutoSizeText(
                                        "${widget.startTime} - ${widget.endTime}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 12,
                                      ),
                                      SizedBox(height: 8),
                                      AutoSizeText(
                                        _movieDetails!.cinemaName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 12,
                                      ),
                                      SizedBox(height: 8),
                                      AutoSizeText(
                                        _movieDetails!.age,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        minFontSize: 12,
                                      ),
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
                              children: [
                                Text('Thông tin giao dịch'),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${widget.quantity} Vé - ${widget.seatCodes}'),
                                    Text(
                                        '${formatPrice(widget.ticketPrice)} VND'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${widget.quantityCombo} - ${widget.titleCombo}'),
                                    Text(
                                        '${formatPrice(widget.totalComboPrice)} VND'),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Tổng cộng:'),
                                    Text(
                                        '${formatPrice(widget.ticketPrice + widget.totalComboPrice)} VND'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(thickness: 1, color: Colors.grey),
                          // Voucher Section
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.percent, color: Colors.purple),
                                    SizedBox(width: 8),
                                    Text('PANTHERs Voucher'),
                                  ],
                                ),
                                Text('-30K',
                                    style: TextStyle(color: Colors.blue)),
                              ],
                            ),
                          ),
                          const Divider(thickness: 1, color: Colors.grey),
                          // Total Payment Information
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Phương thức thanh toán'),
                                SizedBox(height: 8),
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

String formatPrice(double price) {
  final formatter = NumberFormat('#,###');
  return formatter.format(price);
}
