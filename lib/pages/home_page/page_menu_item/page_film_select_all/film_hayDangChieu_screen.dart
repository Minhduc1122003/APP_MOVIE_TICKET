import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_listViewCardIteam.dart'; // Giả sử bạn có một tiện ích tương tự đã tạo
import 'package:flutter_app_chat/components/my_movie_item.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:diacritic/diacritic.dart'; // Để xử lý loại bỏ dấu

class FilmHaydangchieuScreen extends StatefulWidget {
  const FilmHaydangchieuScreen({super.key});

  @override
  State<FilmHaydangchieuScreen> createState() => _FilmHaydangchieuScreenState();
}

class _FilmHaydangchieuScreenState extends State<FilmHaydangchieuScreen> {
  late Future<List<MovieDetails>> _moviesFuture;
  late ApiService _APIService;
  bool isSearching = false;
  FocusNode _focusNode = FocusNode();
  TextEditingController _searchController = TextEditingController();
  List<MovieDetails> _allMovies = []; // Danh sách tất cả các phim
  List<MovieDetails> _filteredMovies = []; // Danh sách phim sau khi lọc

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
    _moviesFuture = _APIService.getMoviesDangChieu();

    _moviesFuture.then((movies) {
      setState(() {
        _allMovies = movies; // Lưu toàn bộ phim
        _filteredMovies = movies; // Khởi tạo danh sách lọc
      });
    });

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          if (_searchController.text.isEmpty) {
            isSearching = false; // Chỉ khi không có ký tự mới ẩn TextField
          }
        });
      }
    });

    // Lắng nghe sự thay đổi khi người dùng nhập ký tự
    // Lắng nghe sự thay đổi khi người dùng nhập ký tự
    _searchController.addListener(() {
      _filterMovies(_searchController.text);
      if (_searchController.text.isNotEmpty) {
        setState(() {
          isSearching = true; // Hiển thị TextField khi có ký tự nhập vào
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Hàm lọc phim dựa trên tên và từ khóa tìm kiếm
  void _filterMovies(String query) {
    final normalizedQuery = removeDiacritics(
        query.toLowerCase()); // Bỏ dấu và chuyển thành chữ thường

    setState(() {
      if (normalizedQuery.isEmpty) {
        _filteredMovies = _allMovies; // Hiển thị tất cả phim khi không tìm kiếm
      } else {
        _filteredMovies = _allMovies.where((movie) {
          final normalizedTitle = removeDiacritics(
              movie.title.toLowerCase()); // Bỏ dấu và chuyển thành chữ thường
          return normalizedTitle.contains(normalizedQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0XFF6F3CD7),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined,
                color: Colors.white, size: 16),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: AnimatedSwitcher(
              duration: Duration(milliseconds: 300), // Thời gian cho animation
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity:
                      animation, // Sử dụng FadeTransition để tạo hiệu ứng mờ dần
                  child: SizeTransition(
                    sizeFactor:
                        animation, // Kết hợp với SizeTransition để phóng to thu nhỏ
                    axis: Axis.horizontal, // Hiệu ứng theo chiều ngang
                    child: child,
                  ),
                );
              },
              child: isSearching || _searchController.text.isNotEmpty
                  ? TextField(
                      controller:
                          _searchController, // Sử dụng controller để lắng nghe input
                      focusNode: _focusNode,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm phim...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(color: Colors.black),
                    )
                  : Text('Phim hay đang chiếu',
                      style: TextStyle(color: Colors.white, fontSize: 20))),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.white, size: 20),
              onPressed: () {
                setState(() {
                  if (isSearching || _searchController.text.isNotEmpty) {
                    _searchController.clear();
                    isSearching =
                        false; // Đặt trạng thái tìm kiếm thành false và xóa nội dung
                  } else {
                    isSearching =
                        true; // Bật trạng thái tìm kiếm khi nhấn vào icon
                  }
                });
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: FutureBuilder<List<MovieDetails>>(
          future: _moviesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text(
                'No movies available.',
                style: TextStyle(color: Colors.black),
              ));
            } else {
              // Kiểm tra nếu danh sách phim sau khi lọc rỗng
              if (_filteredMovies.isEmpty) {
                return Center(child: Text('Không tìm thấy phim.'));
              } else {
                return ListView.builder(
                  itemCount: _filteredMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _filteredMovies[index];
                    return MyListViewCardItem(
                      movieId: movie.movieId,
                      title: movie.title,
                      rating: movie.averageRating.toString(),
                      ratingCount: movie.reviewCount.toString(),
                      genre: movie.genres,
                      cinema: movie.cinemaName,
                      duration: movie.duration.toString(),
                      releaseDate: movie.releaseDate.toString(),
                      imageUrl: movie.posterUrl,
                    );
                  },
                );
              }
            }
          },
        ),
      ),
    );
  }
}

extension on String {
  join(String s) {}
}
