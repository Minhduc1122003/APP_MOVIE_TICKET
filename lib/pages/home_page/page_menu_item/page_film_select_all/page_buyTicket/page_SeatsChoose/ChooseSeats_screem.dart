import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/Chair_modal.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/page_SeatsChoose/cinema_seat_grid.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/page_SeatsChoose/page_billTicket/bill_Ticket_Screen.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/page_SeatsChoose/page_detail/detail_invoice.dart';
import 'package:flutter_app_chat/pages/login_page/login_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

class ChooseseatsPage extends StatefulWidget {
  final int movieID;
  final int cinemaRoomID;
  final int showTimeID;
  final String showtimeDate;
  final String startTime;
  final String endTime;

  const ChooseseatsPage({
    Key? key,
    required this.movieID,
    required this.cinemaRoomID,
    required this.showTimeID,
    required this.showtimeDate,
    required this.startTime,
    required this.endTime,
  }) : super(key: key);

  @override
  _ChooseseatsPageState createState() => _ChooseseatsPageState();
}

class _ChooseseatsPageState extends State<ChooseseatsPage>
    with AutomaticKeepAliveClientMixin {
  late ApiService _apiService;
  late List<ChairModel> _chairs = [];
  MovieDetails? _movieDetails; // New variable for movie details
  late int selectedCount = 0; // This will track the number of selected seats
  List<Map<String, dynamic>> selectedChairsInfo =
      []; // List to store selected chair info
  List<int> seatIDList = [];
  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadChairs();
    _loadMovieDetails();
  }

  Future<void> _loadChairs() async {
    try {
      _chairs = await _apiService.getChairList(
        widget.cinemaRoomID,
        widget.showTimeID,
      );
      if (_chairs.isNotEmpty) {
        print('Đã tìm thấy ghế!');
        setState(() {});
      } else {
        print('Không tìm thấy ghế nào.');
      }
    } catch (e) {
      print('Lỗi khi tải ghế: $e');
    }
  }

  Future<void> _loadMovieDetails() async {
    try {
      _movieDetails = await _apiService.findByViewMovieID(
          widget.movieID, UserManager.instance.user?.userId ?? 0);
      if (_movieDetails != null) {
        print('Đã tìm thấy chi tiết phim!');
        setState(() {}); // Ensure the UI updates when movie details are loaded
      } else {
        print('Không tìm thấy chi tiết phim.');
      }
    } catch (e) {
      print('Lỗi khi tải chi tiết phim: $e');
    }
  }

  String formatPrice(double price) {
    final formatter = NumberFormat('#,###');
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      top: false,
      child: Scaffold(
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
          title: const Text(
            'Trung Tâm Đặt Vé',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: _movieDetails == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 40,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: CustomPaint(
                                    size: const Size(double.infinity, 40),
                                    painter: CurvedLinePainter(),
                                  ),
                                ),
                                const Text(
                                  'MÀN HÌNH',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  child: Center(
                                    child: InteractiveViewer(
                                      boundaryMargin:
                                          const EdgeInsets.all(80.0),
                                      minScale: 0.01,
                                      maxScale: 4.0,
                                      child: CinemaSeatGrid(
                                        chairs: _chairs,
                                        onCountChanged: (int change) {
                                          setState(() {
                                            selectedCount +=
                                                change; // Update selectedCount based on change
                                          });
                                        },
                                        // Update the onChairSelected callback to handle selection/deselection
                                        onChairSelected: (chairId, chairCode) {
                                          if (chairId == 0) {
                                            // Nếu ghế bị bỏ chọn (id = 0), xóa nó khỏi danh sách
                                            selectedChairsInfo.removeWhere(
                                                (chair) =>
                                                    chair['id'] == chairId);
                                            seatIDList.remove(
                                                chairId); // Xóa ID khỏi seatIDList
                                          } else {
                                            // Kiểm tra nếu ghế đã được chọn trước đó
                                            if (selectedChairsInfo.any(
                                                (chair) =>
                                                    chair['id'] == chairId)) {
                                              // Nếu ghế đã được chọn, bỏ chọn nó
                                              selectedChairsInfo.removeWhere(
                                                  (chair) =>
                                                      chair['id'] == chairId);
                                              seatIDList.remove(
                                                  chairId); // Xóa ID khỏi seatIDList
                                            } else {
                                              // Nếu ghế chưa được chọn, thêm nó vào danh sách
                                              selectedChairsInfo.add({
                                                'id': chairId,
                                                'code': chairCode,
                                              });
                                              seatIDList.add(
                                                  chairId); // Thêm ID vào seatIDList
                                            }
                                          }
                                          // Ghi log thông tin ghế đã chọn
                                          for (var chair
                                              in selectedChairsInfo) {
                                            print('id: ${chair['id']}');
                                          }
                                          // Ghi log seatIDList để xem cập nhật
                                          print(
                                              'Selected seat IDs: $seatIDList');
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const Divider(
                                  height: 0,
                                  thickness: 2,
                                  color: Color(0xfff0f0f0),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildLegendItem(mainColor, 'Ghế trống',
                                        isEmpty: true),
                                    _buildLegendItem(mainColor, 'Ghế bạn chọn'),
                                    _buildLegendItem(Colors.red, 'Đã đặt'),
                                  ],
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Các phần tử nằm ở đáy
                  const Divider(
                    height: 0,
                    thickness: 6,
                    color: Color(0xfff0f0f0),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            _movieDetails!.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            minFontSize: 14,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0, 5, 0),
                          child: Align(
                              alignment: Alignment
                                  .topRight, // Căn giữa ở phía trên bên phải
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: const BoxDecoration(
                                      color: mainColor,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                    ),
                                    child: const Text(
                                      'Đổi suất',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ))),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Text(
                          _movieDetails!.age,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildInfoItem(
                                '', '${widget.startTime} ~ ${widget.endTime}'),
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
                                'Thời lượng', '${widget.showtimeDate}'),
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
                                _movieDetails!.voiceover ? 'Lồng Tiếng' : '',
                                _movieDetails!.subTitle ? 'Phụ Đề' : ''),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: AutoSizeText(
                            'Tạm tính',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            minFontSize: 14,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 0, 5, 0),
                          child: AutoSizeText(
                            _movieDetails != null && selectedCount > 0
                                ? '${formatPrice(_movieDetails!.price! * selectedCount)} VND'
                                : _movieDetails != null
                                    ? '0 VND' // Display 0 VND when no chairs are selected
                                    : 'Đang tải...',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            minFontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: MyButton(
                      fontsize: 20,
                      paddingText: 10,
                      text: 'Đặt vé ngay',
                      isBold: true,
                      onTap: () {
                        // Kiểm tra người dùng đã đăng nhập chưa
                        if (UserManager.instance.user?.userId == null) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Bạn chưa đăng nhập!'),
                                content: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Bạn cần ',
                                        style:
                                            DefaultTextStyle.of(context).style,
                                      ),
                                      const TextSpan(
                                        text: 'đăng nhập',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0XFF6F3CD7),
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            ' để sử dụng tính năng này, bạn có muốn đăng nhập?',
                                        style:
                                            DefaultTextStyle.of(context).style,
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
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      EasyLoading.show();
                                      await Future.delayed(
                                          const Duration(milliseconds: 200));
                                      EasyLoading.dismiss();
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          Navigator.push(
                            context,
                            SlideFromRightPageRoute(
                                page: DetailInvoice(
                              movieID: widget.movieID,
                              quantity: selectedCount,
                              sumPrice: (_movieDetails!.price! * selectedCount),
                              showTimeID: widget.showTimeID,
                              seatCodes: seatIDList,
                            )),
                          );

                          // Navigator.push(
                          //   context,
                          //   SlideFromRightPageRoute(
                          //     page: BillTicketScreen(
                          //         movieID: widget.movieID,
                          //         quantity: selectedCount,
                          //         sumPrice:
                          //             (_movieDetails!.price! * selectedCount),
                          //         showTimeID: widget.showTimeID,
                          //         seatCodes: seatIDList),
                          //   ),
                          // );
                        }
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Widget _buildInfoItem(String title, [String? value, String? value3]) {
  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.center, // Căn giữa theo chiều ngang cho Column
    children: [
      if (value != null &&
          value.isNotEmpty) // Kiểm tra giá trị value có tồn tại và không rỗng
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      if (value3 != null &&
          value3.isNotEmpty) // Kiểm tra giá trị value3 có tồn tại và không rỗng
        Text(
          value3,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
    ],
  );
}

Widget _buildLegendItem(Color color, String label, {bool isEmpty = false}) {
  return Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: isEmpty ? Colors.white : color, // Set color based on isEmpty
          border: isEmpty
              ? Border.all(color: mainColor, width: 1) // Border for empty
              : null, // No border if not empty
          borderRadius:
              BorderRadius.circular(isEmpty ? 4 : 2), // Radius based on isEmpty
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}

class CurvedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    var path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    canvas.drawPath(path, shadowPaint);

    var paint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
