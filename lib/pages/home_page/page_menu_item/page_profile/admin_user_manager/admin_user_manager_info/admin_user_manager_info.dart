import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:intl/intl.dart';

class PersonnelInfoPage extends StatefulWidget {
  final User usermodel;

  const PersonnelInfoPage(this.usermodel, {Key? key}) : super(key: key);

  @override
  _PersonnelInfoPageState createState() => _PersonnelInfoPageState();
}

class _PersonnelInfoPageState extends State<PersonnelInfoPage> {
  int selectedTab = 0; // 0: Trạng thái, 1: Tài sản, 2: Công việc
  //định dạng ngày
  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(parsedDate);
  }

  void onTabSelected(int index) {
    setState(() {
      selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          '${widget.usermodel.fullName}',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Phần trên của đường line
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  backgroundImage: widget.usermodel.photo != null &&
                          widget.usermodel!.photo.isNotEmpty
                      ? AssetImage('assets/images/${widget.usermodel.photo}')
                      : AssetImage('assets/images/profile.png'),
                ),
                const SizedBox(height: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.usermodel.fullName,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.usermodel.userName,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(3),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      onTabSelected(0);
                    },
                    child: Text('Trạng thái'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          selectedTab == 0 ? Colors.white : Color(0XFF0e3b82),
                      backgroundColor:
                          selectedTab == 0 ? Colors.blue : Colors.blue[100],
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      onTabSelected(1);
                    },
                    child: AutoSizeText(
                      'Tài sản',
                      maxLines: 1,
                      minFontSize: 12,
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          selectedTab == 1 ? Colors.white : Color(0XFF0e3b82),
                      backgroundColor:
                          selectedTab == 1 ? Colors.blue : Colors.blue[100],
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      onTabSelected(2);
                    },
                    child: AutoSizeText(
                      'Công việc',
                      maxLines: 1,
                      minFontSize: 12,
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          selectedTab == 2 ? Colors.white : Color(0XFF0e3b82),
                      backgroundColor:
                          selectedTab == 2 ? Colors.blue : Colors.blue[100],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Divider(
            height: 5,
            color: Colors.grey[200],
            thickness: 4, // Thay đổi giá trị này để tăng độ dày
          ),

          // Phần cuộn của nội dung
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Nội dung thay đổi dựa trên nút đã chọn
                  if (selectedTab == 0) ...[
                    buildStatusContent(),
                  ] else if (selectedTab == 1) ...[
                    buildAssetsContent(),
                  ] else if (selectedTab == 2) ...[
                    buildWorkContent(),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Xử lý sự kiện khi nhấn 'Khóa tài khoản'
                      print('Khóa tài khoản');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.yellow, // Màu nền cho nút 'Khóa tài khoản'
                      foregroundColor: Colors.white, // Màu chữ trắng
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Bo góc 10
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('Khóa tài khoản'),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Xử lý sự kiện khi nhấn 'Xóa tài khoản'
                      print('Xóa tài khoản');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red, // Màu nền cho nút 'Xóa tài khoản'
                      foregroundColor: Colors.white, // Màu chữ trắng
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Bo góc 10
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('Xóa tài khoản'),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildStatusContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiết',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          // Thêm nội dung trạng thái nhân sự với tiêu đề "Chi tiết"
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.email_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Email: ',
                  ),
                  Expanded(
                    child: Text(
                      widget.usermodel.email,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Ngày tạo: ',
                  ),
                  Expanded(
                    child: Text(
                      widget.usermodel.email,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Người tạo: ',
                  ),
                  Expanded(
                    child: Text(
                      widget.usermodel.email,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Ngày cập nhật: ',
                  ),
                  Expanded(
                    child: Text(
                      widget.usermodel.email,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Người cập nhật: ',
                  ),
                  Expanded(
                    child: Text(
                      widget.usermodel.email,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildAssetsContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          // Thêm nội dung về tài sản
          Column(
            children: [
              Text('tab buildAsset'),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildWorkContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Công việc',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          // Thêm nội dung về công việc
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hiệu suất công việc',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tháng 9/2023',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.7,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.green,
                              size: 30,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Đúng hạn',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '9 công việc',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.orange,
                              size: 30,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Bị muộn',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '2 công việc',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Công việc tháng 9',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'September',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[500]),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '20',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Kết thúc sau',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '10 ngày nữa',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Image.asset(
                      'assets/images/target.png',
                      width: 150,
                      height: 150,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dự án tham gia',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Webstie vệ tinh',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              AssetImage('assets/images/profile.png'),
                        ),
                        SizedBox(width: 8),
                        CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              AssetImage('assets/images/profile.png'),
                        ),
                        SizedBox(width: 8),
                        CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              AssetImage('assets/images/profile.png'),
                        ),
                      ],
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
}
