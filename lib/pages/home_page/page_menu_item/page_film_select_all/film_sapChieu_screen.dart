import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FilmSapchieuScreen extends StatefulWidget {
  const FilmSapchieuScreen({super.key});

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
          "imageUrl": "assets/images/postermada.jpg",
        },
        {
          "title": "Chàng nữ phi công",
          "releaseDate": "30/08/2024",
          "genre": "Hài",
          "imageUrl": "assets/images/postermada.jpg",
        },
        {
          "title": "HELLBOY: Đại chiến quỷ dữ",
          "releaseDate": "30/08/2024",
          "genre": "Hành động, Kinh dị",
          "imageUrl": "assets/images/postermada.jpg",
        },
        {
          "title": "200% Sói Bánh",
          "releaseDate": "30/08/2024",
          "genre": "Hoạt hình, Phiêu lưu",
          "imageUrl": "assets/images/postermada.jpg",
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
          "imageUrl": "assets/images/postermada.jpg",
        },
        {
          "title": "Xuyên không cải mệnh gia tộc",
          "releaseDate": "06/09/2024",
          "genre": "Hài, Hành động",
          "imageUrl": "assets/images/postermada.jpg",
        },
        {
          "title": "Không nói điều dối",
          "releaseDate": "13/09/2024",
          "genre": "Kinh dị, Tâm lý, Hồi hộp",
          "imageUrl": "assets/images/postermada.jpg",
        },
        {
          "title": "Báo thù từ tìm chủ",
          "releaseDate": "13/09/2024",
          "genre": "Hoạt hình, Hài",
          "imageUrl": "assets/images/postermada.jpg",
        },
      ]
    },
  ];

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
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcOver,
                ),
              ),
            ),
            // Top Navigation Bar
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
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
            // Main Content
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 90, 16, 50),
                child: Column(
                  children: <Widget>[
                    SearchBarWithIcon(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (var monthData in moviesByMonth)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
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
                                        final movie =
                                            monthData['movies'][index];
                                        return MovieCard(movie: movie);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
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

class SearchBarWithIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Tìm tên phim',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
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
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              // Handle filter action
            },
          ),
        ),
      ],
    );
  }
}

class MovieCard extends StatelessWidget {
  final Map<String, String> movie;

  const MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    // Calculate the width based on screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth - 40) /
        3; // Adjust based on the number of cards you want in a row

    return Container(
      width: cardWidth, // Use calculated width
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: cardWidth * 1.3, // Adjust height proportionally
            width: cardWidth, // Use calculated width
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(movie['imageUrl']!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            movie['releaseDate']!,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            movie['title']!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              overflow: TextOverflow.ellipsis, // Handle overflow
            ),
            maxLines: 1, // Limits the text to one line
          ),
          Text(
            movie['genre']!,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
              overflow: TextOverflow.ellipsis, // Handle overflow
            ),
            maxLines: 1, // Limits the text to one line
          ),
        ],
      ),
    );
  }
}
