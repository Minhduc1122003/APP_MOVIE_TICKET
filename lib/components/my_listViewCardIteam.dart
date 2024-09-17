import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class MyListviewcarditeam extends StatefulWidget {
  final List<Map<String, dynamic>> filmList;

  const MyListviewcarditeam({required this.filmList, Key? key})
      : super(key: key);

  @override
  _MyListviewcarditeamState createState() => _MyListviewcarditeamState();
}

class _MyListviewcarditeamState extends State<MyListviewcarditeam> {
  final ScrollController _scrollController = ScrollController();
  bool _showPrevButton = false;
  bool _showNextButton = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _showPrevButton = _scrollController.offset > 0;
        _showNextButton = _scrollController.offset <
            _scrollController.position.maxScrollExtent;
      });
    });
  }

  void _scrollNext() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset + 150, // Scroll thêm 150 pixels
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollPrev() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.offset - 150, // Scroll lùi 150 pixels
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showButtons = widget.filmList.length > 3;
    return Stack(
      children: [
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            itemCount: widget.filmList.length,
            itemBuilder: (context, index) {
              final film = widget.filmList[index];
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
                          film['title'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
        ),
        if (showButtons)
          Positioned(
            left: 10,
            top: 0,
            bottom: 100,
            child: Align(
              alignment: Alignment.center,
              child: _showPrevButton
                  ? IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: _scrollPrev,
                    )
                  : SizedBox.shrink(),
            ),
          ),
        if (showButtons)
          Positioned(
            right: 10,
            top: 0,
            bottom: 100,
            child: Align(
              alignment: Alignment.center,
              child: _showNextButton
                  ? IconButton(
                      icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onPressed: _scrollNext,
                    )
                  : SizedBox.shrink(),
            ),
          ),
      ],
    );
  }
}
