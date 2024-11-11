import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_film_select_all/page_buyTicket/page_SeatsChoose/page_combo_Ticket/combo_model.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';

class ComboTicketStaffPage extends StatefulWidget {
  const ComboTicketStaffPage();

  @override
  _ComboTicketStaffPageState createState() => _ComboTicketStaffPageState();
}

class _ComboTicketStaffPageState extends State<ComboTicketStaffPage> {
  late ApiService _apiService;
  List<Combo> comboItems = []; // Danh sách combo bắp nước
  List<Combo> singleItems = []; // Danh sách combo bán lẻ
  bool isLoading = true;
  Map<int, int> selectedCombos = {};
  Map<int, int> selectedSingleItems = {};

  int get totalItems => [
        ...selectedCombos.values,
        ...selectedSingleItems.values
      ].fold(0, (sum, quantity) => sum + quantity);

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Gọi cả 2 API
      final combos = await _apiService.getAllIsCombo();
      final singles = await _apiService.getAllIsNotCombo();

      setState(() {
        comboItems = combos;
        singleItems = singles;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải dữ liệu. Vui lòng thử lại sau.')),
      );
    }
  }

  void updateItemQuantity(int comboId, bool isCombo, int change) {
    setState(() {
      if (isCombo) {
        selectedCombos[comboId] = (selectedCombos[comboId] ?? 0) + change;
        if (selectedCombos[comboId] == 0) {
          selectedCombos.remove(comboId);
        }
      } else {
        selectedSingleItems[comboId] =
            (selectedSingleItems[comboId] ?? 0) + change;
        if (selectedSingleItems[comboId] == 0) {
          selectedSingleItems.remove(comboId);
        }
      }
    });
  }

  Widget _buildQuantityControls(int comboId, bool isCombo) {
    final quantity = isCombo
        ? selectedCombos[comboId] ?? 0
        : selectedSingleItems[comboId] ?? 0;

    return Container(
      child: quantity == 0
          ? ElevatedButton(
              onPressed: () => updateItemQuantity(comboId, isCombo, 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Thêm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                border: Border.all(color: mainColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: mainColor, size: 20),
                    onPressed: () => updateItemQuantity(comboId, isCombo, -1),
                  ),
                  Text(
                    quantity.toString(),
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: mainColor, size: 20),
                    onPressed: () => updateItemQuantity(comboId, isCombo, 1),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildComboItem(Combo combo) {
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
                combo.image,
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
                  Text(combo.title,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(combo.subtitle),
                  Text('${combo.price.toStringAsFixed(0)} VND',
                      style: TextStyle(color: Colors.red)),
                  _buildQuantityControls(combo.comboId, true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleItem(Combo item) {
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
                item.image,
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
                  Text(item.title,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(item.subtitle),
                  Text('${item.price.toStringAsFixed(0)} VND',
                      style: TextStyle(color: Colors.red)),
                  _buildQuantityControls(item.comboId, false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
          title: Text('Đặt combo',
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
                tabs: [Tab(text: 'Combo bắp nước'), Tab(text: 'Combo bán lẻ')],
              ),
            ),
          ),
        ),
        // Thay thế phần cuối của body với code sau
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  // Combo bắp nước tab
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: comboItems.length,
                          itemBuilder: (context, index) {
                            return _buildComboItem(comboItems[index]);
                          },
                        ),

                  // Combo bán lẻ tab
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: singleItems.length,
                          itemBuilder: (context, index) {
                            return _buildSingleItem(singleItems[index]);
                          },
                        ),
                ],
              ),
            ),
            if (totalItems > 0)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 350,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: mainColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Phần header
                            Text(
                              'Danh sách đã chọn',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                              ),
                            ),
                            SizedBox(height: 10),

                            // Phần danh sách sản phẩm
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    // Header cho danh sách (tùy chọn)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Sản phẩm',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            'Số lượng',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Danh sách combo đã chọn
                                    ...selectedCombos.entries.map(
                                      (entry) => _buildSelectedItem(
                                        entry.key,
                                        entry.value,
                                        true,
                                      ),
                                    ),
                                    // Danh sách sản phẩm đơn lẻ đã chọn
                                    ...selectedSingleItems.entries.map(
                                      (entry) => _buildSelectedItem(
                                        entry.key,
                                        entry.value,
                                        false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Phần footer với tổng số lượng và nút tiếp tục
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Tổng:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '$totalItems sản phẩm',
                                        style: TextStyle(
                                          color: mainColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  MyButton(
                                    fontsize: 20,
                                    paddingText: 10,
                                    text: 'Tiếp tục',
                                    isBold: true,
                                    onTap: () {
                                      print(
                                          'Tiếp tục với $totalItems sản phẩm');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedItem(int comboId, int quantity, bool isCombo) {
    // Tìm combo/item tương ứng từ danh sách để lấy thông tin
    final item = isCombo
        ? comboItems.firstWhere((c) => c.comboId == comboId)
        : singleItems.firstWhere((s) => s.comboId == comboId);

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
                  isCombo ? 'Combo' : 'Sản phẩm đơn lẻ',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: mainColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.remove, color: mainColor, size: 20),
                  onPressed: () => updateItemQuantity(comboId, isCombo, -1),
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
                    quantity.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: mainColor, size: 20),
                  onPressed: () => updateItemQuantity(comboId, isCombo, 1),
                  constraints: BoxConstraints(
                    minWidth: 25,
                    minHeight: 25,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
