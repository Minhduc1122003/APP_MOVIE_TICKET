import 'package:flutter/material.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_profile/profile_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_profile/profile_notlogin_page.dart';

class CheckUserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (UserManager.instance.user == null) {
      return const ProfileNotloginPage();
    } else {
      return const ProfilePage();
    }
  }
}
