import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import thư viện fl_chart
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:intl/intl.dart';

class TicketStatiscialManagerPage extends StatefulWidget {
  const TicketStatiscialManagerPage({super.key});

  @override
  State<TicketStatiscialManagerPage> createState() =>
      _TicketStatiscialManagerPageState();
}

class _TicketStatiscialManagerPageState
    extends State<TicketStatiscialManagerPage> {
  late ApiService _apiService;
  int _activeTabIndex = 0;

  late Future<List<Map<String, dynamic>>> _getThongke;
  String selectedDay = ''; // Di chuyển khai báo biến `selectedDay` ra ngoài
  late List<String> months = [];

  late List<dynamic> userCounts = [];
  DateTime _currentWeekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1)); // Thứ 2 của tuần hiện tại
  DateTime _currentWeekEnd = DateTime.now().add(
      Duration(days: 7 - DateTime.now().weekday)); // Chủ nhật của tuần hiện tại
  DateTime? _selectedDate;
  TextEditingController _dateController = TextEditingController();
  bool isLoading = true;
  int totalInvoiceCount = 0;
  double totalTicketPrice = 0.0;
  double totalComboPrice = 0.0;
  double totalRevenue = 0.0;
  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _fetchThongkeData(); // Gọi hàm để xử lý API và cập nhật dữ liệu
  }

  double totalPreviousWeekRevenue = 0.0; // Biến lưu tổng doanh thu tuần trước

  void _fetchThongkeData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Gọi API
      final data = await _apiService.getThongkeDoanhThuOnline(
        _currentWeekStart.toIso8601String(),
        _currentWeekEnd.toIso8601String(),
        "0",
      );

      totalInvoiceCount = 0;
      totalTicketPrice = 0;
      totalComboPrice = 0;
      totalRevenue = 0;

      // Phân tích dữ liệu trả về
      Map<String, dynamic> parsedResponse = Map<String, dynamic>.from(data);
      List<Map<String, dynamic>> parsedData =
          List<Map<String, dynamic>>.from(parsedResponse['data']);

      // Gán giá trị totalPreviousWeekRevenue
      setState(() {
        totalPreviousWeekRevenue =
            parsedResponse['totalPreviousWeekRevenue']?.toDouble() ?? 0.0;

        months = parsedData.map((item) {
          // Chuyển ngày từ chuỗi sang DateTime UTC
          DateTime date = DateTime.parse(item['Date']).toUtc();
          return DateFormat('dd/MM')
              .format(date); // Định dạng không bị lệch múi giờ
        }).toList();

        userCounts = parsedData.map((item) {
          return item['TotalRevenue'] ?? 0;
        }).toList();

        // Tính tổng các trường
        for (var item in parsedData) {
          totalInvoiceCount += (item['InvoiceCount'] as int) ?? 0;
          totalTicketPrice += item['TotalTicketPrice']?.toDouble() ?? 0.0;
          totalComboPrice += item['TotalComboPrice']?.toDouble() ?? 0.0;
          totalRevenue += item['TotalRevenue']?.toDouble() ?? 0.0;
        }

        // Tính toán tỷ lệ tăng trưởng
        double growthRate = 0.0;
        if (totalPreviousWeekRevenue != 0) {
          growthRate = ((totalRevenue - totalPreviousWeekRevenue) /
                  totalPreviousWeekRevenue) *
              100;
        }

        // In kết quả ra console
        print("Tổng số hóa đơn: $totalInvoiceCount");
        print("Tổng tiền vé: $totalTicketPrice");
        print("Tổng tiền combo: $totalComboPrice");
        print("Tổng doanh thu: $totalRevenue");
        print("Tổng doanh thu tuần trước: $totalPreviousWeekRevenue");
        print("Tăng trưởng doanh thu: ${growthRate.toStringAsFixed(2)}%");

        isLoading = false; // Dữ liệu đã tải xong
      });
    } catch (error) {
      print("Lỗi khi tải dữ liệu: $error");
      setState(() {
        isLoading = false; // Nếu lỗi cũng dừng loading
      });
    }
  }

  void _updateDateController() {
    if (_selectedDate != null) {
      _dateController.text =
          'Tuần: ${DateFormat('dd/MM').format(_getWeekStart(_selectedDate!))} - ${DateFormat('dd/MM').format(_getWeekEnd(_selectedDate!))}';
    }
    _fetchThongkeData();
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1)); // Thứ 2 của tuần
  }

  // Hàm để lấy ngày kết thúc của tuần cho một ngày cụ thể
  DateTime _getWeekEnd(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday)); // Chủ nhật của tuần
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Doanh thu đặt vé online',
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
          _buildTab('Theo tuần', index: 0),
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
    final double maxValue = userCounts.isNotEmpty
        ? userCounts.reduce((a, b) => a > b ? a : b).toDouble()
        : 0;
    final double maxY =
        maxValue / 0.8; // Tính maxY để giá trị lớn nhất chiếm 80%

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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        setState(() {
                          _currentWeekStart =
                              _currentWeekStart.subtract(Duration(days: 7));
                          _currentWeekEnd =
                              _currentWeekEnd.subtract(Duration(days: 7));
                          _selectedDate =
                              _currentWeekStart; // Cập nhật ngày đã chọn
                          _updateDateController(); // Cập nhật controller
                        });
                      },
                    ),
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText:
                              'Tuần: ${DateFormat('dd/MM').format(_currentWeekStart)} - ${DateFormat('dd/MM').format(_currentWeekEnd)}',
                          border: OutlineInputBorder(),
                        ),
                        controller: _dateController,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              _selectedDate = pickedDate;
                              _currentWeekStart = _getWeekStart(_selectedDate!);
                              _currentWeekEnd = _getWeekEnd(_selectedDate!);
                              _updateDateController();
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        setState(() {
                          _currentWeekStart =
                              _currentWeekStart.add(Duration(days: 7));
                          _currentWeekEnd =
                              _currentWeekEnd.add(Duration(days: 7));
                          _selectedDate =
                              _currentWeekStart; // Cập nhật ngày đã chọn
                          _updateDateController();
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(), // Hoặc sử dụng Spinkit
                ),
              if (isLoading == false)
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceEvenly,
                      maxY: maxValue / 0.7,
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
                                width: 20,
                                borderRadius: BorderRadius.circular(1),
                                rodStackItems: [], // Nếu cần stacked bar
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          );
                        },
                      ).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          axisNameWidget: Text(
                            'Tuần: ${DateFormat('dd/MM/yyyy').format(_currentWeekStart)} - ${DateFormat('dd/MM/yyyy').format(_currentWeekEnd)}',
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < months.length) {
                                return Text(
                                  months[value.toInt()],
                                  style: const TextStyle(fontSize: 10),
                                );
                              } else {
                                return const Text('');
                              }
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final double maxY = maxValue / 0.7;
                              if (value == maxY) {
                                return Container();
                              }
                              final formattedValue = value
                                  .toInt()
                                  .toString()
                                  .replaceAllMapped(
                                      RegExp(r'(\d{3})(?=(\d{3})*$)'),
                                      (match) => '${match.group(1)}\n');
                              return Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Text(
                                  formattedValue.trim(),
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.right,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipHorizontalOffset: 0,
                          getTooltipColor: (group) => Colors.transparent,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final formattedValue = NumberFormat("#,##0")
                                .format(rod.toY); // Định dạng số

                            return BarTooltipItem(
                              '$formattedValue',
                              const TextStyle(
                                color: mainColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 8,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng hóa đơn:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '$totalInvoiceCount đơn hàng',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng tiền vé:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${formatPrice(totalTicketPrice)} đ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng tiền combo:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${formatPrice(totalComboPrice)} đ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Divider(
                      height: 1,
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng doanh thu:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${formatPrice(totalRevenue)} đ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.deepOrange),
                        ),
                      ],
                    ),
                  ],
                ),
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

String formatPrice(double price) {
  final formatter = NumberFormat('#,###', 'vi');
  return formatter.format(price);
}
