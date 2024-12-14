import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';

class PersonnelInfoManagerPage2 extends StatefulWidget {
  final User user;
  final int? isUpdate;

  const PersonnelInfoManagerPage2({
    Key? key,
    required this.user,
    this.isUpdate = 10,
  }) : super(key: key);
  @override
  State<PersonnelInfoManagerPage2> createState() =>
      _PersonnelInfoManagerPage2State();
}

class _PersonnelInfoManagerPage2State extends State<PersonnelInfoManagerPage2>
    with SingleTickerProviderStateMixin {
  int _activeTabIndex = 0;
  late ApiService _APIService;
  late Future<List<User>> _userList;
  int? _selectedUserId;
  late Future<User> _userDetail;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
    _userList = _APIService.getUserListForAdmin();
    _userDetail = _APIService.findByViewIDUser(widget.user.userId);
    _tabController = TabController(length: 3, vsync: this); // 2 tab
// Gọi API
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
    return FutureBuilder<User>(
      future: _userDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          return Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      user.photo != null ? NetworkImage(user.photo!) : null,
                  backgroundColor: user.photo == null ? Colors.grey[300] : null,
                  child: user.photo == null
                      ? Icon(Icons.person, size: 40, color: Colors.grey[400])
                      : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.userName,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(child: Text('Không tìm thấy dữ liệu.'));
        }
      },
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
    return FutureBuilder<User>(
      future: _userDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          return ListView(
            children: [
              _buildInfoItem('ID người dùng:', user.userId.toString()),
              _buildInfoItem('Tên người dùng:', user.fullName),
              _buildInfoItem('Số điện thoại:', user.phoneNumber.toString()),
              _buildInfoItem(
                  'Ngày tạo tài khoản:', _formatDate(user.createDate)),
              SizedBox(height: 20),
              _buildActionButtons(),
            ],
          );
        } else {
          return Center(child: Text('Không có dữ liệu.'));
        }
      },
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
    bool isLocked = widget.user.status == 'Đã khóa'; // Kiểm tra trạng thái

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Đảm bảo các nút tràn hết chiều ngang
        children: [
          // Nếu user có role 0 (khách hàng), hiển thị nút "Cấp quyền Nhân Viên"
          if (widget.user.role == 0)
            ElevatedButton(
              onPressed: () async {
                try {
                  // Chuyển đổi role từ 0 lên 1
                  int newRole = 1;
                  await _APIService.updateUserRole(widget.user.userId, newRole);

                  // Hiển thị thông báo thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã cấp quyền Nhân Viên.')),
                  );

                  // Quay lại trang trước và thông báo cần làm mới
                  Navigator.of(context).pop(true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Cấp quyền Nhân Viên'),
            ),
          // Nếu user có role 2 (quản lý/admin), hiển thị nút "Giáng quyền xuống Nhân Viên"
          if (widget.user.role == 2)
            ElevatedButton(
              onPressed: () async {
                try {
                  // Chuyển đổi role từ 2 xuống 1
                  int newRole = 1;
                  await _APIService.updateUserRole(widget.user.userId, newRole);

                  // Hiển thị thông báo thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã giáng quyền xuống Nhân Viên.')),
                  );

                  // Quay lại trang trước và thông báo cần làm mới
                  Navigator.of(context).pop(true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Giáng quyền xuống Nhân Viên'),
            ),
          // Nếu user có role 1 (nhân viên), hiển thị các nút "Cấp quyền Quản Lý" và "Giáng quyền Khách Hàng"
          if (widget.user.role == 1) ...[
            ElevatedButton(
              onPressed: () async {
                try {
                  // Chuyển đổi role từ 1 lên 2
                  int newRole = 2;
                  await _APIService.updateUserRole(widget.user.userId, newRole);

                  // Hiển thị thông báo thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã cấp quyền Quản Lý (Admin).')),
                  );

                  // Quay lại trang trước và thông báo cần làm mới
                  Navigator.of(context).pop(true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Cấp quyền Quản Lý (Admin)'),
            ),
            const SizedBox(height: 10), // Khoảng cách giữa các nút
            ElevatedButton(
              onPressed: () async {
                try {
                  // Chuyển đổi role từ 1 xuống 0
                  int newRole = 0;
                  await _APIService.updateUserRole(widget.user.userId, newRole);

                  // Hiển thị thông báo thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã giáng quyền xuống Khách hàng')),
                  );

                  // Quay lại trang trước và thông báo cần làm mới
                  Navigator.of(context).pop(true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Giáng quyền xuống Khách hàng'),
            ),
          ],
        ],
      ),
    );
  }
}
