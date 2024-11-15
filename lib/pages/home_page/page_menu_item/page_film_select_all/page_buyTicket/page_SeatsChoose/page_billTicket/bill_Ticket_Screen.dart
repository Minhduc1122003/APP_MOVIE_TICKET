import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/Chair_modal.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/page_SeatsChoose/page_detail/detail_invoice.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:intl/intl.dart';

class BillTicketScreen extends StatefulWidget {
  final int movieID;
  final int cinemaRoomID;
  final int showTimeID;
  final String showtimeDate;
  final String startTime;
  final String endTime;
  final int quantity;
  final List<Map<String, dynamic>> seatCodes;
  final double ticketPrice;
  final int quantityCombo;
  final double totalComboPrice;
  final List<Map<String, dynamic>> titleCombo;

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
  late int voucher = 30;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  String _selectedPaymentMethod = '';
  late final String idTicket;
  String seatsID = '';
  String comboIDList = '';
  String countComboID = '';
  String result = '';
  double tongTienConLai = 0.0;

  @override
  void initState() {
    List<String> comboIDList =
        widget.titleCombo.map((combo) => combo['comboId'].toString()).toList();
    List<String> countComboID =
        widget.titleCombo.map((combo) => combo['quantity'].toString()).toList();

    seatsID = widget.seatCodes.map((seats) => seats['id']).join(',');

    result = List.generate(comboIDList.length, (index) {
      return '${comboIDList[index]}:${countComboID[index]}';
    }).join(',');
    tongTienConLai =
        (widget.ticketPrice + widget.totalComboPrice) - (voucher * 1000);
    super.initState();
    _apiService = ApiService();
    _loadChairs();
    _loadMovieDetails();
    print(widget.quantityCombo);
    _remainingTime = 15 * 60;
    _startTimer();
    _scrollController.addListener(_scrollListener);
    _insertBuyTicket();
  }

  void _scrollListener() {
    if (_scrollController.offset > 10 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 10 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
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

  Future<void> _insertBuyTicket() async {
    String formattedDate = DateFormat('MMddHHmmss').format(DateTime.now());

    idTicket =
        '${UserManager.instance.user?.userId}${widget.movieID}${widget.showTimeID}$formattedDate';
    print('object');
    try {
      final response = await _apiService.insertBuyTicket(
          idTicket,
          UserManager.instance.user!.userId,
          widget.movieID,
          tongTienConLai,
          widget.showTimeID,
          seatsID,
          result);

      print("Thành công: $response");
    } catch (e) {
      print("Lỗi khi gọi API: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
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
            'Thông tin thanh toán',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: _movieDetails == null
            ? Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            children: [
                              SizedBox(
                                  height: _isScrolled
                                      ? 50
                                      : 4), // Thêm space khi có fixed container
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
                                          'Thời gian còn lại: ',
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
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                    Image.network(
                                      '${_movieDetails!.posterUrl}',
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

                              Divider(thickness: 1, color: Colors.grey),
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
                                            '${widget.quantity} Vé - ${widget.seatCodes.map((seat) => seat['code']).join(', ')}'),
                                        Text(
                                            '${formatPrice(widget.ticketPrice)}đ'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex:
                                              2, // Điều chỉnh tỷ lệ không gian cho phần title
                                          child: Row(
                                            children: [
                                              Text(
                                                  '${widget.quantityCombo} - '), // Số lượng combo = 0
                                              Expanded(
                                                child: AutoSizeText(
                                                  '${widget.titleCombo.isEmpty ? 'Không có combo' : widget.titleCombo.map((combo) => combo['title']).join(', ')}', // Kiểm tra nếu không có combo
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  minFontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${formatPrice(widget.totalComboPrice)}đ', // Giá combo = 0
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
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
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.percent,
                                            color: Colors.purple),
                                        SizedBox(width: 8),
                                        Text('PANTHERs Voucher'),
                                      ],
                                    ),
                                    Text(
                                      '${voucher}.000 VND', // Hiển thị giá trị voucher
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(thickness: 1, color: Colors.grey),
                              // Total Payment Information
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Tổng thanh toán:'),
                                        Text(
                                            '${formatPrice(widget.ticketPrice + widget.totalComboPrice)} VND'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Giảm giá voucher:'),
                                        Text('${voucher}.000 VND'),
                                      ],
                                    ),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Còn lại:',
                                            style:
                                                TextStyle(color: Colors.red)),
                                        Text(
                                            '${formatPrice((widget.ticketPrice + widget.totalComboPrice) - (voucher * 1000))} VND',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(thickness: 1, color: Colors.grey),
                              // Payment Methods
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Phương thức thanh toán'),
                                    SizedBox(height: 8),
                                    // Nút VNPAY
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 1,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                        minimumSize: Size(double.infinity, 50),
                                        backgroundColor: _selectedPaymentMethod ==
                                                'VNPAY'
                                            ? mainColor
                                            : Colors
                                                .white, // Thay đổi màu sắc dựa trên trạng thái
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _selectedPaymentMethod = 'VNPAY';
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.qr_code,
                                              color: Colors.blue),
                                          SizedBox(width: 16),
                                          Text('VNPAY'),
                                          Spacer(),
                                          Icon(Icons.arrow_forward_ios,
                                              size: 16),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    // Nút MOMO
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 1,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                        minimumSize: Size(double.infinity, 50),
                                        backgroundColor: _selectedPaymentMethod ==
                                                'MOMO'
                                            ? mainColor
                                            : Colors
                                                .white, // Thay đổi màu sắc dựa trên trạng thái
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _selectedPaymentMethod = 'MOMO';
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.mobile_friendly,
                                              color: Colors.pink),
                                          SizedBox(width: 16),
                                          Text('MOMO'),
                                          Spacer(),
                                          Icon(Icons.arrow_forward_ios,
                                              size: 16),
                                        ],
                                      ),
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
                            Navigator.push(
                              context,
                              SlideFromRightPageRoute(
                                  page: DetailInvoice(
                                movieDetails: _movieDetails,
                                quantity: selectedCount,
                                sumPrice:
                                    (_movieDetails!.price! * selectedCount),
                                showTimeID: widget.showTimeID,
                                seatCodes: widget.seatCodes,
                                idTicket: idTicket,
                                tongTienConLai: tongTienConLai,
                                quantityCombo: widget.quantityCombo,
                                ticketPrice: widget.ticketPrice,
                                titleCombo: widget.titleCombo,
                                totalComboPrice: widget.totalComboPrice,
                                showtimeDate: widget.showtimeDate,
                                cinemaRoomID: widget.cinemaRoomID,
                                startTime: widget.startTime,
                                endTime: widget.endTime,
                              )),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 300),
                    top: _isScrolled ? 0 : -100, // Thay đổi từ 0 thành 10
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Thời gian còn lại:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            child: Text(
                              _formatRemainingTime(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
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
