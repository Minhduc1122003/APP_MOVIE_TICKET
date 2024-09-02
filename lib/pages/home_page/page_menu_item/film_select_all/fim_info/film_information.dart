import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/film_select_all/fim_info/bloc/film_info_Bloc.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

class FilmInformation extends StatefulWidget {
  final int movieId;
  const FilmInformation({super.key, required this.movieId});

  @override
  State<FilmInformation> createState() => _FilmInformationState();
}

class _FilmInformationState extends State<FilmInformation> {
  late ApiService _APIService;

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
  }

  Future<MovieDetails?> _loadMovieDetails() async {
    return await _APIService.findByViewMovieID(
        widget.movieId, UserManager.instance.user!.userId ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return FutureBuilder<MovieDetails?>(
      future: _loadMovieDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final movie = snapshot.data;
          print('Movie loaded: ${movie?.title}');
          return BlocProvider(
            create: (context) => FilmInfoBloc()..add(LoadData(movie)),
            child: Scaffold(
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
                  'Chi tiết phim',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                centerTitle: true,
              ),
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  // Top Navigation Bar
                  // Main Content
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
        } else {
          return Center(child: Text('No data available'));
        }
      },
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
            borderRadius:
                BorderRadius.circular(15), // Bo góc cho viền và hình ảnh
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.black, width: 10), // Viền cho hình ảnh
                borderRadius: BorderRadius.circular(15), // Bo góc cho viền
              ),
              child: Image.asset(
                context.read<FilmInfoBloc>().state.movieDetails?.posterUrl ??
                    'assets/images/default_poster.png', // Thêm fallback cho URL poster
                width: 130,
                height: 200,
                fit: BoxFit.cover, // Điều chỉnh ảnh cho phù hợp với khung
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.read<FilmInfoBloc>().state.movieDetails?.title ??
                      'Title Not Available', // Thêm fallback cho title
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  context.read<FilmInfoBloc>().state.movieDetails?.genres ??
                      'Genres Not Available', // Thêm fallback cho genres
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Text(
                    '${context.read<FilmInfoBloc>().state.movieDetails?.age ?? 'N/A'}+',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Phim được phổ biến đến người xem từ đủ ${context.read<FilmInfoBloc>().state.movieDetails?.age ?? 'N/A'} tuổi trở lên',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: FavouriteButton(),
                      ),
                    ),
                    SizedBox(width: 8), // Khoảng cách giữa 2 nút
                    Expanded(
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.only(
                                top: 0, left: 5, right: 5, bottom: 0),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.movie, size: 14),
                              SizedBox(width: 3),
                              Text(
                                'Trailer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
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

class FavouriteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilmInfoBloc, FilmInfoBlocState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: () {
            context.read<FilmInfoBloc>().add(ClickFavourite(
                state.movieDetails,
                state.movieDetails!.movieId,
                UserManager.instance.user!.userId));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.grey),
            padding:
                const EdgeInsets.only(top: 0, left: 5, right: 5, bottom: 0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                state.movieDetails?.favourite == true
                    ? Icons.favorite_outlined
                    : Icons.favorite_border_sharp,
                size: 14,
                color: state.movieDetails?.favourite == true
                    ? Color(0XFF6F3CD7)
                    : Colors.black,
              ),
              const SizedBox(
                width: 3, // Khoảng cách giữa icon và text
              ),
              Text(
                state.movieDetails?.favourite == true ? 'Đã thích' : 'Thích',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: state.movieDetails?.favourite == true
                      ? Color(0XFF6F3CD7)
                      : Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MovieInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
      child: BlocBuilder<FilmInfoBloc, FilmInfoBlocState>(
        builder: (context, state) {
          return Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoItem('Ngày khởi chiếu',
                        '${state.movieDetails?.releaseDate}'),
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
                    _buildInfoItem(
                        'Thời lượng', '${state.movieDetails?.duration} phút'),
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
                    _buildInfoItem('Ngôn ngữ',
                        '${state.movieDetails?.languageName}${state.movieDetails?.subTitle == true ? ', Phụ Đề' : ''}'),
                  ],
                ),
              ),
            ],
          );
        },
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
