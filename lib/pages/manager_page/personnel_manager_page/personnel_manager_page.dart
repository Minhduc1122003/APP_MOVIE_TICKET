import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/manager_page/personnel_manager_page/personnel_info_manager_page/personnel_info_manager_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';

class PersonnelManagerPage extends StatefulWidget {
  final int role; // Tham số xác định Role (0: Khách hàng, 1: Nhân viên)

  const PersonnelManagerPage({super.key, required this.role});

  @override
  State<PersonnelManagerPage> createState() => _PersonnelManagerPageState();
}

class _PersonnelManagerPageState extends State<PersonnelManagerPage>
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
          leading: user.photo != null
              ? Image.network(user.photo!)
              : Icon(Icons.person),
          trailing: Text(user.status),
          onTap: () async {
            final shouldRefresh = await Navigator.push(
              context,
              SlideFromRightPageRoute(
                page: PersonnelInfoManagerPage(user: user),
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
              widget.role == 1 ? 'Danh sách nhân viên' : 'Danh sách khách hàng',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: 'Đang hoạt động'),
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
