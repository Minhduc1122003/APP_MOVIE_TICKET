import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/Chair_modal.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/buyTicket_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/page_SeatsChoose/cinema_seat_grid.dart';

class ChooseseatsPage extends StatefulWidget {
  final int cinemaRoomID;
  final int showTimeID;

  const ChooseseatsPage({
    Key? key,
    required this.cinemaRoomID,
    required this.showTimeID,
  }) : super(key: key);

  @override
  _ChooseseatsPageState createState() => _ChooseseatsPageState();
}

class _ChooseseatsPageState extends State<ChooseseatsPage>
    with AutomaticKeepAliveClientMixin {
  late ApiService _apiService;
  late List<ChairModel> _chairs = [];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadChairs();
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
      body: Column(
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
                          margin: const EdgeInsets.symmetric(horizontal: 20),
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
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildLegendItem(Colors.grey[300]!, 'Ghế trống'),
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
                const Expanded(
                  child: AutoSizeText(
                    'Đây là title của Đây lĐây là title của Đây lĐây là title của Đây là titl tle của ',
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
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 5, 0),
                  child: Align(
                      alignment:
                          Alignment.topRight, // Căn giữa ở phía trên bên phải
                      child: GestureDetector(
                          onTap: () {
                            print('Đổi xuất');
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0XFF6F3CD7),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                            child: Text(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: const Text(
                  '16+',
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
                    _buildInfoItem('', '17:19 ~ 21:23'),
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
                    _buildInfoItem('Thời lượng', '13/09/2024'),
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
                    _buildInfoItem('Ngôn ngữ', 'Lồng tiếng', 'Phụ Đề'),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
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
                    '60.000 VND',
                    style: TextStyle(
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

Widget _buildLegendItem(Color color, String label) {
  return Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
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
