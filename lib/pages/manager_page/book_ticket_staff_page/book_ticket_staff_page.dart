import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/models/Shift_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/work_schedule_checkIn.dart';
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

  Set<Marker> allMarkers = {};
  GoogleMapController? mapController;
  @override
  void initState() {
    super.initState();

    _APIService = ApiService();
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
            const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: Text('Hello'),
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
                child: FilmSapchieuStaff(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
