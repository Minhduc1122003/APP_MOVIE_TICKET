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
              children: [],
            ),
          ),
        ],
      ),
    );
  }
}
