import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';

class ComboTicketStaffPage extends StatefulWidget {
  const ComboTicketStaffPage();

  @override
  _ComboTicketStaffPageState createState() => _ComboTicketStaffPageState();
}

class _ComboTicketStaffPageState extends State<ComboTicketStaffPage> {
  late ApiService _apiService;
  Map<String, int> selectedCombos = {};
  Map<String, int> selectedSingleItems = {};

  int get totalItems => [
        ...selectedCombos.values,
        ...selectedSingleItems.values
      ].fold(0, (sum, quantity) => sum + quantity);

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
  }

  void updateItemQuantity(String itemName, bool isCombo, int change) {
    setState(() {
      if (isCombo) {
        selectedCombos[itemName] = (selectedCombos[itemName] ?? 0) + change;
        if (selectedCombos[itemName] == 0) {
          selectedCombos.remove(itemName);
        }
      } else {
        selectedSingleItems[itemName] =
            (selectedSingleItems[itemName] ?? 0) + change;
        if (selectedSingleItems[itemName] == 0) {
          selectedSingleItems.remove(itemName);
        }
      }
    });
  }

  Widget _buildQuantityControls(String itemName, bool isCombo) {
    final quantity = isCombo
        ? selectedCombos[itemName] ?? 0
        : selectedSingleItems[itemName] ?? 0;

    return Container(
      child: quantity == 0
          ? ElevatedButton(
              onPressed: () => updateItemQuantity(itemName, isCombo, 1),
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
                    onPressed: () => updateItemQuantity(itemName, isCombo, -1),
                  ),
                  Text(
                    quantity.toString(),
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: mainColor, size: 20),
                    onPressed: () => updateItemQuantity(itemName, isCombo, 1),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildComboItem(String title, String description, String price) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(
              width: 100,
              height: 120,
              child: Image.asset(
                'assets/images/combo1.png',
                fit: BoxFit.cover,
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
                  _buildQuantityControls(title, true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleItem(String title, String description, String price) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Image.asset('assets/single_item_image.png'),
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
                  _buildQuantityControls(title, false),
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
                  // Combo tab content
                  ListView(
                    children: [
                      _buildComboItem(
                        'COMBO SOLO',
                        '1 bắp ngọt 60oz + 1 coke 32oz',
                        '94,000 VND',
                      ),
                      _buildComboItem(
                        'COMBO COUPLE',
                        '1 bắp ngọt 60oz + 2 coke 32oz',
                        '115,000 VND',
                      ),
                      _buildComboItem(
                        'COMBO SOLO',
                        '1 bắp ngọt 60oz + 1 coke 32oz',
                        '94,000 VND',
                      ),
                      _buildComboItem(
                        'COMBO COUPLE',
                        '1 bắp ngọt 60oz + 2 coke 32oz',
                        '115,000 VND',
                      ),
                    ],
                  ),

                  // Bán lẻ tab content
                  ListView(
                    children: [
                      _buildSingleItem(
                        'BẮP NGỌT',
                        '1 bắp ngọt 60oz',
                        '49,000 VND',
                      ),
                      _buildSingleItem(
                        'COCA 32OZ',
                        '1 coke Coca 32oz',
                        '39,000 VND',
                      ),
                    ],
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

  Widget _buildSelectedItem(String name, int quantity, bool isCombo) {
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
                  name,
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
                // Nút giảm
                IconButton(
                  icon: Icon(Icons.remove, color: mainColor, size: 20),
                  onPressed: () => updateItemQuantity(name, isCombo, -1),
                  constraints: BoxConstraints(
                    minWidth: 25,
                    minHeight: 25,
                  ),
                  padding: EdgeInsets.zero,
                ),
                // Hiển thị số lượng
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
                // Nút tăng
                IconButton(
                  icon: Icon(Icons.add, color: mainColor, size: 20),
                  onPressed: () => updateItemQuantity(name, isCombo, 1),
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
