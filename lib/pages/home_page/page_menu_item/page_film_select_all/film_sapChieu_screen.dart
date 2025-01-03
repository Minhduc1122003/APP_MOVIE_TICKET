import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_listViewCardIteam.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:diacritic/diacritic.dart'; // Để xử lý loại bỏ dấu
import 'package:intl/intl.dart'; // Để xử lý ngày tháng

class FilmSapchieuScreen extends StatefulWidget {
  final List<MovieDetails> filmSapChieu;

  const FilmSapchieuScreen({Key? key, required this.filmSapChieu})
      : super(key: key);

  @override
  State<FilmSapchieuScreen> createState() => _FilmSapchieuScreenState();
}

class _FilmSapchieuScreenState extends State<FilmSapchieuScreen> {
  bool isSearching = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  List<MovieDetails> _filteredMovies = [];

  @override
  void initState() {
    super.initState();
    _filteredMovies = List.from(widget.filmSapChieu);

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _searchController.text.isEmpty) {
        setState(() {
          isSearching = false;
        });
      }
    });

    _searchController.addListener(() {
      _filterMovies(_searchController.text);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterMovies(String query) {
    final normalizedQuery = removeDiacritics(query.toLowerCase());

    setState(() {
      if (normalizedQuery.isEmpty) {
        _filteredMovies = List.from(widget.filmSapChieu);
      } else {
        _filteredMovies = widget.filmSapChieu.where((movie) {
          final normalizedTitle = removeDiacritics(movie.title.toLowerCase());
          return normalizedTitle.contains(normalizedQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> moviesByMonth =
        _mapMoviesByMonth(_filteredMovies); // Sử dụng danh sách phim đã lọc

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: mainColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined,
                color: Colors.white, size: 16),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isSearching
                ? TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm phim...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(color: Colors.black),
                  )
                : const Text('Phim sắp chiếu',
                    style: TextStyle(color: Colors.white)),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 20),
              onPressed: () {
                setState(() {
                  if (isSearching) {
                    _searchController.clear();
                    isSearching = false;
                  } else {
                    isSearching = true;
                  }
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: moviesByMonth.entries.map((entry) {
              final month = entry.key;
              final movieList = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề tháng
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Text(
                      month,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                  ),
                  // Danh sách phim của tháng đó
                  SizedBox(
                    height: 300,
                    child: MyListviewCardItem(filmList: movieList),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

Map<String, List<Map<String, dynamic>>> _mapMoviesByMonth(
    List<MovieDetails> movies) {
  // Sắp xếp phim theo tháng phát hành
  Map<String, List<Map<String, dynamic>>> moviesByMonth = {};

  for (var movie in movies) {
    // Chuyển chuỗi releaseDate thành DateTime
    final releaseDate = DateFormat('dd/MM/yyyy').parse(movie.releaseDate);
    final monthYear = "Tháng ${DateFormat('MM/yyyy').format(releaseDate)}";

    if (!moviesByMonth.containsKey(monthYear)) {
      moviesByMonth[monthYear] = [];
    }

    moviesByMonth[monthYear]!.add({
      'image': 'assets/images/${movie.posterUrl}',
      'title': movie.title,
      'rating': movie.averageRating,
      'genre': movie.genres,
      'movieID': movie.movieId,
      'releaseDate': releaseDate // Lưu lại kiểu DateTime để sử dụng
    });
  }

  return moviesByMonth; // Trả về bản đồ phim theo tháng
}

List<Map<String, dynamic>> _mapMoviesToFilmList(List<MovieDetails> movies) {
  return movies.map((movie) {
    return {
      'image': 'assets/images/${movie.posterUrl}',
      'title': movie.title,
      'rating': movie.averageRating,
      'genre': movie.genres,
      'movieID': movie.movieId
    };
  }).toList();
}
