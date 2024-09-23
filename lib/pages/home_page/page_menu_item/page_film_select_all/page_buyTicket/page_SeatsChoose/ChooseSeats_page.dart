import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';

late ApiService _apiService = ApiService();

class ChooseseatsPage extends StatefulWidget {
  final int movieId;

  const ChooseseatsPage({super.key, required this.movieId});

  @override
  _ChooseseatsPageState createState() => _ChooseseatsPageState();
}

class _ChooseseatsPageState extends State<ChooseseatsPage>
    with AutomaticKeepAliveClientMixin {
  late ApiService _APIService; // Khởi tạo biến _APIService

  @override
  void initState() {
    super.initState();
    _APIService = ApiService(); // Khởi tạo _APIService
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Vì sử dụng AutomaticKeepAliveClientMixin, cần gọi super.build
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
                InteractiveViewer(
                  boundaryMargin: EdgeInsets.all(20.0),
                  minScale: 0.1, // Tỉ lệ thu nhỏ tối thiểu
                  maxScale: 4.0, // Tỉ lệ phóng to tối đa
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 16,
                      childAspectRatio: 1,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: 10 * 16,
                    itemBuilder: (context, index) {
                      final row = String.fromCharCode(65 + (index ~/ 16));
                      final seat = (index % 16) + 1;
                      final seatLabel = '$row$seat';
                      Color seatColor = Colors.grey[300]!;
                      if (['A1', 'A2', 'J15', 'J16'].contains(seatLabel)) {
                        seatColor = Color(0xFF6F3CD7);
                      }
                      return GestureDetector(
                        onTap: () {
                          // Handle seat selection
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: seatColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              seat.toString(),
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      );
                    },
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
