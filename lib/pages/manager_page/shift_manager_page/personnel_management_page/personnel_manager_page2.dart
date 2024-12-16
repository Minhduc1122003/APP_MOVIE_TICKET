import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/manager_page/personnel_manager_page/personnel_info_manager_page/personnel_info_manager_page.dart';
import 'package:flutter_app_chat/pages/manager_page/shift_manager_page/personnel_management_page/personnel_info_manager_page2.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';

class PersonnelManagerPage2 extends StatefulWidget {
  final int role; // Tham số xác định Role (0: Khách hàng, 1: Nhân viên)

  const PersonnelManagerPage2({super.key, required this.role});

  @override
  State<PersonnelManagerPage2> createState() => _PersonnelManagerPage2State();
}

class _PersonnelManagerPage2State extends State<PersonnelManagerPage2>
    with SingleTickerProviderStateMixin {
  late ApiService _APIService;
  late Future<List<User>> _filteredUsers;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
    _filteredUsers =
        _filterUsersByRole(widget.role); // Lọc người dùng theo Role
    _tabController = TabController(length: 2, vsync: this); // 2 tab
  }

  void _refreshUserList() {
    setState(() {
      _filteredUsers = _filterUsersByRole(widget.role);
    });
  }

  Future<List<User>> _filterUsersByRole(int role) async {
    final users = await _APIService.getUserListForAdmin();

    // Nếu role là -1, lấy cả role 1 và 2
    if (role == -1) {
      return users.where((user) => [1, 2].contains(user.role)).toList();
    }

    // Lấy danh sách theo role cụ thể
    return users.where((user) => user.role == role).toList();
  }

  Widget buildUserList(List<User> users, String statusFilter) {
    // Lọc danh sách người dùng theo status
    final filteredUsers =
        users.where((user) => user.status == statusFilter).toList();
    if (filteredUsers.isEmpty) {
      return Center(child: Text('Không có dữ liệu.'));
    }

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return ListTile(
          title: Text(user.fullName),
          subtitle: Text(user.email),
          leading: CircleAvatar(
            radius: 30,
            backgroundImage:
                user.photo != null ? NetworkImage(user.photo!) : null,
            backgroundColor: user.photo == null ? Colors.grey[300] : null,
            child: user.photo == null
                ? Icon(Icons.person, size: 40, color: Colors.grey[400])
                : null,
          ),
          trailing: Text(user.status),
          onTap: () async {
            final shouldRefresh = await Navigator.push(
              context,
              SlideFromRightPageRoute(
                page: PersonnelInfoManagerPage2(
                    user: user, isUpdate: widget.role),
              ),
            );

            // Nếu cần làm mới danh sách, gọi hàm _refreshUserList
            if (shouldRefresh == true) {
              _refreshUserList();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: mainColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_outlined,
                  color: Colors.white, size: 16),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              [1, 2].contains(widget.role)
                  ? 'Danh sách nhân viên' // Role 1 và 2
                  : 'Danh sách người dùng', // Role khác
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            centerTitle: false,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              dividerHeight: 0,
              unselectedLabelColor:
                  Colors.black, // Text màu trắng cho tab không chọn
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(
                  text: 'Đang hoạt động',
                ),
                Tab(text: 'Đã khóa'),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: FutureBuilder<List<User>>(
            future: _filteredUsers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Không tìm thấy dữ liệu.'));
              } else {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    buildUserList(snapshot.data!, 'Đang hoạt động'), // Tab 1
                    buildUserList(snapshot.data!, 'Đã khóa'), // Tab 2
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
