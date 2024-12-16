import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/pages/manager_page/scan_code_manager/QRinfoTicket_page.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQrcode extends StatefulWidget {
  const ScanQrcode({super.key});

  @override
  _ScanQrcodeState createState() => _ScanQrcodeState();
}

class _ScanQrcodeState extends State<ScanQrcode>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String result = "";
  TextEditingController _idTicket = TextEditingController();
  late int QRScan = 0;
  late List<String> scannedCodes = [];

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      if (Platform.isAndroid) {
        controller!.pauseCamera();
      }
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F75FF),
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
          'Quét mã',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.all(5),
                color: Colors.orange,
                child: const Text(
                  'Đưa QR vào khung để check vé !',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 250, // Adjust the width as needed
              height: 250, // Adjust the height as needed
              child: Stack(
                children: [
                  // Top-left corner
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Colors.white.withOpacity(0.8), width: 3.0),
                          left: BorderSide(
                              color: Colors.white.withOpacity(0.8), width: 3.0),
                        ),
                      ),
                    ),
                  ),
                  // Top-right corner
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: Colors.white.withOpacity(0.8), width: 3.0),
                          right: BorderSide(
                              color: Colors.white.withOpacity(0.8), width: 3.0),
                        ),
                      ),
                    ),
                  ),
                  // Bottom-left corner
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Colors.white.withOpacity(0.8), width: 3.0),
                          left: BorderSide(
                              color: Colors.white.withOpacity(0.8), width: 3.0),
                        ),
                      ),
                    ),
                  ),
                  // Bottom-right corner
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Colors.white.withOpacity(0.8), width: 3.0),
                          right: BorderSide(
                              color: Colors.white.withOpacity(0.8), width: 3.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              result,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () => _showQRModal(context), // Hàm mở modal

                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Icon(
                        Icons.camera_alt,
                        color: Color(0xFF6439FF),
                      ),
                    ),
                    Text(
                      'Quét mã QR',
                      style: TextStyle(
                        color: Color(0xFF6439FF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQRModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Để modal không bị giới hạn kích thước
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context)
              .viewInsets, // Đẩy modal lên khi mở bàn phím
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Để modal vừa khít nội dung
              children: [
                const Text(
                  'Nhập mã hóa đơn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _idTicket,
                  decoration: InputDecoration(
                    labelText: 'Mã hóa đơn',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                MyButton(
                  text: "Kiểm tra",
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      SlideFromRightPageRoute(
                        page: QrinfoticketPage(
                          buyTicketID: _idTicket.text,
                        ),
                      ),
                    );
                    if (result == 'Không tồn tại') {
                      EasyLoading.showError('Lỗi không tìm thấy vé');
                    }
                  },
                  fontsize: 16,
                  paddingText: 10,
                )
              ],
            ),
          ),
        );
      },
    );
  }

// Danh sách lưu các mã đã quét

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null && QRScan == 0) {
        final scannedCode = scanData.code!;

        // Kiểm tra nếu mã đã tồn tại trong danh sách
        if (scannedCodes.contains(scannedCode)) {
          result = 'Mã này đã được quét trước đó!';
          return; // Không tiếp tục xử lý nếu mã đã tồn tại
        }

        setState(() {
          result = scannedCode;
          QRScan = 1; // Ngăn quét liên tục
        });

        final result2 = await Navigator.push(
          context,
          SlideFromRightPageRoute(
            page: QrinfoticketPage(
              buyTicketID: result,
            ),
          ),
        );

        if (result2 == 'Không tồn tại') {
          EasyLoading.showError('Lỗi không tìm thấy vé');
          scannedCodes.add(scannedCode); // Lưu mã vào danh sách

          setState(() {
            QRScan = 0; // Cho phép quét lại
            result = 'Mã này đã được quét trước đó!';

            // Không xóa mã khỏi danh sách ngay cả khi không hợp lệ
          });
        } else {
          // Nếu vé tồn tại, cho phép quét tiếp
          setState(() {
            QRScan = 0;
          });
        }
      } else {
        setState(() {
          result = "Không quét được mã!";
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
