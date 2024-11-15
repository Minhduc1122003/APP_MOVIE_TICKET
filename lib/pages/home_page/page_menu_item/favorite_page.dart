import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/fim_info/film_information.dart';
import 'package:flutter_app_chat/pages/login_page/login_page.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

final favoritePageKey = GlobalKey<FavoritePageState>();

class FavoritePage extends StatefulWidget {
  final Function? onRefresh;

  FavoritePage({this.onRefresh, Key? key}) : super(key: key ?? favoritePageKey);

  @override
  // Đổi tên từ _FavoritePageState thành FavoritePageState
  FavoritePageState createState() => FavoritePageState();
}

class FavoritePageState extends State<FavoritePage> {
  late ApiService _apiService;
  List<Map<String, dynamic>> listFilmFavourire =
      []; // Khai báo listFilmFavourire với kiểu dữ liệu phù hợp
  MovieDetails? _movieDetails; // New variable for movie details

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    if (UserManager.instance.user != null) {
      _fetchFavoriteFilms();
    }
  }

  Future<void> _fetchFavoriteFilms() async {
    print('đã gọi load data');
    try {
      List<Map<String, dynamic>> films =
          await _apiService.getFilmFavourire(UserManager.instance.user!.userId);
      setState(() {
        listFilmFavourire = films;
      });
      // Gọi callback onRefresh nếu có
      widget.onRefresh?.call();
    } catch (e) {
      print('Error fetching favorite films: $e');
    }
  }

  void refreshFavorites() {
    if (UserManager.instance.user != null) {
      _fetchFavoriteFilms();
    }
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
          automaticallyImplyLeading: false,
          title: Text(
            'Phim yêu thích',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.7),
                  BlendMode.srcOver,
                ),
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Kiểm tra trạng thái đăng nhập
    if (UserManager.instance.user == null) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Bo góc card
          side: BorderSide(color: Colors.grey[300]!, width: 1), // Viền xám
        ),
        elevation: 5, // Độ đổ bóng nhẹ
        margin: const EdgeInsets.symmetric(
            vertical: 100, horizontal: 40), // Khoảng cách xung quanh card
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Padding trong card
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_outline,
                  size: 70,
                  color: Colors.deepOrangeAccent,
                ),
                SizedBox(height: 16),
                Text(
                  'Bạn chưa đăng nhập',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Vui lòng đăng nhập để xem phim yêu thích',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: MyButton(
                    fontsize: 16,
                    paddingText: 16,
                    text: 'ĐĂNG NHẬP',
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideFromRightPageRoute(
                            page: LoginPage(
                          isBack: true,
                          onPopCallback: () {
                            refreshFavorites();
                          },
                        )),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    // Hiển thị loading khi đang tải dữ liệu
    if (listFilmFavourire.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Bo góc card
          side: BorderSide(color: Colors.grey[300]!, width: 1), // Viền xám
        ),
        elevation: 5, // Độ đổ bóng nhẹ
        margin: const EdgeInsets.symmetric(
            vertical: 100, horizontal: 40), // Khoảng cách xung quanh card
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Padding trong card
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_outline,
                  size: 70,
                  color: Colors.deepOrangeAccent,
                ),
                SizedBox(height: 16),
                Text(
                  'Bạn chưa thích phim nào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Hiển thị danh sách phim yêu thích
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 0.55,
      ),
      itemCount: listFilmFavourire.length,
      itemBuilder: (context, index) {
        final film = listFilmFavourire[index];
        return GestureDetector(
          onTap: () {
            int movieID =
                int.parse(film['MovieID'].toString()); // Chuyển đổi sang int
            Navigator.push(
              context,
              SlideFromRightPageRoute(
                page: FilmInformation(
                  movieId: movieID,
                  onPopCallback: () {
                    print("Đã callback từ FilmInformation");
                    refreshFavorites();
                  },
                ),
              ),
            );
          },
          child: Card(
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black.withOpacity(0.1),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: film['PosterUrl'],
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(), // Hiển thị vòng tròn khi đang tải
                        errorWidget: (context, url, error) => const Icon(Icons
                            .error), // Hiển thị icon lỗi nếu tải ảnh không thành công
                        fadeInDuration: const Duration(
                            seconds: 1), // Thời gian hiệu ứng fade-in
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: AutoSizeText(
                    film['Title'] ?? 'No Title',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12, // Kích thước chữ tối đa
                    ),
                    maxLines: 1, // Tối đa 2 dòng
                    minFontSize: 10, // Kích thước chữ nhỏ nhất
                    overflow: TextOverflow.ellipsis, // Cắt bớt khi tràn
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
