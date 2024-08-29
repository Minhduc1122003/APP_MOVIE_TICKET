import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_listViewCardIteam.dart'; // Giả sử bạn có một tiện ích tương tự đã tạo
import 'package:flutter_app_chat/components/my_movie_item.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FilmHaydangchieuScreen extends StatefulWidget {
  const FilmHaydangchieuScreen({super.key});

  @override
  State<FilmHaydangchieuScreen> createState() => _FilmHaydangchieuScreenState();
}

class _FilmHaydangchieuScreenState extends State<FilmHaydangchieuScreen> {
  late Future<List<MovieDetails>> _moviesFuture; // Biến để lưu trữ dữ liệu phim
  late ApiService _APIService;

  @override
  void initState() {
    super.initState();
    _APIService = ApiService(); // Khởi tạo ChatService

    // Gọi hàm getAllMovies và lưu trữ kết quả vào biến _moviesFuture
    _moviesFuture = _APIService.getAllMovies();
  }

  // Mẫu danh sách phim
  // final List<Map<String, String>> movies = [
  //   {
  //     "title": "Shin cậu bé bút chì: Nhật ký khủng long của chúng mình",
  //     "rating": "9.2/10 (87 đánh giá)",
  //     "genre": "Hài, Hoạt hình, Phiêu lưu, Gia đình",
  //     "cinema": "PANTHERS Tô Ký",
  //     "duration": "97p",
  //     "releaseDate": "23/08/2024",
  //     "imageUrl": "assets/images/postermada.jpg",
  //   },
  //   {
  //     "title": "MA DA",
  //     "rating": "9.2/10 (87 đánh giá)",
  //     "genre": "Kinh dị",
  //     "cinema": "PANTHERS Tô Ký",
  //     "duration": "95p",
  //     "releaseDate": "16/08/2024",
  //     "imageUrl": "assets/images/postermada.jpg",
  //   },
  //   {
  //     "title": "MA DA",
  //     "rating": "9.2/10 (87 đánh giá)",
  //     "genre": "Kinh dị",
  //     "cinema": "PANTHERS Tô Ký",
  //     "duration": "95p",
  //     "releaseDate": "16/08/2024",
  //     "imageUrl": "assets/images/postermada.jpg",
  //   },
  //   {
  //     "title": "MA DA",
  //     "rating": "9.2/10 (87 đánh giá)",
  //     "genre": "Kinh dị",
  //     "cinema": "PANTHERS Tô Ký",
  //     "duration": "95p",
  //     "releaseDate": "16/08/2024",
  //     "imageUrl": "assets/images/postermada.jpg",
  //   },
  //   {
  //     "title": "MA DA",
  //     "rating": "9.2/10 (87 đánh giá)",
  //     "genre": "Kinh dị",
  //     "cinema": "PANTHERS Tô Ký",
  //     "duration": "95p",
  //     "releaseDate": "16/08/2024",
  //     "imageUrl": "assets/images/postermada.jpg",
  //   },
  //   // Thêm các phim khác vào danh sách movies
  // ];

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
            await Future.delayed(const Duration(milliseconds: 150));
            // Xử lý khi thành công nếu cần
          }
        },
        child: Stack(
          children: [
            const Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcOver,
                ),
              ),
            ),
            Positioned(
              top: statusBarHeight,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.keyboard_arrow_left,
                              size: 25, color: Colors.black),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 40, 0),
                          child: Text(
                            'Phim hay đang chiếu',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 90, 0, 0),
                child: Column(
                  children: <Widget>[
                    // Thêm SearchBarWithIcon ở đây
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SearchBarWithIcon(),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: FutureBuilder<List<MovieDetails>>(
                        future: _moviesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No movies available.'));
                          } else {
                            final movies = snapshot.data!;
                            return ListView.builder(
                              itemCount: movies.length,
                              itemBuilder: (context, index) {
                                final movie = movies[index];
                                return MyListViewCardItem(
                                  title: movie.title,
                                  rating: movie.averageRating
                                      .toString(), // Chuyển đổi sang chuỗi nếu cần
                                  ratingCount: movie.reviewCount.toString(),
                                  genre: movie
                                      .genres, // Chuyển đổi danh sách thể loại thành chuỗi
                                  cinema: movie.cinemaName,
                                  duration: movie.duration
                                      .toString(), // Chuyển đổi thời gian thành chuỗi nếu cần
                                  releaseDate: movie.releaseDate
                                      .toLocal()
                                      .toString(), // Chuyển đổi ngày tháng thành chuỗi
                                  imageUrl: movie.posterUrl,
                                );
                              },
                            );
                          }
                        },
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
}

extension on String {
  join(String s) {}
}

class SearchBarWithIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm tên phim',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              // Xử lý khi nhấn vào icon filter
            },
          ),
        ),
      ],
    );
  }
}
