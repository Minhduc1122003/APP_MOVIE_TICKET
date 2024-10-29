import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/buyTicket_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';

class GridviewCardFilmsapchieu extends StatelessWidget {
  final int movieId;
  final String title;
  final String rating;
  final String ratingCount;
  final String genre;
  final String cinema;
  final String duration;
  final String releaseDate;
  final String imageUrl;

  const GridviewCardFilmsapchieu({
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
    return GestureDetector(
      onTap: () {
        // Điều hướng đến trang chi tiết phim
        Navigator.push(
          context,
          SlideFromRightPageRoute(
            page: BuyTicketPage(
              movieId: movieId,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4.0, // Đổ bóng nhẹ
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: Hình ảnh
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/images/$imageUrl',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Row 2: Thông tin phim
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      child: AutoSizeText(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            overflow: TextOverflow.clip),
                        maxFontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Thể loại: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: genre,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Thời lượng: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: '$duration phút',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),

              Expanded(
                flex: 2,
                child: MyButton(
                  text: 'Mua vé',
                  paddingText: 5,
                  fontsize: 14,
                  onTap: () {
                    // Hàm xử lý khi bấm nút mua vé
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
