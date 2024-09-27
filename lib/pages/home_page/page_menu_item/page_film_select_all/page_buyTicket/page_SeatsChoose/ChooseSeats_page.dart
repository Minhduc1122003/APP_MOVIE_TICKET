import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/Chair_modal.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/buyTicket_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/page_SeatsChoose/cinema_seat_grid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ChooseseatsPage extends StatefulWidget {
  final int movieID;
  final int cinemaRoomID;
  final int showTimeID;
  final String showtimeDate;
  final String startTime;
  final String endTime;

  const ChooseseatsPage({
    Key? key,
    required this.movieID,
    required this.cinemaRoomID,
    required this.showTimeID,
    required this.showtimeDate,
    required this.startTime,
    required this.endTime,
  }) : super(key: key);

  @override
  _ChooseseatsPageState createState() => _ChooseseatsPageState();
}

class _ChooseseatsPageState extends State<ChooseseatsPage>
    with AutomaticKeepAliveClientMixin {
  late ApiService _apiService;
  late List<ChairModel> _chairs = [];
  MovieDetails? _movieDetails; // New variable for movie details
  late int selectedCount = 0; // This will track the number of selected seats

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
          'Trung Tâm Đặt Vé',
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
                        Container(
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 40,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: CustomPaint(
                                  size: const Size(double.infinity, 40),
                                  painter: CurvedLinePainter(),
                                ),
                              ),
                              const Text(
                                'MÀN HÌNH',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6F3CD7),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                child: Center(
                                  child: InteractiveViewer(
                                    boundaryMargin: const EdgeInsets.all(80.0),
                                    minScale: 0.01,
                                    maxScale: 4.0,
                                    child: CinemaSeatGrid(
                                      chairs: _chairs,
                                      onCountChanged: (int change) {
                                        setState(() {
                                          selectedCount +=
                                              change; // Update selectedCount based on change
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildLegendItem(
                                      Colors.grey[300]!, 'Ghế trống',
                                      isEmpty: true),
                                  _buildLegendItem(
                                      const Color(0xFF6F3CD7), 'Ghế bạn chọn'),
                                  _buildLegendItem(Colors.red, 'Đã đặt'),
                                ],
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Các phần tử nằm ở đáy
                const Divider(
                  height: 0,
                  thickness: 6,
                  color: Color(0xfff0f0f0),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 5, 0),
                        child: Align(
                            alignment: Alignment
                                .topRight, // Căn giữa ở phía trên bên phải
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: const BoxDecoration(
                                    color: Color(0XFF6F3CD7),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                  ),
                                  child: const Text(
                                    'Đổi suất',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ))),
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
                          _movieDetails != null && selectedCount > 0
                              ? '${formatPrice(_movieDetails!.price! * selectedCount)} VND'
                              : _movieDetails != null
                                  ? '0 VND' // Display 0 VND when no chairs are selected
                                  : 'Đang tải...',
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
                    text: 'Đặt vé ngay',
                    isBold: true,
                    onTap: () => Navigator.push(
                      context,
                      SlideFromRightPageRoute(
                        page: BuyTicketPage(
                          movieId: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
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
              ? Border.all(
                  color: Color(0xFF6F3CD7), width: 1) // Border for empty
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
      ..color = const Color(0xFF6F3CD7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
