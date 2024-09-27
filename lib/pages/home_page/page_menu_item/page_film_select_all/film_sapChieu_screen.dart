import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:diacritic/diacritic.dart'; // Để xử lý loại bỏ dấu

class FilmSapchieuScreen extends StatefulWidget {
  const FilmSapchieuScreen({Key? key}) : super(key: key);

  @override
  State<FilmSapchieuScreen> createState() => _FilmSapchieuScreenState();
}

class _FilmSapchieuScreenState extends State<FilmSapchieuScreen> {
  final List<Map<String, dynamic>> moviesByMonth = [
    {
      "month": "Tháng 08/2024",
      "movies": [
        {
          "title": "Hai Mươi",
          "releaseDate": "30/08/2024",
          "genre": "Gia đình, Tâm lý",
          "imageUrl": "assets/images/lamgiauvoima.jpg",
        },
        {
          "title": "Chàng nữ phi công",
          "releaseDate": "30/08/2024",
          "genre": "Hài",
          "imageUrl": "assets/images/thamkichdigiao.jpg",
        },
        {
          "title": "HELLBOY: Đại chiến quỷ dữ",
          "releaseDate": "30/08/2024",
          "genre": "Hành động, Kinh dị",
          "imageUrl": "assets/images/thecrowbaothu.jpg",
        },
        {
          "title": "200% Sói Bánh",
          "releaseDate": "30/08/2024",
          "genre": "Hoạt hình, Phiêu lưu",
          "imageUrl": "assets/images/timkiemtainangamphu.jpg",
        },
      ]
    },
    {
      "month": "Tháng 09/2024",
      "movies": [
        {
          "title": "Ma siêu quậy",
          "releaseDate": "06/09/2024",
          "genre": "Kinh dị",
          "imageUrl": "assets/images/joker_folieadeuxdiencodoi.jpg",
        },
        {
          "title": "Xuyên không cải mệnh gia tộc",
          "releaseDate": "06/09/2024",
          "genre": "Hài, Hành động",
          "imageUrl": "assets/images/khongnoidieudu.jpg",
        },
        {
          "title": "Không nói điều dối",
          "releaseDate": "13/09/2024",
          "genre": "Kinh dị, Tâm lý, Hồi hộp",
          "imageUrl": "assets/images/henhovoisatnhan.jpg",
        },
        {
          "title": "Báo thù từ tìm chủ",
          "releaseDate": "13/09/2024",
          "genre": "Hoạt hình, Hài",
          "imageUrl": "assets/images/codauhaomon.jpg",
        },
      ]
    },
    {
      "month": "Tháng 10/2024",
      "movies": [
        {
          "title": "Báo thủ đi tìm chủ",
          "releaseDate": "06/10/2024",
          "genre": "Kinh dị",
          "imageUrl": "assets/images/baothuditimchu.jpg",
        },
        {
          "title": "Cám",
          "releaseDate": "14/10/2024",
          "genre": "Hài, Hành động",
          "imageUrl": "assets/images/cam.jpg",
        },
      ]
    },
  ];

  bool isSearching = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredMoviesByMonth = [];

  @override
  void initState() {
    super.initState();
    _filteredMoviesByMonth = List.from(moviesByMonth);

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
        _filteredMoviesByMonth = List.from(moviesByMonth);
      } else {
        _filteredMoviesByMonth = moviesByMonth
            .map((monthData) {
              final filteredMovies = monthData['movies'].where((movie) {
                final normalizedTitle =
                    removeDiacritics(movie['title'].toLowerCase());
                return normalizedTitle.contains(normalizedQuery);
              }).toList();
              return {
                'month': monthData['month'],
                'movies': filteredMovies,
              };
            })
            .where((monthData) => monthData['movies'].isNotEmpty)
            .toList();
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined,
                color: Colors.white, size: 16),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.horizontal,
                  child: child,
                ),
              );
            },
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
        body: BlocListener<SendCodeBloc, SendCodeState>(
          listener: (context, state) {
            if (state is SendCodeError) {
              EasyLoading.showError('Sai tài khoản hoặc mật khẩu');
            } else if (state is SendCodeWaiting) {
              EasyLoading.show(status: 'Loading...');
            } else if (state is SendCodeSuccess) {
              EasyLoading.dismiss();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                children: _filteredMoviesByMonth.map((monthData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          monthData['month'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: monthData['movies'].length,
                          itemBuilder: (context, index) {
                            final movie = monthData['movies'][index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                width: 150, // Chiều rộng cố định cho card
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      movie['imageUrl'],
                                      width: 150,
                                      height: 220,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      movie['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      maxLines: 1, // Giới hạn số dòng
                                      overflow: TextOverflow
                                          .ellipsis, // Hiển thị '...' nếu dài
                                    ),
                                    Text(
                                      movie['genre'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow
                                          .ellipsis, // Hiển thị '...' nếu dài
                                    ),
                                    Text(
                                      movie['releaseDate'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
