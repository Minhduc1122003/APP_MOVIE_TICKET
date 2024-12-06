import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_InfoCard.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_app_chat/pages/manager_page/personnel_manager_page/personnel_manager_page.dart';

class PersonnelManagerTab extends StatefulWidget {
  const PersonnelManagerTab({super.key});

  @override
  State<PersonnelManagerTab> createState() => _PersonnelManagerTabState();
}

class _PersonnelManagerTabState extends State<PersonnelManagerTab> {
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
              'Quản lý nhân sự',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          body: Column(
            children: [
              UtilitySection(
                title: 'Thông tin nhân sự',
                buttons: [
                  UtilityButton(
                    color: mainColor,
                    title: 'Danh sách nhân viên',
                    icon: Icons.info_outline_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        SlideFromRightPageRoute(
                          page: PersonnelManagerPage(
                              role: 1), // Role = 1 (Nhân viên)
                        ),
                      );
                    },
                  ),
                  UtilityButton(
                    color: mainColor,
                    title: 'Danh sách khách hàng',
                    icon: Icons.manage_accounts,
                    onPressed: () {
                      Navigator.push(
                        context,
                        SlideFromRightPageRoute(
                          page: PersonnelManagerPage(
                              role: 0), // Role = 0 (Khách hàng)
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
