import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/fim_info/film_information.dart';

class MyListviewCardItem extends StatefulWidget {
  final List<Map<String, dynamic>> filmList;

  const MyListviewCardItem({required this.filmList, Key? key})
      : super(key: key);

  @override
  _MyListviewCardItemState createState() => _MyListviewCardItemState();
}

class _MyListviewCardItemState extends State<MyListviewCardItem> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showPrevButton = ValueNotifier(false);
  final ValueNotifier<bool> _showNextButton = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateButtonVisibility);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateButtonVisibility);
    _scrollController.dispose();
    _showPrevButton.dispose();
    _showNextButton.dispose();
    super.dispose();
  }

  void _updateButtonVisibility() {
    _showPrevButton.value = _scrollController.offset > 0;
    _showNextButton.value =
        _scrollController.offset < _scrollController.position.maxScrollExtent;
  }

  void _scroll(double offset) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        (_scrollController.offset + offset).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showButtons = widget.filmList.length > 3;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            SizedBox(
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                itemCount: widget.filmList.length,
                itemBuilder: (context, index) {
                  return _buildFilmItem(widget.filmList[index]);
                },
              ),
            ),
            if (showButtons) ...[
              _buildNavigationButton(
                icon: Icons.arrow_back_ios,
                onPressed: _showPrevButton,
                alignment: Alignment.centerLeft,
              ),
              _buildNavigationButton(
                icon: Icons.arrow_forward_ios,
                onPressed: _showNextButton,
                alignment: Alignment.centerRight,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFilmItem(Map<String, dynamic> film) {
    return GestureDetector(
      onTap: () {
        // In ra ID của phần tử được bấm
        Navigator.push(
          context,
          SlideFromRightPageRoute(
            page: FilmInformation(movieId: film['movieID']),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilmImage(film['image']),
            const SizedBox(height: 8),
            _buildRating(film['rating']),
            _buildTitle(film['title']),
            _buildGenre(film['genre']),
          ],
        ),
      ),
    );
  }

  Widget _buildFilmImage(String imageUrl) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150, maxHeight: 220),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 150, // Chiều rộng của ảnh
          height: 220, // Chiều cao của ảnh
          fit: BoxFit.cover, // Cách co giãn ảnh để vừa vặn với kích thước
          placeholder: (context, url) =>
              const CircularProgressIndicator(), // Hiển thị vòng tròn khi đang tải
          errorWidget: (context, url, error) => const Icon(
              Icons.error), // Hiển thị icon lỗi nếu tải ảnh không thành công
          fadeInDuration:
              const Duration(seconds: 1), // Thời gian hiệu ứng fade-in
        ),
      ),
    );
  }

  Widget _buildRating(double rating) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.yellow, size: 18),
        const SizedBox(width: 5),
        AutoSizeText(
          '$rating/10',
          style: const TextStyle(color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return SizedBox(
      width: 150,
      child: AutoSizeText(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        minFontSize: 16,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildGenre(String genre) {
    return SizedBox(
      width: 150,
      child: AutoSizeText(
        genre,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
        minFontSize: 14,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required ValueNotifier<bool> onPressed,
    required Alignment alignment,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: ValueListenableBuilder<bool>(
          valueListenable: onPressed,
          builder: (context, value, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(icon, color: Colors.white),
                onPressed: value
                    ? () => _scroll(icon == Icons.arrow_back_ios ? -150 : 150)
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
