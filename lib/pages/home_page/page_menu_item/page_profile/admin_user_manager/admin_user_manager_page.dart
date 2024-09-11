import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_profile/admin_user_manager/admin_user_manager_info/admin_user_manager_info.dart';

class AdminUserManagerPage extends StatefulWidget {
  const AdminUserManagerPage({Key? key}) : super(key: key);

  @override
  _AdminUserManagerPageState createState() => _AdminUserManagerPageState();
}

class _AdminUserManagerPageState extends State<AdminUserManagerPage> {
  late ApiService _apiService;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  List<User> _allUsers = [];
  List<User> _displayedUsers = [];
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isSearchLoading = false; // For controlling search loading state
  int _page = 1;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadAllUsers();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _loadMore();
      }
    });

    // Listen to changes in the search bar
    _searchController.addListener(() {
      _filterUsers(_searchController.text);
    });
  }

  void _filterUsers(String query) {
    final lowerCaseQuery = query.toLowerCase();

    setState(() {
      searchQuery = query;
      _isSearchLoading = true;

      _displayedUsers = _allUsers.where((user) {
        final nameLower = user.fullName?.toLowerCase();
        final emailLower = user.email?.toLowerCase();
        _isSearchLoading = false;

        return nameLower!.contains(lowerCaseQuery) ||
            emailLower!.contains(lowerCaseQuery);
      }).toList();

      _isSearchLoading = false; // Đặt lại loading sau khi lọc xong
    });
  }

  Future<void> _loadAllUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allUsers =
          await _apiService.getAllUserData(UserManager.instance.user!.userName);

      setState(() {
        _allUsers = allUsers!;
        _filterUsers(searchQuery); // Filter users right after loading
        _isLoading = false;
      });
      // Print the list of all users
      print('from admin ${allUsers}');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
      print('Error loading users: $e');
    }
    _isLoading = false;
  }

  Future<void> _loadMore() async {
    if (_hasMore && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      final nextPageStartIndex = _page * _pageSize;
      final nextPageEndIndex =
          (_allUsers.length < nextPageStartIndex + _pageSize)
              ? _allUsers.length
              : nextPageStartIndex + _pageSize;

      if (nextPageStartIndex < _allUsers.length) {
        setState(() {
          _displayedUsers
              .addAll(_allUsers.sublist(nextPageStartIndex, nextPageEndIndex));
          _isLoading = false;

          if (_displayedUsers.length >= _allUsers.length) {
            _hasMore = false;
          } else {
            _page++;
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFF6F3CD7),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 16,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Quản lý người dùng',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                prefixIcon: Icon(Icons.search, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            searchQuery = '';
                            _filterUsers(''); // Show all users again
                          });
                        },
                      )
                    : null,
                hintText: 'Tìm kiếm người dùng',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _displayedUsers.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _displayedUsers.length && _hasMore) {
                  return Center(child: CircularProgressIndicator());
                }

                User user = _displayedUsers[index];
                return ListTile(
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CircleAvatar(
                          backgroundColor: null,
                          backgroundImage:
                              user.photo != null && user.photo!.isNotEmpty
                                  ? AssetImage('assets/images/${user.photo}')
                                  : AssetImage('assets/images/profile.png'),
                          radius: 23,
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    user.fullName.toString(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    user.email.toString(),
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.black54),
                  onTap: () {
                    Navigator.push(
                        context,
                        SlideFromRightPageRoute(
                          page: PersonnelInfoPage(user),
                        ));
                  },
                );
              },
            ),
          ),
          if (_isLoading) // Show a loading spinner during pagination
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
