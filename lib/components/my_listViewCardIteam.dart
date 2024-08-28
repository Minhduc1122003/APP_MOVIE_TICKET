import 'package:flutter/material.dart';

class MyListviewcarditeam extends StatelessWidget {
  final List<Map<String, dynamic>> filmList;

  const MyListviewcarditeam({required this.filmList, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300, // Tăng chiều cao của list ngang để phù hợp với item lớn hơn
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filmList.length,
        itemBuilder: (context, index) {
          final film = filmList[index];
          return GestureDetector(
            onTap: () {
              print(film['title']); // In ra tên phim khi nhấn vào
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7.0), // Khoảng cách giữa các item là 5
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Căn trái cho cột
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(12), // Bo góc của viền
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12), // Bo góc cho hình ảnh
                      child: Image.asset(
                        film['image'],
                        width: 150, // Tăng kích thước chiều rộng của item
                        height: 220, // Tăng kích thước chiều cao của item
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    film['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left, // Căn trái cho tiêu đề
                  ),
                  Text(
                    'Rating: ${film['rating']}',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.left, // Căn trái cho rating
                  ),
                  Text(
                    'Release: ${film['releaseDate']}',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.left, // Căn trái cho ngày phát hành
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
