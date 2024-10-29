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
  late ApiService _apiService;
  late Future<List<MovieDetails>> _moviesDangChieuFuture;
  late Future<List<MovieDetails>> _moviesSapChieuFuture;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _moviesDangChieuFuture = _apiService.getMoviesDangChieu();
    _moviesSapChieuFuture = _apiService.getMoviesSapChieu();
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
          children: [
            // Phim đang chiếu tab
            buildMovieGridView(_moviesDangChieuFuture),
            // Phim sắp chiếu tab
            FutureBuilder<List<MovieDetails>>(
              future: _moviesSapChieuFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No movies available.'));
                } else {
                  return FilmSapchieuStaff(filmSapChieu: snapshot.data!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMovieGridView(Future<List<MovieDetails>> future) {
    return FutureBuilder<List<MovieDetails>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No movies available.'));
        } else {
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 0.65,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final movie = snapshot.data![index];
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
          );
        }
      },
    );
  }
}
