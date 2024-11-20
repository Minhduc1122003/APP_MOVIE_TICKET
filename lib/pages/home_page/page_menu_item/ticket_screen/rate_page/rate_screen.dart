import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/models/BuyTicket_model.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/fim_info/bloc/film_info_Bloc.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:get/get.dart';

import '../../../../../../../auth/api_service.dart';

late ApiService _apiService = ApiService();

class RateScreen extends StatefulWidget {
  final BuyTicket buyTicket;
  const RateScreen({Key? key, required this.buyTicket}) : super(key: key);

  @override
  RateScreenState createState() => RateScreenState();
}

class RateScreenState extends State<RateScreen>
    with AutomaticKeepAliveClientMixin {
  late final ApiService _apiService;
  int _selectedStars = 0; // Số sao được chọn
  late final TextEditingController
      _noteController; // Tạo controller cho TextField
  Map<String, dynamic>? _rateInfo; // Biến lưu trữ thông tin đánh giá

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _noteController = TextEditingController(); // Khởi tạo controller
    _fetchRateInfo(); // Gọi API để lấy thông tin đánh giá
  }

  Future<void> _insertRate(String content, int rating) async {
    EasyLoading.show();
    try {
      final message = await _apiService.insertRate(
          UserManager.instance.user!.userId, // ID người dùng
          widget.buyTicket.movieID, // ID phim
          content, // Nội dung đánh giá
          rating // Số sao đánh giá
          );

      // Kiểm tra phản hồi từ server
      if (message == "Rate inserted successfully") {
        EasyLoading.dismiss();
        EasyLoading.showSuccess("Gửi đánh giá thành công!");
        Navigator.pop(context);
      } else {
        EasyLoading.dismiss();
        EasyLoading.showError("Lỗi khi gửi đánh giá!");
      }
    } catch (e) {
      // Xử lý lỗi khi gọi API
      print("Lỗi khi gọi API đánh giá: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Có lỗi xảy ra, vui lòng thử lại sau.")),
      );
    }
  }

  void _fetchRateInfo() async {
    try {
      // Giả sử API trả về dữ liệu đánh giá trong Map
      final rateInfo = await _apiService.getRate(
          UserManager.instance.user!.userId, widget.buyTicket.movieID);

      setState(() {
        _rateInfo = rateInfo; // Cập nhật dữ liệu đánh giá vào _rateInfo
      });

      // Cập nhật _noteController và RatingController khi có dữ liệu đánh giá
      if (_rateInfo != null && _rateInfo!['Rating'] != null) {
        int rating = _rateInfo!['Rating'];
        final RatingController ratingController = Get.find<RatingController>();
        ratingController.updateStars(rating);
        _noteController.text = _rateInfo!['Content'] ??
            ''; // Cập nhật nội dung vào _noteController
      }
    } catch (e) {
      // Xử lý lỗi khi gọi API
      print("Lỗi khi tải thông tin đánh giá: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final RatingController ratingController = Get.put(RatingController());

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset:
          true, // Đảm bảo nội dung cuộn khi bàn phím hiển thị
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 16,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          _rateInfo != null && _rateInfo!['Rating'] != null
              ? 'Thông tin đánh giá'
              : 'Đánh giá phim',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
              bottom: 16.0), // Đệm dưới để tránh bị che khuất
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MovieHeader được cố định, không phụ thuộc vào state
              MovieHeader(movieId: widget.buyTicket.movieID),
              const SizedBox(height: 10),
              Divider(height: 1, color: basicColor, thickness: 1),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RatingStars(),
              ),
              const SizedBox(height: 10),
              // Hiển thị số sao đã chọn
              Obx(() {
                String caption = ''; // Khởi tạo biến caption

                // Dựa trên số sao chọn, xác định caption phù hợp
                if (ratingController.selectedStars.value >= 9) {
                  caption = 'Tuyệt vời';
                } else if (ratingController.selectedStars.value >= 6) {
                  caption = 'Tạm được';
                } else if (ratingController.selectedStars.value >= 5) {
                  caption = 'Khá thất vọng';
                } else if (ratingController.selectedStars.value >= 3) {
                  caption = 'Không hay';
                } else if (ratingController.selectedStars.value >= 0) {
                  caption = '';
                } else {
                  caption = 'Thất vọng';
                }

                return Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Đánh giá ',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Text(
                        '${ratingController.selectedStars.value}',
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        '/10 ',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 25,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        caption, // Hiển thị caption tương ứng với số sao
                        style:
                            const TextStyle(fontSize: 16, color: Colors.amber),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: basicColor, // Nền là basicColor
                    borderRadius: BorderRadius.circular(10), // Border radius 10
                    border: Border.all(
                        color: Colors.black, width: 1), // Viền màu đen
                  ),
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _noteController,
                    maxLines: 5, // Hiển thị 5 dòng văn bản
                    decoration: InputDecoration(
                      hintText:
                          "Chia sẻ cảm nghĩ của bạn sau khi xem phim tại rạp nhé!.",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border:
                          InputBorder.none, // Xóa viền mặc định của TextField
                    ),
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Rating stars
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent, // Màu của nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Bo tròn góc
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                  ),
                  onPressed: () async {
                    if (_rateInfo != null && _rateInfo!['Rating'] != null) {
                      Navigator.pop(context);
                    } else {
                      _insertRate(_noteController.text,
                          ratingController.selectedStars.value.toInt());
                      // Xử lý logic khi bấm nút
                    }
                  },
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Căn giữa theo chiều ngang
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.center, // Căn giữa văn bản
                          child: Text(
                            _rateInfo != null && _rateInfo!['Rating'] != null
                                ? 'Đóng'
                                : 'Gửi đánh giá',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class RatingController extends GetxController {
  var selectedStars =
      0.obs; // Số sao được chọn, sử dụng Rx để lắng nghe thay đổi

  void updateStars(int stars) {
    selectedStars.value = stars;
  }
}

class RatingStars extends StatelessWidget {
  const RatingStars({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RatingController ratingController = Get.find<RatingController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Màu nền trắng
          ),
          padding: const EdgeInsets.all(3), // Khoảng cách  bên trong Container
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hàng 1: 5 ngôi sao đầu tiên
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Obx(() {
                    return IconButton(
                      icon: Icon(
                        index < ratingController.selectedStars.value
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                      ),
                      onPressed: () {
                        ratingController.updateStars(index + 1);
                      },
                    );
                  });
                }),
              ),
              const SizedBox(height: 3), // Khoảng cách giữa 2 hàng
              // Hàng 2: 5 ngôi sao tiếp theo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Obx(() {
                    return IconButton(
                      icon: Icon(
                        index + 5 < ratingController.selectedStars.value
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                      ),
                      onPressed: () {
                        ratingController.updateStars(index + 6);
                      },
                    );
                  });
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MovieHeader extends StatefulWidget {
  final int movieId;

  const MovieHeader({super.key, required this.movieId});

  @override
  _MovieHeaderState createState() => _MovieHeaderState();
}

class _MovieHeaderState extends State<MovieHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  Future<MovieDetails?> _loadMovieDetails() async {
    return await _apiService.findByViewMovieID(
        widget.movieId, UserManager.instance.user?.userId ?? 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      padding: EdgeInsets.all(10),
      child: FutureBuilder<MovieDetails?>(
        future: _loadMovieDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Không có dữ liệu'));
          }

          final movieDetails = snapshot.data!;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 10),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Image.network(
                    '${movieDetails.posterUrl}',
                    width: 130,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      '${movieDetails.title}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      minFontSize: 18,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${movieDetails.genres}',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      child: Text(
                        '${movieDetails.age}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      alignment: Alignment.center,
                      child: Text(
                        'Được cộng đồng đánh giá tích cực!',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: RatingSection(
                              movieDetails:
                                  movieDetails), // Truyền dữ liệu vào đây
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class RatingSection extends StatelessWidget {
  final MovieDetails movieDetails;

  const RatingSection({Key? key, required this.movieDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double fontSize24 = screenWidth * 0.04; // Ví dụ: 6% chiều rộng màn hình
    double fontSize16 = screenWidth * 0.03;
    double fontSize12 = screenWidth * 0.02;

    return Container(
      child: BlocBuilder<FilmInfoBloc, FilmInfoBlocState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star,
                                    color: Colors.orange, size: fontSize24),
                                Text(
                                  '${movieDetails.averageRating}',
                                  style: TextStyle(
                                    fontSize: fontSize16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                Text(
                                  ' /10',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: fontSize16,
                                  ),
                                ),
                              ],
                            ),
                            AutoSizeText(
                              '(${movieDetails.reviewCount} đánh giá)',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: fontSize12,
                              ),
                              maxLines: 1,
                              minFontSize: 8,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: _buildRatingBar(movieDetails),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRatingBar(MovieDetails movieDetails) {
    int totalReviews = movieDetails.reviewCount;
    if (totalReviews == 0) {
      return Center(child: Text('No reviews yet.'));
    }

    return Column(
      children: [
        _buildRatingRow('9-10', movieDetails.rating9_10, totalReviews),
        _buildRatingRow('7-8', movieDetails.rating7_8, totalReviews),
        _buildRatingRow('5-6', movieDetails.rating5_6, totalReviews),
        _buildRatingRow('3-4', movieDetails.rating3_4, totalReviews),
        _buildRatingRow('1-2', movieDetails.rating1_2, totalReviews),
      ],
    );
  }

  Widget _buildRatingRow(String label, int count, int totalReviews) {
    double percentage = totalReviews > 0 ? count / totalReviews : 0;

    return Row(
      children: [
        SizedBox(
          width: 30,
          child: AutoSizeText(
            label,
            style: TextStyle(fontSize: 10, color: Colors.black),
            maxLines: 1,
            minFontSize: 8,
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
        SizedBox(width: 10),
        Text(
          '($count)',
          style: TextStyle(fontSize: 10, color: Colors.black),
        ),
      ],
    );
  }
}
