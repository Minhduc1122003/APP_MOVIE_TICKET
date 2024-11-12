import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/Chair_modal.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/page_SeatsChoose/page_billTicket/bill_Ticket_Screen.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/page_SeatsChoose/page_combo_Ticket/combo_model.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:intl/intl.dart';

class ComboTicketScreen extends StatefulWidget {
  final int movieID;
  final int cinemaRoomID;
  final int showTimeID;
  final String showtimeDate;
  final String startTime;
  final String endTime;
  final List<Map<String, dynamic>> seatCodes;
  final int quantity;
  final double ticketPrice;

  const ComboTicketScreen({
    Key? key,
    required this.movieID,
    required this.cinemaRoomID,
    required this.showTimeID,
    required this.showtimeDate,
    required this.startTime,
    required this.endTime,
    required this.quantity,
    required this.ticketPrice,
    required this.seatCodes,
  }) : super(key: key);

  @override
  _ComboTicketScreenState createState() => _ComboTicketScreenState();
}

class _ComboTicketScreenState extends State<ComboTicketScreen>
    with AutomaticKeepAliveClientMixin {
  late ApiService _apiService;
  late List<ChairModel> _chairs = [];
  MovieDetails? _movieDetails; // New variable for movie details
  late int selectedCount = 0; // This will track the number of selected seats
  List<Map<String, dynamic>> selectedChairsInfo =
      []; // List to store selected chair info
  List<int> seatIDList = [];
  List<Combo> comboItems = [];
  List<Combo> nonComboItems = [];
  Map<int, int> itemCounts = {};
  late final int quantityCombo = 0;
  late final int totalComboPrice = 0;
  final List<Map<String, dynamic>> infoCombo = [];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadChairs();
    _loadMovieDetails();
    _loadComboItems(); // Add this
  }

  bool hasSelectedItems() {
    return itemCounts.values.any((count) => count > 0);
  }

  Future<void> _loadComboItems() async {
    try {
      final combos = await _apiService.getAllIsCombo();
      final nonCombos = await _apiService.getAllIsNotCombo();
      setState(() {
        comboItems = combos;
        nonComboItems = nonCombos;
      });
    } catch (e) {
      print('Error loading combo items: $e');
    }
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
            'Combo Vé',
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
                          DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                TabBar(
                                  tabs: [
                                    Tab(text: 'Combo'),
                                    Tab(text: 'Bán lẻ'),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      430, // Set a fixed height for the TabBarView
                                  child: TabBarView(
                                    children: [
                                      // Combo tab content
                                      comboItems.isEmpty
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : ListView.builder(
                                              itemCount: comboItems.length,
                                              itemBuilder: (context, index) {
                                                final combo = comboItems[index];
                                                return _buildComboItem(
                                                  combo.title,
                                                  combo.subtitle,
                                                  formatPrice(combo.price) +
                                                      ' VND',
                                                  combo.image,
                                                  itemId: combo
                                                      .comboId, // Sử dụng comboId thay vì id
                                                );
                                              },
                                            ),
                                      // Bán lẻ tab content
                                      nonComboItems.isEmpty
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : ListView.builder(
                                              itemCount: nonComboItems.length,
                                              itemBuilder: (context, index) {
                                                final item =
                                                    nonComboItems[index];
                                                return _buildSingleItem(
                                                  item.title,
                                                  item.subtitle,
                                                  formatPrice(item.price) +
                                                      ' VND',
                                                  item.image,
                                                  itemId: item.comboId,
                                                );
                                              },
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom elements
                  const Divider(
                    height: 0,
                    thickness: 6,
                    color: Color(0xfff0f0f0),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
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
                  // Row 1: Tiền vé
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: AutoSizeText(
                            'Tiền vé',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 0, 5, 0),
                          child: AutoSizeText(
                            // Chỉ lấy giá tiền vé
                            formatPrice(widget.ticketPrice) + ' VND',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

// Row 2: Tiền combo
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: AutoSizeText(
                            'Tiền combo',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 0, 5, 0),
                          child: AutoSizeText(
                            // Chỉ lấy tổng giá tiền combo
                            formatPrice(
                                    itemCounts.entries.fold(0.0, (sum, entry) {
                                  final item = [...comboItems, ...nonComboItems]
                                      .firstWhere(
                                          (item) => item.comboId == entry.key);
                                  return sum + (item.price * entry.value);
                                })) +
                                ' VND',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 0,
                    thickness: 3,
                    color: Color(0xfff0f0f0),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
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
                            // Tính tổng giá trị combo và cộng với widget.sumPrice
                            formatPrice(widget.ticketPrice +
                                    itemCounts.entries.fold(0.0, (sum, entry) {
                                      final item = [
                                        ...comboItems,
                                        ...nonComboItems
                                      ].firstWhere(
                                          (item) => item.comboId == entry.key);
                                      return sum + (item.price * entry.value);
                                    })) +
                                'VND',
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
                  _buildBottomButtons(),
                ],
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: hasSelectedItems()
          ? Row(
              children: [
                SizedBox(
                  width: 100, // Khoảng 1/3 của nút tiếp tục
                  child: MyButton(
                    text: '', // Để trống vì chỉ muốn hiển thị icon
                    fontsize: 20,
                    paddingText: 10,
                    showIcon: true, // Hiển thị icon
                    isBold: true,
                    onTap: () {
                      _showCartItems();
                    },
                  ),
                ),
                SizedBox(width: 10), // Khoảng cách giữa 2 nút
                // Nút tiếp tục
                Expanded(
                  child: MyButton(
                    fontsize: 20,
                    paddingText: 10,
                    text: 'Tiếp tục',
                    isBold: true,
                    onTap: () {
                      infoCombo.clear();
// In ra danh sách combo đã chọn
                      print('Danh sách combo đã chọn:');
                      itemCounts.forEach((comboId, quantity) {
                        // Tìm item trong danh sách comboItems và nonComboItems
                        final item = [...comboItems, ...nonComboItems]
                            .firstWhere((item) => item.comboId == comboId);

                        // In ra tên combo và số lượng
                        print('${item.title} - Số lượng: $quantity');

                        // Thêm thông tin combo vào infoCombo
                        infoCombo.add({
                          'comboId': comboId,
                          'title': item.title,
                          'quantity': quantity,
                        });
                      });

                      // Tính tổng tiền combo
                      double totalComboPrice =
                          itemCounts.entries.fold(0.0, (sum, entry) {
                        final item = [...comboItems, ...nonComboItems]
                            .firstWhere((item) => item.comboId == entry.key);
                        return sum + (item.price * entry.value);
                      });

                      Navigator.push(
                        context,
                        SlideFromRightPageRoute(
                          page: BillTicketScreen(
                            movieID: widget.movieID,
                            quantity: widget.quantity,
                            ticketPrice: widget.ticketPrice,
                            showTimeID: widget.showTimeID,
                            seatCodes: widget.seatCodes,
                            showtimeDate: widget.showtimeDate,
                            startTime: widget.startTime,
                            endTime: widget.endTime,
                            cinemaRoomID: widget.cinemaRoomID,
                            quantityCombo: itemCounts.values
                                .fold(0, (sum, count) => sum + count),
                            totalComboPrice: totalComboPrice,
                            titleCombo: infoCombo,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : MyButton(
              fontsize: 20,
              paddingText: 10,
              text: 'Tiếp tục',
              isBold: true,
              onTap: () {
                infoCombo.clear();
// In ra danh sách combo đã chọn
                print('Danh sách combo đã chọn:');
                itemCounts.forEach((comboId, quantity) {
                  // Tìm item trong danh sách comboItems và nonComboItems
                  final item = [...comboItems, ...nonComboItems]
                      .firstWhere((item) => item.comboId == comboId);

                  // In ra tên combo và số lượng
                  print('${item.title} - Số lượng: $quantity');

                  // Thêm thông tin combo vào infoCombo
                  infoCombo.add({
                    'comboId': comboId,
                    'title': item.title,
                    'quantity': quantity,
                  });
                });

                // Tính tổng tiền combo
                double totalComboPrice =
                    itemCounts.entries.fold(0.0, (sum, entry) {
                  final item = [...comboItems, ...nonComboItems]
                      .firstWhere((item) => item.comboId == entry.key);
                  return sum + (item.price * entry.value);
                });
                print('Tổng tiền combo: ${formatPrice(totalComboPrice)} VND');
                print('Tổng tiền vé: ${formatPrice(widget.ticketPrice)} VND');
                print(
                    'Tổng cộng: ${formatPrice(widget.ticketPrice + totalComboPrice)} VND');

                // Chuyển đến màn hình BillTicketScreen
                Navigator.push(
                  context,
                  SlideFromRightPageRoute(
                    page: BillTicketScreen(
                      movieID: widget.movieID,
                      quantity: widget.quantity,
                      ticketPrice: widget.ticketPrice,
                      showTimeID: widget.showTimeID,
                      seatCodes: widget.seatCodes,
                      showtimeDate: widget.showtimeDate,
                      startTime: widget.startTime,
                      endTime: widget.endTime,
                      cinemaRoomID: widget.cinemaRoomID,
                      quantityCombo: itemCounts.values
                          .fold(0, (sum, count) => sum + count),
                      totalComboPrice: totalComboPrice,
                      titleCombo: infoCombo,
                    ),
                  ),
                );
              },
            ),
    );
  }

// Method để hiển thị modal bottom sheet chứa các items trong giỏ hàng
  void _showCartItems() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            double totalPrice = itemCounts.entries.fold(0, (sum, entry) {
              final item = [...comboItems, ...nonComboItems]
                  .firstWhere((item) => item.comboId == entry.key);
              return sum + (item.price * entry.value);
            });

            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Danh sách đã chọn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Existing content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (itemCounts.keys.any((key) => comboItems
                              .any((combo) => combo.comboId == key))) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Text(
                                    'Combo',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: mainColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildItemsListWithState(true, setModalState),
                          ],
                          if (itemCounts.keys.any((key) => nonComboItems
                              .any((item) => item.comboId == key))) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Text(
                                    'Sản phẩm bán lẻ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: mainColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildItemsListWithState(false, setModalState),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tổng số lượng:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Tổng tiền:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${itemCounts.values.fold(0, (sum, count) => sum + count)} sản phẩm',
                                  style: TextStyle(
                                    color: mainColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '${formatPrice(totalPrice)} VND',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildItemsListWithState(bool isCombo, StateSetter setModalState) {
    final filteredItems = itemCounts.entries.where((entry) {
      final item = [...comboItems, ...nonComboItems]
          .firstWhere((item) => item.comboId == entry.key);
      return isCombo == comboItems.any((combo) => combo.comboId == entry.key);
    }).toList();

    return Column(
      children: filteredItems.map((entry) {
        final item = [...comboItems, ...nonComboItems]
            .firstWhere((item) => item.comboId == entry.key);

        return Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${formatPrice(item.price)} VND',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: mainColor, size: 20),
                    onPressed: () {
                      setState(() {
                        itemCounts[entry.key] =
                            (itemCounts[entry.key] ?? 0) - 1;
                        if (itemCounts[entry.key]! <= 0) {
                          itemCounts.remove(entry.key);
                        }
                      });
                      setModalState(() {});
                    },
                    constraints: BoxConstraints(
                      minWidth: 25,
                      minHeight: 25,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  Container(
                    constraints: BoxConstraints(minWidth: 32),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: mainColor),
                        right: BorderSide(color: mainColor),
                      ),
                    ),
                    child: Text(
                      entry.value.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: mainColor, size: 20),
                    onPressed: () {
                      setState(() {
                        itemCounts[entry.key] =
                            (itemCounts[entry.key] ?? 0) + 1;
                      });
                      setModalState(() {});
                    },
                    constraints: BoxConstraints(
                      minWidth: 25,
                      minHeight: 25,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  // Nút xóa cho từng mục
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () {
                      setState(() {
                        itemCounts.remove(entry.key);
                      });
                      setModalState(() {});
                    },
                    constraints: BoxConstraints(
                      minWidth: 25,
                      minHeight: 25,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComboItem(
      String title, String description, String price, String imagePath,
      {required int itemId}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(
              width: 100,
              height: 120,
              child: Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/combo1.png');
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(description),
                  Text(price, style: TextStyle(color: Colors.red)),
                  itemCounts[itemId] == null || itemCounts[itemId] == 0
                      ? ElevatedButton(
                          child: Text('Thêm'),
                          onPressed: () {
                            setState(() {
                              itemCounts[itemId] = 1;
                            });
                          },
                        )
                      : Row(
                          children: [
                            IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    itemCounts[itemId] =
                                        (itemCounts[itemId] ?? 0) - 1;
                                    if (itemCounts[itemId]! <= 0) {
                                      itemCounts.remove(itemId);
                                    }
                                  });
                                }),
                            Text('${itemCounts[itemId] ?? 0}'),
                            IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    itemCounts[itemId] =
                                        (itemCounts[itemId] ?? 0) + 1;
                                  });
                                }),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleItem(
      String title, String description, String price, String imagePath,
      {required int itemId}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(
              width: 100,
              height: 120,
              child: Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/combo1.png');
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(description),
                  Text(price, style: TextStyle(color: Colors.red)),
                  itemCounts[itemId] == null || itemCounts[itemId] == 0
                      ? ElevatedButton(
                          child: Text('Thêm'),
                          onPressed: () {
                            setState(() {
                              itemCounts[itemId] = 1;
                            });
                          },
                        )
                      : Row(
                          children: [
                            IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    itemCounts[itemId] =
                                        (itemCounts[itemId] ?? 0) - 1;
                                    if (itemCounts[itemId]! <= 0) {
                                      itemCounts.remove(itemId);
                                    }
                                  });
                                }),
                            Text('${itemCounts[itemId] ?? 0}'),
                            IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    itemCounts[itemId] =
                                        (itemCounts[itemId] ?? 0) + 1;
                                  });
                                }),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

String formatPrice(double price) {
  final formatter = NumberFormat('#,###');
  return formatter.format(price);
}
