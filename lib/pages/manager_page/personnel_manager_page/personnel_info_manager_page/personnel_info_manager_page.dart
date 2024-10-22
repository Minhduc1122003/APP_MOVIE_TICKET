import 'package:flutter/material.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';

class PersonnelInfoManagerPage extends StatefulWidget {
  const PersonnelInfoManagerPage({super.key});

  @override
  State<PersonnelInfoManagerPage> createState() =>
      _PersonnelInfoManagerPageState();
}

class _PersonnelInfoManagerPageState extends State<PersonnelInfoManagerPage> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Thông tin người dùng',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildUserHeader(),
          _buildTabs(),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: mainColor,
            child: Icon(Icons.person, size: 40, color: Colors.grey[400]),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Huỳnh Nhi',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text('Hyn_0912@gmail.com',
                    style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildTab('Thông tin', index: 0),
          _buildTab('Hoạt động', index: 1),
          _buildTab('Lịch sử giao dịch', index: 2),
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
    switch (_activeTabIndex) {
      case 0:
        return _buildInfoContent();
      case 1:
        return Center(child: Text('Hoạt động content'));
      case 2:
        return Center(child: Text('Lịch sử giao dịch content'));
      default:
        return Container();
    }
  }

  Widget _buildInfoContent() {
    return ListView(
      children: [
        _buildInfoItem('ID người dùng:', 'PT09122004'),
        _buildInfoItem('Tên người dùng:', 'Huỳnh Thị Yến Nhi'),
        _buildInfoItem('Ngày sinh:', '09/12/2004'),
        _buildInfoItem('Số điện thoại:', '0386706328'),
        _buildInfoItem('Ngày tạo tài khoản:', '12/09/2024'),
        _buildInfoItem('Mật khẩu:', '••••••••••••'),
        SizedBox(height: 20),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Khóa tài khoản'),
              style: ElevatedButton.styleFrom(),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Xóa tài khoản'),
              style: ElevatedButton.styleFrom(),
            ),
          ),
        ],
      ),
    );
  }
}
