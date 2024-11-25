import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import thư viện fl_chart
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';

class NewPersonnelInfoManagerPage extends StatefulWidget {
  const NewPersonnelInfoManagerPage({super.key});

  @override
  State<NewPersonnelInfoManagerPage> createState() =>
      _NewPersonnelInfoManagerPageState();
}

class _NewPersonnelInfoManagerPageState
    extends State<NewPersonnelInfoManagerPage> {
  late ApiService _apiService;
  int _activeTabIndex = 0;

  late Future<Map<int, int>> _getThongke;
  String selectedDay = ''; // Di chuyển khai báo biến `selectedDay` ra ngoài

  final List<String> months = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];

  final List<int> userCounts = [
    10,
    20,
    15,
    25,
    18,
    30,
    11,
    35,
    28,
    40,
    32,
    200,
  ];
  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    // _getThongke = _apiService.getThongkeNguoiDungMoi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Thống kê người dùng',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildTab('Theo ngày', index: 0),
          _buildTab('Theo tháng', index: 1),
          _buildTab('Theo năm', index: 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, {required int index}) {
    bool isActive = _activeTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTabIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? mainColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? mainColor : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    // Lấy ngày hôm nay
    DateTime now = DateTime.now();
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    List<String> daysOfMonth = List.generate(daysInMonth, (index) {
      int day = index + 1;
      return '$day/${now.month}';
    });

    // Cập nhật selectedDay với ngày hiện tại nếu chưa được gán
    if (selectedDay.isEmpty) {
      selectedDay = '${now.day}/${now.month}';
    }

    switch (_activeTabIndex) {
      case 0:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'Chọn ngày muốn xem: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        10, 0, 10, 0), // Padding cho dropdown
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // Border radius
                      border: Border.all(
                        color: Colors.grey, // Màu border là grey
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: selectedDay,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDay =
                              newValue!; // Cập nhật selectedDay khi người dùng chọn ngày
                        });
                      },
                      items: daysOfMonth
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10), // Dropdown cho ngày trong tháng

              // Biểu đồ
              SizedBox(
                width: double.infinity,
                height: 300, // Giới hạn chiều cao biểu đồ
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceBetween,
                    barGroups: userCounts.asMap().entries.map(
                      (entry) {
                        int index = entry.key;
                        double value = entry.value.toDouble();
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: value,
                              color: mainColor,
                              width: 16,
                              borderRadius: BorderRadius.zero,
                            ),
                          ],
                        );
                      },
                    ).toList(),
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        axisNameSize: 16,
                        axisNameWidget: Text('Tháng'),
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Text(months[value.toInt()]);
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Số người dùng theo tháng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Thông tin thêm',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

      case 1:
        return Center(child: Text('Hoạt động content'));
      case 2:
        return Center(child: Text('Lịch sử giao dịch content'));
      default:
        return Container();
    }
  }
}
