import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_profile/page_user/forgot_user/forgot_pass_user.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

class InfoUser extends StatefulWidget {
  const InfoUser({
    Key? key,
  }) : super(key: key);

  @override
  State<InfoUser> createState() => _InfoUser();
}

class _InfoUser extends State<InfoUser> {
  late ApiService _APIService;
  late final Future<User> _userFuture;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  late TextEditingController createDateController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
    _userFuture =
        _APIService.findByViewIDUser(UserManager.instance.user!.userId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Cập nhật thông tin người dùng
  Future<void> _saveChanges() async {
    try {
      EasyLoading.show(status: 'Đang lưu...'); // Hiển thị thông báo đang lưu

      final userId = UserManager.instance.user!.userId;
      final userName = usernameController.text;
      final fullName = fullnameController.text;
      final phoneNumber = int.tryParse(phoneController.text) ?? 0;
      final photo = ''; // You can add logic to update the photo if needed

      // Call the API to update user info
      final response = await _APIService.updateInfoUser(
          userId, userName, fullName, phoneNumber, photo);

      EasyLoading.showSuccess(response); // Hiển thị thông báo thành công
    } catch (e) {
      EasyLoading.showError('Lỗi: $e'); // Hiển thị thông báo lỗi
    } finally {
      // Đảm bảo luôn ẩn EasyLoading sau khi xử lý xong
      Future.delayed(Duration(seconds: 2), () {
        EasyLoading.dismiss();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F75FF),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 16,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No user data available.'));
          } else {
            final user = snapshot.data!;
            usernameController.text = user.userName;
            fullnameController.text = user.fullName;
            phoneController.text = user.phoneNumber.toString();
            createDateController.text = dateFormatter.format(user.createDate);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.blue,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/${user.photo}',
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 13,
                                backgroundColor: Colors.grey,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.edit_square,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  onPressed: () {
                                    // Handle edit profile picture
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  iconSize: 16,
                                  tooltip: "Edit",
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.userName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(user.email),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 15),
                    MyTextfield(
                      placeHolder: 'Tên người dùng',
                      controller: usernameController,
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      placeHolder: 'Họ tên người dùng',
                      controller: fullnameController,
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      placeHolder: 'Số điện thoại',
                      controller: phoneController,
                      isPhone: true,
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      placeHolder: 'Ngày tạo',
                      isEdit: false,
                      controller: createDateController,
                    ),
                    const SizedBox(height: 30),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                SlideFromRightPageRoute(
                                  page: ForgotPassUser(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(
                                color: mainColor,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Đổi mật khẩu',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: mainColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: MyButton(
                            text: 'Lưu thay đổi',
                            fontsize: 16,
                            paddingText: 16,
                            onTap:
                                _saveChanges, // Call the _saveChanges method here
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
