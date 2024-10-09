import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/models/Chair_modal.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:flutter_app_chat/models/user_manager.dart';

class BillTicketScreen extends StatefulWidget {
  final int movieID;
  final int quantity;
  final double sumPrice;
  final int showTimeID;
  final List<int> seatCodes; // Thêm thuộc tính chứa danh sách ghế

  const BillTicketScreen({
    Key? key,
    required this.movieID,
    required this.quantity,
    required this.sumPrice,
    required this.showTimeID,
    required this.seatCodes, // Nhận danh sách ghế từ constructor
  }) : super(key: key);

  @override
  _BillTicketScreenState createState() => _BillTicketScreenState();
}

class _BillTicketScreenState extends State<BillTicketScreen>
    with AutomaticKeepAliveClientMixin {
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    // Gọi API sau khi khởi tạo
    _insertBuyTicket();
  }

  Future<void> _insertBuyTicket() async {
    try {
      // Cộng các chuỗi từ userId, quantity, showTimeID
      String combinedString = UserManager.instance.user!.userId.toString() +
          widget.quantity.toString() +
          widget.showTimeID.toString();

      String firstSeatCode =
          widget.seatCodes.isNotEmpty ? widget.seatCodes[0].toString() : '';

      combinedString += firstSeatCode;

      int finalResult;
      try {
        finalResult = int.parse(combinedString);
        print("finalResult: $finalResult");
      } catch (e) {
        print("Error: $e");
        finalResult = 0; // Hoặc một giá trị mặc định khác
      }

// Gọi hàm insertBuyTicket với finalResult
      final response = await _apiService.insertBuyTicket(
        finalResult, // Sử dụng finalResult đã chuyển đổi
        '${UserManager.instance.user?.userId}',
        widget.movieID,
        widget.quantity,
        widget.sumPrice.toDouble(),
        widget.showTimeID,
        widget.seatCodes,
      );

      // Xử lý phản hồi
      if (response != null) {
        // Có thể hiển thị thông báo hoặc thực hiện hành động nào đó với dữ liệu nhận được
        print("Thành công: $response");
      } else {
        print("Không nhận được dữ liệu từ API");
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0XFF6F3CD7),
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
      body: Center(
        child: Text('đã clear'),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
