import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class MyListviewcarditeam extends StatelessWidget {
  final List<Map<String, dynamic>> filmList;

  const MyListviewcarditeam({required this.filmList, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
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
              padding: const EdgeInsets.symmetric(horizontal: 7.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: 150, // Đặt kích thước tối đa cho hình ảnh
                      maxHeight: 220,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        film['image'],
                        width: 150,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 150, // Đặt kích thước cho tiêu đề
                    child: AutoSizeText(
                      film['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 150, // Đặt kích thước cho rating
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow, size: 18),
                        SizedBox(width: 5),
                        AutoSizeText(
                          '${film['rating']}/10',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 150, // Đặt kích thước cho tiêu đề
                    child: AutoSizeText(
                      '${film['genre']}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
