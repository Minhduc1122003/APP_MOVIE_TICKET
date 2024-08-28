import 'package:flutter/material.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FilmInformation extends StatefulWidget {
  const FilmInformation({super.key});

  @override
  State<FilmInformation> createState() => _FilmInformationState();
}

class _FilmInformationState extends State<FilmInformation> {
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<SendCodeBloc, SendCodeState>(
        listener: (context, state) async {
          if (state is SendCodeError) {
            EasyLoading.showError('Sai tài khoản hoặc mật khẩu');
          } else if (state is SendCodeWaiting) {
            EasyLoading.show(status: 'Loading...');
          } else if (state is SendCodeSuccess) {
            await Future.delayed(Duration(milliseconds: 150));
          }
        },
        child: Stack(
          children: [
            // Top Navigation Bar
            Positioned(
              top: statusBarHeight,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.keyboard_arrow_left,
                          size: 25, color: Colors.black),
                    ),
                    const Expanded(
                      child: Text(
                        'Thông tin vé',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Main Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 90, 10, 50),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MovieHeader(),
                      SizedBox(
                          height: 16), // Khoảng cách giữa các phần tử nếu cần
                      MovieInfo(),
                      SizedBox(
                          height: 16), // Khoảng cách giữa các phần tử nếu cần
                      RatingSection(),
                      SizedBox(
                          height: 16), // Khoảng cách giữa các phần tử nếu cần
                      PlotSummary(),
                      SizedBox(
                          height: 16), // Khoảng cách giữa các phần tử nếu cần
                      CastAndCrew(),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MovieHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/images/postermada.jpg', width: 120, height: 180),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ngày Xưa Có Một Chuyện Tình',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('Lãng Mạn', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Text(
                    '13+',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 8),
                Text('Phim được phổ biến đến người xem từ đủ 13 tuổi trở lên'),
                SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Thích'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Trailer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MovieInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoItem('Ngày khởi chiếu', '11/10/2024'),
          _buildInfoItem('Thời lượng', '123 phút'),
          _buildInfoItem('Ngôn ngữ', 'Phụ đề\nLồng Tiếng'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey)),
        SizedBox(height: 4),
        Text(value, textAlign: TextAlign.center),
      ],
    );
  }
}

class RatingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('8.9',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('/10', style: TextStyle(color: Colors.grey)),
              SizedBox(width: 8),
              Icon(Icons.star, color: Colors.orange),
            ],
          ),
          Text('(11 đánh giá)', style: TextStyle(color: Colors.grey)),
          // Implement rating chart here
        ],
      ),
    );
  }
}

class PlotSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nội dung phim',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
              'Chuyển thể từ truyện dài cùng tên của nhà văn Nguyễn Nhật Ánh.'),
          SizedBox(height: 8),
          Text(
              'Ngày Xưa Có Một Chuyện Tình xoay quanh câu chuyện tình bạn, tình yêu giữa hai chàng trai và một cô gái từ thuở ấu thơ cho đến khi trưởng thành, phải đối mặt với những thử thách của số phận. Trải dài t...'),
          TextButton(
            onPressed: () {},
            child: Text('Xem thêm', style: TextStyle(color: Colors.pink)),
          ),
        ],
      ),
    );
  }
}

class CastAndCrew extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đạo diễn & Diễn viên',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            children: [
              _buildActorItem('assets/images/postermada.jpg'),
              SizedBox(width: 8),
              _buildActorItem('assets/images/postermada.jpg'),
              SizedBox(width: 8),
              _buildActorItem('assets/images/postermada.jpg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActorItem(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(imagePath, width: 80, height: 80, fit: BoxFit.cover),
    );
  }
}
