import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/auth/content_film_infomation.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/actor_model.dart';
import 'package:flutter_app_chat/models/rating_info_model.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/fim_info/bloc/film_info_Bloc.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/buyTicket_page.dart';
import 'package:flutter_app_chat/pages/login_page/login_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart'; // Import package

class FilmInformation extends StatefulWidget {
  final int movieId;
  final Function? onPopCallback; // Thêm callback

  const FilmInformation({super.key, required this.movieId, this.onPopCallback});

  @override
  State<FilmInformation> createState() => _FilmInformationState();
}

class _FilmInformationState extends State<FilmInformation>
    with
        AutomaticKeepAliveClientMixin<FilmInformation>,
        SingleTickerProviderStateMixin<FilmInformation> {
  late ApiService _APIService;

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
    _loadMovieDetails();
  }

  Future<MovieDetails?> _loadMovieDetails() async {
    return await _APIService.findByViewMovieID(
        widget.movieId, UserManager.instance.user?.userId ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Quan trọng cho AutomaticKeepAliveClientMixin
    return FutureBuilder<MovieDetails?>(
      future: _loadMovieDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final movie = snapshot.data;
          return BlocProvider(
            create: (context) => FilmInfoBloc()..add(LoadData(movie)),
            child: SafeArea(
              top: false,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: mainColor,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () {
                      // Kiểm tra nếu có callback, gọi callback rồi pop
                      if (widget.onPopCallback != null) {
                        widget.onPopCallback!(); // Gọi callback
                      }
                      Navigator.of(context).pop(); // Quay lại màn hình trước
                    },
                  ),
                  title: Text(
                    'Chi tiết phim',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  centerTitle: true,
                ),
                backgroundColor: Colors.white,
                body: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MovieHeader(),
                              MovieInfo(),
                              RatingSection(),
                              PlotSummary(),
                              CastAndCrew(movieId: widget.movieId),
                              Divider(
                                height: 1,
                                color: basicColor,
                                thickness: 1,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              UserRating(movieId: widget.movieId),
                              SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: BuyTicketButton(),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true; // Giữ trạng thái của trang
}

class MovieHeader extends StatefulWidget {
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: BlocBuilder<FilmInfoBloc, FilmInfoBlocState>(
        builder: (context, state) {
          if (state.movieDetails?.favourite == true) {
            _controller.forward(); // Hiển thị animation đầy đủ nếu đã thích
          } else {
            _controller.reverse();
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(15), // Bo góc cho viền và hình ảnh
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black, width: 10), // Viền cho hình ảnh
                    borderRadius: BorderRadius.circular(15), // Bo góc cho viền
                  ),
                  child: CachedNetworkImage(
                    imageUrl: '${state.movieDetails?.posterUrl}',
                    // Thêm fallback cho URL poster
                    width: 130,
                    height: 200,
                    fit: BoxFit.cover, // Điều chỉnh ảnh cho phù hợp với khung
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(), // Hiển thị vòng tròn khi đang tải
                    errorWidget: (context, url, error) => const Icon(Icons
                        .error), // Hiển thị icon lỗi nếu tải ảnh không thành công
                    fadeInDuration: const Duration(
                        seconds: 1), // Thời gian hiệu ứng fade-in
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      '${state.movieDetails?.title}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2, // Giới hạn số dòng hiển thị là 2
                      overflow: TextOverflow
                          .ellipsis, // Hiển thị "..." khi văn bản quá dài
                      minFontSize:
                          18, // Kích thước font tối thiểu khi tự động điều chỉnh
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${state.movieDetails?.genres} ',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      child: Text(
                        '${state.movieDetails?.age}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Phim được phổ biến đến người xem từ đủ ${state.movieDetails?.age} tuổi trở lên',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: ElevatedButton(
                              onPressed: state.favouriteLoading
                                  ? null
                                  : () {
                                      if (UserManager.instance.user?.userId ==
                                          null) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Bạn chưa đăng nhập!'),
                                              content: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'Bạn cần ',
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  context)
                                                              .style,
                                                    ),
                                                    const TextSpan(
                                                      text: 'đăng nhập',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0XFF6F3CD7),
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          ' để sử dụng tính năng này, bạn có muốn đăng nhập?',
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  context)
                                                              .style,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Đóng hộp thoại
                                                  },
                                                  child: const Text('Hủy',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    Navigator.push(
                                                      context,
                                                      SlideFromLeftPageRoute(
                                                          page: LoginPage(
                                                        isBack: true,
                                                      )),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Đăng Nhập',
                                                    style: TextStyle(
                                                      color: Color(0XFF6F3CD7),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        setState(() {
                                          isFavourite = !isFavourite;
                                          if (isFavourite) {
                                            _controller.forward();
                                          } else {
                                            _controller.reverse();
                                          }
                                        });

                                        context.read<FilmInfoBloc>().add(
                                            ClickFavourite(
                                                state.movieDetails,
                                                state.movieDetails!.movieId,
                                                UserManager
                                                    .instance.user!.userId));
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.only(
                                    top: 0, left: 0, right: 5, bottom: 0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Lottie.network(
                                        'https://lottie.host/e5a06743-9f9a-413a-a927-c7995c78aead/RX9Sv0FDU8.json',
                                        width:
                                            25, // Điều chỉnh kích thước Lottie vừa với nội dung
                                        height: 30,
                                        fit: BoxFit
                                            .cover, // Đảm bảo Lottie vừa khít với kích thước đã đặt
                                        controller: _controller,
                                      ),
                                      Text(
                                        state.movieDetails?.favourite == true
                                            ? 'Đã thích'
                                            : 'Thích',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color:
                                              state.movieDetails?.favourite ==
                                                      true
                                                  ? mainColor
                                                  : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8), // Khoảng cách giữa 2 nút
                        Expanded(
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigator.push(
                                //     context,
                                //     SlideFromRightPageRoute(
                                //         page: TrailerPage(
                                //             videoUrl: state
                                //                 .movieDetails!.trailerUrl)));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.only(
                                    top: 0, left: 5, right: 5, bottom: 0),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.movie, size: 14),
                                  SizedBox(width: 3),
                                  Text(
                                    'Trailer',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

class MovieInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
      child: BlocBuilder<FilmInfoBloc, FilmInfoBlocState>(
        builder: (context, state) {
          return Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoItem('Ngày khởi chiếu',
                        '${state.movieDetails?.releaseDate}'),
                  ],
                ),
              ),
              Container(
                color: Colors.black, // Màu của đường kẻ
                width: 1, // Độ dày của đường kẻ
                height: 50, // Chiều cao của đường kẻ
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoItem(
                        'Thời lượng', '${state.movieDetails?.duration} phút'),
                  ],
                ),
              ),
              Container(
                color: Colors.black,
                width: 1,
                height: 50,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoItem(
                        'Ngôn ngữ',
                        '${state.movieDetails?.voiceover == true ? 'Lồng tiếng' : ''}',
                        '${state.movieDetails?.subTitle == true ? 'Phụ Đề' : ''}'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(String title, [String? value, String? value3]) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.center, // Căn giữa theo chiều ngang cho Column
      children: [
        Align(
          alignment: Alignment.center, // Cố định vị trí của title
          child: Text(
            title,
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 5),
        if (value != null &&
            value.isNotEmpty) // Kiểm tra giá trị value có tồn tại và không rỗng
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        if (value3 != null &&
            value3
                .isNotEmpty) // Kiểm tra giá trị value3 có tồn tại và không rỗng
          Text(
            value3,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

class RatingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
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
                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: Row(
                    children: [
                      // Phần tử chiếm 40% chiều rộng
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.orange, size: 30),
                                Text('${state.movieDetails?.averageRating}',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange)),
                                const Text(' /10',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16)),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(
                                '(${state.movieDetails?.reviewCount} đánh giá)',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 12)),
                          ],
                        ),
                      ),
                      // Phần tử chiếm 60% chiều rộng
                      Expanded(
                        flex: 6,
                        child:
                            _buildRatingBar(), // Thay thế bằng widget của bạn
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildRatingBar() {
    return BlocBuilder<FilmInfoBloc, FilmInfoBlocState>(
      builder: (context, state) {
        final movieDetails = state.movieDetails;
        if (movieDetails == null) {
          return Center(child: CircularProgressIndicator());
        }

        int totalReviews = movieDetails.reviewCount;
        if (totalReviews == 0) {
          // Handle the case where there are no reviews
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
      },
    );
  }

  Widget _buildRatingRow(String label, int count, int totalReviews) {
    double percentage = totalReviews > 0 ? count / totalReviews : 0;

    return Row(
      children: [
        SizedBox(
          width: 40,
          child:
              Text(label, style: TextStyle(fontSize: 12, color: Colors.black)),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
        SizedBox(width: 10), // Khoảng cách giữa thanh và số lượng
        Text(
          '($count)', // Hiển thị số lượng đánh giá
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }
}

class PlotSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocBuilder<FilmInfoBloc, FilmInfoBlocState>(
        builder: (context, state) {
          if (state.movieDetails == null) {
            return Center(child: CircularProgressIndicator());
          }

          final description = state.movieDetails!.description;
          final title = 'Nội dung phim'; // Title for the card

          return ExpandableInfoCard(
            title: title,
            content: description,
            isExpandedInitially:
                false, // You can set this to false if you want the card to be collapsed initially
          );
        },
      ),
    );
  }
}

class CastAndCrew extends StatelessWidget {
  final ApiService _apiService = ApiService();
  final int movieId; // Thêm tham số movieId

  CastAndCrew({required this.movieId}); // Constructor với movieId

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đạo diễn & Diễn viên',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          FutureBuilder<List<Actor>>(
            future: _apiService.getActor(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('Không có dữ liệu diễn viên');
              }

              // Lọc danh sách actor theo movieId
              final actorsInMovie = snapshot.data!
                  .where((actor) => actor.movieId == movieId)
                  .toList();

              if (actorsInMovie.isEmpty) {
                return Text('Không có dữ liệu diễn viên cho phim này');
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: actorsInMovie.map((actor) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: _buildActorItem(
                        'assets/images/combo1.png', // Lấy ảnh từ assets
                        actor.name,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActorItem(String imagePath, String name) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/default_avatar.jpg',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class UserRating extends StatelessWidget {
  final ApiService _apiService = ApiService();
  final int movieId;

  UserRating({required this.movieId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Đánh giá từ cộng đồng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          FutureBuilder<List<RatingInfoModel>>(
            future: _apiService.getAllRateInfoByMovieID(movieId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Không có bài đánh giá nào!');
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('Không có bài đánh giá nào!');
              }

              // Dùng Column để hiển thị tất cả các item
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(snapshot.data!.length, (index) {
                  final rating = snapshot.data![index];
                  return Column(
                    children: [
                      _buildRatingItem(rating),
                      if (index < snapshot.data!.length - 1)
                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 2,
                        ),
                    ],
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  // Hàm để xây dựng mỗi item đánh giá
  Widget _buildRatingItem(RatingInfoModel rating) {
    if (rating.reviewContent.isEmpty) {
      return SizedBox.shrink(); // Trả về một widget rỗng
    }
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar người dùng (ảnh tròn)
          Container(
            height: 40,
            width: 40,
            child: CircleAvatar(
              radius: 10,
              backgroundImage: rating.avatar != null
                  ? NetworkImage(rating.avatar!)
                  : AssetImage('assets/images/profile.png'),
            ),
          ),
          SizedBox(width: 12), // Khoảng cách giữa avatar và nội dung
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên người dùng
                Row(
                  children: [
                    Text(
                      rating.name,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '    ${formatRatingDate(rating.ratingDate)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                // Nội dung đánh giá
                ExpandableText(reviewContent: rating.reviewContent),

                SizedBox(height: 4),
                // Xếp hạng của người dùng
                Row(
                  children: [
                    Text(
                      'Đánh giá: ',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${rating.rating}',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '/10',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String reviewContent;
  ExpandableText({required this.reviewContent});

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Kiểm tra độ dài của reviewContent và cắt bớt sau 4 dòng
    String text = widget.reviewContent;
    if (!_isExpanded && text.length > 200) {
      // Số ký tự có thể thay đổi tùy vào font size và độ dài dòng
      text = text.substring(0, 200) + '...';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 12),
        ),
        if (widget.reviewContent.length >
            200) // Nếu văn bản dài hơn 200 ký tự, hiển thị 'Xem thêm'
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Thu gọn' : 'Xem thêm',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),
      ],
    );
  }
}

String formatRatingDate(DateTime ratingDate) {
  // Định dạng lại thành "HH:mm - dd.MM.yyyy"
  return DateFormat('HH:mm • dd/MM').format(ratingDate);
}

class BuyTicketButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: BlocBuilder<FilmInfoBloc, FilmInfoBlocState>(
        builder: (context, state) {
          return MyButton(
            fontsize: 14,
            paddingText: 10,
            text: 'Đặt vé ngay',
            onTap: () => Navigator.push(
              context,
              SlideFromRightPageRoute(
                page: BuyTicketPage(
                  movieId: state.movieDetails!.movieId,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
