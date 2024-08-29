import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FilmInformation extends StatefulWidget {
  final int movieId;
  const FilmInformation({super.key, required this.movieId});

  @override
  State<FilmInformation> createState() => _FilmInformationState();
}

class _FilmInformationState extends State<FilmInformation> {
  late Future<MovieDetails> _moviesFuture; // Biến để lưu trữ dữ liệu phim
  late ApiService _APIService;
  @override
  void initState() {
    super.initState();

    _APIService = ApiService(); // Khởi tạo ChatService

    _moviesFuture = _APIService.findByViewMovieID(widget.movieId);

    // Thực hiện các thao tác khởi tạo khác ở đây
    print('Movie ID: ${widget.movieId}');
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    print("_moviesFuture : $_moviesFuture");

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
                      child: const Icon(Icons.arrow_back_ios,
                          size: 20, color: Colors.black),
                    ),
                    const Expanded(
                      child: Text(
                        'Chi tiết phim',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24), // To balance the back button
                  ],
                ),
              ),
            ),
            // Main Content
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 90, 0, 0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Adjust for top bar
                      MovieHeader(),
                      MovieInfo(),
                      RatingSection(),
                      PlotSummary(),
                      CastAndCrew(),
                      BuyTicketButton(),
                    ],
                  ),
                ),
              ),
            ),
            // Buy Ticket Button at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BuyTicketButton(),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset('assets/images/postermada.jpg',
                width: 130, height: 200),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hellboy: Đại Chiến Quỷ Dữ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('Kinh Dị, Giả Tưởng',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Text(
                    'C16',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                SizedBox(height: 8),
                Text('Phim được phổ biến đến người xem từ đủ 16 tuổi trở lên',
                    style: TextStyle(fontSize: 12)),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(color: Colors.grey),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border_sharp,
                                size: 16), // Icon 'Thích'
                            SizedBox(width: 8), // Khoảng cách giữa icon và text
                            Text(
                              'Thích',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8), // Khoảng cách giữa 2 nút
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.movie, size: 16), // Icon 'Trailer'
                            SizedBox(width: 8), // Khoảng cách giữa icon và text
                            Text(
                              'Trailer',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
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
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoItem('Ngày khởi chiếu', '30/08/2024'),
              ],
            ),
          ),
          Container(
            color: Colors.black, // Màu của đường kẻ
            width: 1, // Độ dày của đường kẻ
            height: 50, // Chiều cao của đường kẻ
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoItem('Thời lượng', '123 phút'),
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
                _buildInfoItem('Ngôn ngữ', 'Phụ đề'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
        SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Phần tử chiếm 40% chiều rộng
                  const Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 30),
                            Text('7',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            Text('/10',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('(3 đánh giá)',
                            style:
                                TextStyle(color: Colors.black, fontSize: 12)),
                      ],
                    ),
                  ),
                  // Phần tử chiếm 60% chiều rộng
                  Expanded(
                    flex: 6,
                    child: _buildRatingBar(), // Thay thế bằng widget của bạn
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRatingBar() {
    return Column(
      children: [
        _buildRatingRow('9-10', 0),
        _buildRatingRow('7-8', 0),
        _buildRatingRow('5-6', 0),
        _buildRatingRow('3-4', 0),
        _buildRatingRow('1-2', 1),
      ],
    );
  }

  Widget _buildRatingRow(String label, int value) {
    return Row(
      children: [
        SizedBox(
            width: 40,
            child: Text(label,
                style: TextStyle(fontSize: 12, color: Colors.black))),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 10,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
      ],
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            'Cuộc chiến mạn (rợ) nhất từ đủa con của địa ngục. Sẵn sàng bước vào cuộc chiến tàn khốc, Hellboy đối đầu với The Crooked Man - một ác quỷ đầy quyền năng và thù ác. Phần phim điều tra viên bán quỷ vào trận chiến nguy hiểm nhất từ trước đến nay, nó...',
            style: TextStyle(fontSize: 14),
          ),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActorItem('assets/images/postermada.jpg', 'Actor 1'),
                SizedBox(width: 8),
                _buildActorItem('assets/images/postermada.jpg', 'Actor 2'),
                SizedBox(width: 8),
                _buildActorItem('assets/images/postermada.jpg', 'Actor 3'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActorItem(String imagePath, String name) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              Image.asset(imagePath, width: 80, height: 80, fit: BoxFit.cover),
        ),
        SizedBox(height: 4),
        Text(name, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class BuyTicketButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: MyButton(
        fontsize: 14,
        paddingText: 10,
        text: 'Đặt vé ngay',
        onTap: () {},
      ),
    );
  }
}
