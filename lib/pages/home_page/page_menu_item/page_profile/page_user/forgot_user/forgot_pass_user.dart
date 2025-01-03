import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/login_page/login_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';

class ForgotPassUser extends StatefulWidget {
  const ForgotPassUser({super.key});

  @override
  State<ForgotPassUser> createState() => _ForgotPassUserState();
}

class _ForgotPassUserState extends State<ForgotPassUser> {
  late ApiService _APIService;
  late Future<User> _userFuture;

  final TextEditingController passedController = TextEditingController();
  final TextEditingController passnewController = TextEditingController();
  final TextEditingController ConfirmPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
    _userFuture =
        _APIService.findByViewIDUser(UserManager.instance.user!.userId);
    _handleChangePassword();
  }

  Future<void> _handleChangePassword() async {
    final oldPassword = passedController.text.trim();
    final newPassword = passnewController.text.trim();
    final confirmPassword = ConfirmPassController.text.trim();

    // Kiểm tra trường trống
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
      );
      return;
    }

    // Kiểm tra mật khẩu mới và xác nhận mật khẩu
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới và xác nhận không khớp!')),
      );
      return;
    }

    // Kiểm tra mật khẩu mới không trùng với mật khẩu cũ
    if (oldPassword == newPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu mới không được trùng với mật khẩu cũ!'),
        ),
      );
      return;
    }

    try {
      // Gọi API đổi mật khẩu
      final message = await _APIService.changePassword(
        UserManager.instance.user!.userId,
        newPassword,
      );

      // Hiển thị thông báo thành công
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Thông báo'),
            content: const Text('Bạn cần đăng nhập lại để sử dụng dịch vụ!'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  UserManager.instance.clearUser();
                  Navigator.pushAndRemoveUntil(
                    context,
                    SlideFromLeftPageRoute(page: LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đổi mật khẩu thất bại: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Đảm bảo xóa bộ nhớ
    passedController.dispose();
    passnewController.dispose();
    ConfirmPassController.dispose();
    super.dispose();
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
          'Đổi mật khẩu',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No user data available.'));
          } else {
            final user = snapshot.data!;
            return _buildUserContent(user);
          }
        },
      ),
    );
  }

  Widget _buildUserContent(User user) {
    // Tạo giao diện hiển thị thông tin người dùng
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: ClipOval(
                      child: Image.network(
                    '${user.photo}',
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                  )),
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
              placeHolder: 'Mật khẩu cũ',
              controller: passedController,
              isPassword: true,
            ),
            const SizedBox(height: 10),
            MyTextfield(
              placeHolder: 'Mật khẩu mới',
              controller: passnewController,
              isPassword: true,
            ),
            const SizedBox(height: 10),
            MyTextfield(
              placeHolder: 'Xác nhận lại mật khẩu',
              controller: ConfirmPassController,
              isPassword: true,
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await _handleChangePassword(); // Gọi hàm xử lý đổi mật khẩu
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
