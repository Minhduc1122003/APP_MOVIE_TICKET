import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_movie_item.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/Shift_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/work_schedule_checkIn.dart';
import 'package:flutter_app_chat/pages/manager_page/book_ticket_staff_page/GridView_Card_FilmSapchieu.dart';
import 'package:flutter_app_chat/pages/manager_page/book_ticket_staff_page/film_sapchieu_staff.dart';
import 'package:flutter_app_chat/pages/manager_page/checkin_checkout_manager/bloc/timekeeping_bloc.dart';
import 'package:flutter_app_chat/pages/manager_page/checkin_checkout_manager/check_in_history_calendar.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class BookTicketStaffPage extends StatefulWidget {
  const BookTicketStaffPage();

  @override
  _BookTicketStaffPageState createState() => _BookTicketStaffPageState();
}

class _BookTicketStaffPageState extends State<BookTicketStaffPage> {
  final TextEditingController shiftController = TextEditingController();
  late ApiService _APIService;
  late Future<List<MovieDetails>> _moviesFuture;
  List<MovieDetails> _filteredMovies = [];
  List<MovieDetails> _allMovies = [];
  late Future<List<MovieDetails>> _filmSapChieu;

  Set<Marker> allMarkers = {};
  GoogleMapController? mapController;
  @override
  void initState() async {
    super.initState();

    _APIService = ApiService();
    _moviesFuture = _APIService.getMoviesDangChieu();
    _filmSapChieu = _APIService.getMoviesSapChieu();
    _moviesFuture.then((movies) {
      setState(() {
        _allMovies = movies; // Lưu toàn bộ phim
        _filteredMovies = movies; // Khởi tạo danh sách lọc
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined,
                color: Colors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Đặt vé',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search_outlined,
                  color: Colors.white, size: 20),
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(30.0),
            child: Container(
              height: 40,
              child: const TabBar(
                dividerHeight: 0,
                indicatorColor: Colors.blue,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.white,
                tabs: [
                  Tab(text: 'Phim đang chiếu'),
                  Tab(text: 'Phim sắp chiếu')
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: FutureBuilder<List<MovieDetails>>(
                        future: _moviesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                              child: Text(
                                'No movies available.',
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                          } else {
                            if (_filteredMovies.isEmpty) {
                              return Center(
                                  child: Text('Không tìm thấy phim.'));
                            } else {
                              return SizedBox(
                                height: MediaQuery.of(context)
                                    .size
                                    .height, // Set a specific height
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        3, // Số lượng cột trong một hàng
                                    mainAxisSpacing:
                                        10.0, // Khoảng cách giữa các mục theo chiều dọc
                                    crossAxisSpacing:
                                        10.0, // Khoảng cách giữa các mục theo chiều ngang
                                    childAspectRatio:
                                        0.65, // Tỷ lệ chiều cao / chiều rộng của mỗi item
                                  ),
                                  itemCount: _filteredMovies.length,
                                  itemBuilder: (context, index) {
                                    final movie = _filteredMovies[index];
                                    return GridviewCardFilmsapchieu(
                                      movieId: movie.movieId,
                                      title: movie.title,
                                      rating: movie.averageRating.toString(),
                                      ratingCount: movie.reviewCount.toString(),
                                      genre: movie.genres,
                                      cinema: movie.cinemaName,
                                      duration: movie.duration.toString(),
                                      releaseDate: movie.releaseDate.toString(),
                                      imageUrl: movie.posterUrl,
                                    );
                                  },
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: FilmSapchieuStaff(
                  filmSapChieu: [],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
