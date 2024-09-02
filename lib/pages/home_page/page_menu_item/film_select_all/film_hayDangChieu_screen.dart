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
  late Future<List<MovieDetails>> _moviesFuture;
  late ApiService _APIService;

  @override
  void initState() {
    super.initState();
    _APIService = ApiService(); // Khởi tạo ChatService

    // Gọi hàm getAllMovies và lưu trữ kết quả vào biến _moviesFuture
    _moviesFuture = _APIService.getAllMovies();
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
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
          'Phim hay đang chiếu',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
              size: 20, // Kích thước icon search
            ),
            onPressed: () {
              // Xử lý khi nhấn vào icon search
            },
          ),
        ],
      ),
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
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  children: <Widget>[
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
                                  movieId: movie.movieId,
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
