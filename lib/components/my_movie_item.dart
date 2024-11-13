import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/fim_info/film_information.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/buyTicket_page.dart';

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
      padding: const EdgeInsets.fromLTRB(5, 0, 10, 5),
      child: Card(
        elevation: 2,
        color: Colors.white, // Thêm màu nền trắng ở đây

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 10, 0, 5),
                  child: Container(
                    width: 100,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Align(
                      alignment: Alignment
                          .center, // Căn giữa theo chiều dọc và chiều ngang
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
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
                        AutoSizeText(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2, // Giới hạn số dòng hiển thị là 2
                          overflow: TextOverflow
                              .ellipsis, // Hiển thị "..." khi văn bản quá dài
                          minFontSize:
                              16, // Kích thước font tối thiểu khi tự động điều chỉnh
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 16),
                            RichText(
                              text: TextSpan(
                                text: '$rating',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                ),
                                children: const <TextSpan>[
                                  TextSpan(
                                    text: '/10',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
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
                        Text(
                          "$genre",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "$duration'",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '|',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '$releaseDate',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 0), // Khoảng cách dưới cùng
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: Center(
                                  child: MyButton(
                                    color: Colors.white.withOpacity(0.5),
                                    border: true,
                                    text: 'Chi tiết',
                                    paddingText: 8.0,
                                    fontsize: 14.0,
                                    colorText: Colors.black,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SlideFromRightPageRoute(
                                          page:
                                              FilmInformation(movieId: movieId),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Center(
                                  child: MyButton(
                                    text: 'Mua vé',
                                    paddingText: 8.0,
                                    fontsize: 14.0,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        SlideFromRightPageRoute(
                                          page: BuyTicketPage(
                                            movieId: movieId,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Phần chứa các nút nằm ở dưới cùng của card

            Container(
              width: double.infinity,
              height: 2,
              color: Colors.grey.withOpacity(0.1), // Màu sắc của đường viền
            ),
          ],
        ),
      ),
    );
  }
}
