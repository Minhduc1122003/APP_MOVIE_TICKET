import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/models/Chair_modal.dart';
import 'package:flutter_app_chat/models/ShowTime_modal.dart';

late ApiService _apiService = ApiService();

class ChooseseatsPage extends StatefulWidget {
  final int cinemaRoomID;
  final int showTimeID;

  const ChooseseatsPage(
      {super.key, required this.cinemaRoomID, required this.showTimeID});

  @override
  _ChooseseatsPageState createState() => _ChooseseatsPageState();
}

class _ChooseseatsPageState extends State<ChooseseatsPage>
    with AutomaticKeepAliveClientMixin {
  late ApiService _APIService;
  late List<ChairModel> _chair = [];

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
    _loadChair();
  }

  Future<void> _loadChair() async {
    try {
      _chair = await _APIService.getChairList(
          widget.cinemaRoomID, widget.showTimeID);
      if (_chair.isNotEmpty) {
        print('Đã tìm thấy ghế!');
        setState(() {}); // Cập nhật UI sau khi tải dữ liệu
      } else {
        print('Không tìm thấy ghế nào.');
      }
    } catch (e) {
      print('Lỗi khi tải ghế: $e');
    }
  }

  Widget buildCinemaSeatGrid(List<ChairModel> chairs) {
    // Giả định kích thước chiều rộng của GridView
    double gridWidth = MediaQuery.of(context).size.width;
    int numberOfColumns = 16;
    double cellSize = (gridWidth - (numberOfColumns - 1) * 4) /
        numberOfColumns; // 4 là khoảng cách giữa các ô

    return Stack(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: numberOfColumns,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: chairs.length,
          itemBuilder: (context, index) {
            final chair = chairs[index];
            String seatLabel = chair.chairCode;

            Color seatColor = Colors.grey[300]!;
            if (chair.reservationStatus) {
              seatColor = Colors.red;
            } else if (chair.defectiveChair) {
              seatColor = Colors.black;
            } else if (['A1', 'A2', 'J15', 'J16'].contains(seatLabel)) {
              seatColor = Color(0xFF6F3CD7);
            }

            return GestureDetector(
              onTap: () {
                print('Ghế được chọn: $seatLabel');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: seatColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    seatLabel,
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            );
          },
        ),
        // Vẽ hình vuông tại trung tâm, chứa khoảng 20 ghế (5x4)
        CustomPaint(
          size: Size(double.infinity, double.infinity),
          painter: SquareCenterPainter(
            center: Offset(
              (numberOfColumns / 2 - 2) * cellSize, // Đặt hình vuông ở giữa
              (numberOfColumns / 2 - 2) * cellSize, // Đặt hình vuông ở giữa
            ),
            cellSize: cellSize *
                5, // Kích thước của khung lớn hơn để chứa khoảng 20 ghế
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFF6F3CD7),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 16,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Trung Tâm Đặt Vé',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Column(
              children: [
                // Screen
                Container(
                  width: double.infinity,
                  height: 40,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: CustomPaint(
                    size: Size(double.infinity, 40),
                    painter: CurvedLinePainter(),
                  ),
                ),
                Text(
                  'MÀN HÌNH',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6F3CD7),
                  ),
                ),
                SizedBox(height: 20),
                // Seating grid
                Container(
                  width: double.infinity, // Hoặc một giá trị cụ thể
                  height: 400, // Đặt chiều cao hoặc chiều rộng cho khung
                  child: InteractiveViewer(
                    boundaryMargin: EdgeInsets.all(20.0),
                    minScale: 0.1,
                    maxScale: 4.0,
                    child: buildCinemaSeatGrid(_chair),
                  ),
                ),
                SizedBox(height: 20),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(Colors.grey[300]!, 'Ghế trống'),
                    _buildLegendItem(Colors.red, 'Ghế đã chọn'),
                    _buildLegendItem(Color(0xFF6F3CD7), 'Ghế VIP'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // Giữ trạng thái của trang
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
      SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12)),
    ],
  );
}

class CurvedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Tạo paint cho bóng
    var shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3) // Màu sắc bóng
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Vẽ bóng trước
    var path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    canvas.drawPath(path, shadowPaint); // Vẽ bóng

    // Tạo paint cho đường chính
    var paint = Paint()
      ..color = Color(0xFF6F3CD7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Vẽ đường chính
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SquareCenterPainter extends CustomPainter {
  final Offset center;
  final double cellSize;

  SquareCenterPainter({required this.center, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.blue.withOpacity(0.5) // Màu cho khung vuông
      ..style = PaintingStyle.fill;

    // Vẽ hình vuông
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: cellSize, // Kích thước hình vuông lớn hơn để chứa 20 ghế
        height: cellSize,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
