import 'package:flutter/material.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_profile/profile_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_profile/profile_notlogin_page.dart';

final checkUserPageKey = GlobalKey<_CheckUserPageState>();

class CheckUserPage extends StatefulWidget {
  final Function? onRefresh;

  CheckUserPage({this.onRefresh, Key? key})
      : super(key: key ?? checkUserPageKey);

  @override
  _CheckUserPageState createState() => _CheckUserPageState();
}

class _CheckUserPageState extends State<CheckUserPage> {
  @override
  Widget build(BuildContext context) {
    // Kiểm tra nếu người dùng đã đăng nhập hay chưa
    if (UserManager.instance.user == null) {
      return const ProfileNotloginPage();
    } else {
      return const ProfilePage();
    }
  }
}
