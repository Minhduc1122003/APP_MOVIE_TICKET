import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/film_select_all/film_information.dart';

class MyListViewCardItem extends StatelessWidget {
  final int movieId;
  final String title;
  final String rating;
  final String ratingCount;
  final String genre;
  final String cinema;
  final String duration;
  final String releaseDate;
  final String imageUrl;

  const MyListViewCardItem({
    Key? key,
    required this.movieId,
    required this.title,
    required this.rating,
    required this.ratingCount,
    required this.genre,
    required this.cinema,
    required this.duration,
    required this.releaseDate,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:
              MainAxisSize.min, // Đảm bảo card không mở rộng toàn bộ chiều rộng
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        imageUrl,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 16),
                            SizedBox(width: 4),
                            RichText(
                              text: TextSpan(
                                text: '$rating',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 14,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '/10',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                              child: Text(
                                '($ratingCount đánh giá)',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Divider(thickness: 1, color: Colors.grey[300]),
                        Text("Thể loại: $genre",
                            style: TextStyle(fontSize: 14)),
                        SizedBox(height: 4),
                        Text('Rạp phim: $cinema',
                            style: TextStyle(fontSize: 14)),
                        SizedBox(height: 4),
                        Text('Thời lượng: $duration',
                            style: TextStyle(fontSize: 14)),
                        SizedBox(height: 4),
                        Text('Khởi chiếu: $releaseDate',
                            style: TextStyle(fontSize: 14)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            MyButton(
                              text: 'Chi tiết',
                              paddingText: 8.0,
                              fontsize: 14.0,
                              onTap: () {
                                print("MovieId From my movie $movieId");
                                Navigator.push(
                                  context,
                                  SlideFromRightPageRoute(
                                      page: FilmInformation(movieId: movieId)),
                                );
                              },
                            ),
                            SizedBox(width: 10),
                            MyButton(
                              text: 'Mua vé',
                              paddingText: 8.0,
                              fontsize: 14.0,
                              onTap: () {
                                // Xử lý khi nhấn nút 'Mua vé'
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              height: 3,
              color: Colors.grey, // Màu sắc của đường viền
            ),
          ],
        ),
      ),
    );
  }
}
