import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 70,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Bạn chưa đăng nhập',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
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
          ],
        ),
      );
    }

    // Hiển thị loading khi đang tải dữ liệu
    if (listFilmFavourire.isEmpty) {
      return Center(child: CircularProgressIndicator());
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
        return Card(
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
                      imageUrl: '${film['PosterUrl']}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  film['Title'] ?? 'No Title',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
