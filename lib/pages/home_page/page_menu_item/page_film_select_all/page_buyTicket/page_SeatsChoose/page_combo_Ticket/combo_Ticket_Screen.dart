import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/Chair_modal.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/page_SeatsChoose/page_billTicket/bill_Ticket_Screen.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/page_SeatsChoose/page_combo_Ticket/combo_model.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:intl/intl.dart';

class ComboTicketScreen extends StatefulWidget {
  final int movieID;
  final int cinemaRoomID;
  final int showTimeID;
  final String showtimeDate;
  final String startTime;
  final String endTime;
  final List<int> seatCodes;
  final int quantity;
  final double sumPrice;

  const ComboTicketScreen({
    Key? key,
    required this.movieID,
    required this.cinemaRoomID,
    required this.showTimeID,
    required this.showtimeDate,
    required this.startTime,
    required this.endTime,
    required this.quantity,
    required this.sumPrice,
    required this.seatCodes,
  }) : super(key: key);

  @override
  _ComboTicketScreenState createState() => _ComboTicketScreenState();
}

class _ComboTicketScreenState extends State<ComboTicketScreen>
    with AutomaticKeepAliveClientMixin {
  late ApiService _apiService;
  late List<ChairModel> _chairs = [];
  MovieDetails? _movieDetails; // New variable for movie details
  late int selectedCount = 0; // This will track the number of selected seats
  List<Map<String, dynamic>> selectedChairsInfo =
      []; // List to store selected chair info
  List<int> seatIDList = [];
  List<Combo> comboItems = [];
  List<Combo> nonComboItems = [];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadChairs();
    _loadMovieDetails();
    _loadComboItems(); // Add this
  }

  Future<void> _loadComboItems() async {
    try {
      final combos = await _apiService.getAllIsCombo();
      final nonCombos = await _apiService.getAllIsNotCombo();
      setState(() {
        comboItems = combos;
        nonComboItems = nonCombos;
      });
    } catch (e) {
      print('Error loading combo items: $e');
    }
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
            'Combo Vé',
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                TabBar(
                                  tabs: [
                                    Tab(text: 'Combo'),
                                    Tab(text: 'Bán lẻ'),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      500, // Set a fixed height for the TabBarView
                                  child: TabBarView(
                                    children: [
                                      // Combo tab content
                                      comboItems.isEmpty
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : ListView.builder(
                                              itemCount: comboItems.length,
                                              itemBuilder: (context, index) {
                                                final combo = comboItems[index];
                                                return _buildComboItem(
                                                  combo.title,
                                                  combo.subtitle,
                                                  formatPrice(combo.price) +
                                                      ' VND',
                                                  combo.image,
                                                );
                                              },
                                            ),
                                      // Bán lẻ tab content
                                      nonComboItems.isEmpty
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : ListView.builder(
                                              itemCount: nonComboItems.length,
                                              itemBuilder: (context, index) {
                                                final item =
                                                    nonComboItems[index];
                                                return _buildSingleItem(
                                                  item.title,
                                                  item.subtitle,
                                                  formatPrice(item.price) +
                                                      ' VND',
                                                  item.image,
                                                );
                                              },
                                            ),
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
                  // Bottom elements
                  const Divider(
                    height: 0,
                    thickness: 6,
                    color: Color(0xfff0f0f0),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            _movieDetails!.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            minFontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Text(
                          _movieDetails!.age,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildInfoItem(
                                '', '${widget.startTime} ~ ${widget.endTime}'),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.black,
                        width: 1,
                        height: 50,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildInfoItem(
                                'Thời lượng', '${widget.showtimeDate}'),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.black,
                        width: 1,
                        height: 50,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildInfoItem(
                                'Ngôn ngữ',
                                _movieDetails!.voiceover ? 'Lồng Tiếng' : '',
                                _movieDetails!.subTitle ? 'Phụ Đề' : ''),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: AutoSizeText(
                            'Tạm tính',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            minFontSize: 14,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 0, 5, 0),
                          child: AutoSizeText(
                            formatPrice(widget.sumPrice) + 'VND',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            minFontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: MyButton(
                      fontsize: 20,
                      paddingText: 10,
                      text: 'Tiếp tục',
                      isBold: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          SlideFromRightPageRoute(
                              page: BillTicketScreen(
                            movieID: widget.movieID,
                            quantity: widget.quantity,
                            sumPrice: widget.sumPrice,
                            showTimeID: widget.showTimeID,
                            seatCodes: widget.seatCodes,
                            showtimeDate: widget.showtimeDate,
                            startTime: widget.startTime,
                            endTime: widget.endTime,
                            cinemaRoomID: widget.cinemaRoomID,
                          )),
                        );
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

Widget _buildComboItem(
    String title, String description, String price, String imagePath) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            width: 100,
            height: 120,
            child: Image.network(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/combo1.png');
              },
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(description),
                Text(price, style: TextStyle(color: Colors.red)),
                Row(
                  children: [
                    IconButton(icon: Icon(Icons.remove), onPressed: () {}),
                    Text('0'),
                    IconButton(icon: Icon(Icons.add), onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSingleItem(
    String title, String description, String price, String imagePath) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            width: 100,
            height: 120,
            child: Image.network(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/combo1.png');
              },
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(description),
                Text(price, style: TextStyle(color: Colors.red)),
                Row(
                  children: [
                    IconButton(icon: Icon(Icons.remove), onPressed: () {}),
                    Text('0'),
                    IconButton(icon: Icon(Icons.add), onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildInfoItem(String title, [String? value, String? value3]) {
  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.center, // Căn giữa theo chiều ngang cho Column
    children: [
      if (value != null &&
          value.isNotEmpty) // Kiểm tra giá trị value có tồn tại và không rỗng
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      if (value3 != null &&
          value3.isNotEmpty) // Kiểm tra giá trị value3 có tồn tại và không rỗng
        Text(
          value3,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
    ],
  );
}

Widget _buildLegendItem(Color color, String label, {bool isEmpty = false}) {
  return Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: isEmpty ? Colors.white : color, // Set color based on isEmpty
          border: isEmpty
              ? Border.all(color: mainColor, width: 1) // Border for empty
              : null, // No border if not empty
          borderRadius:
              BorderRadius.circular(isEmpty ? 4 : 2), // Radius based on isEmpty
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}

class CurvedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    var path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    canvas.drawPath(path, shadowPaint);

    var paint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

String formatPrice(double price) {
  final formatter = NumberFormat('#,###');
  return formatter.format(price);
}
