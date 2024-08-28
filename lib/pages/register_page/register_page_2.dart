import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/components/my_customIcon_keyboad_left.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/pages/login_page/login_page.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/pages/login_page/login_page2.dart';
import 'package:flutter_app_chat/pages/register_page/createAccount_bloc/createAccount_bloc.dart';
import 'package:flutter_app_chat/pages/register_page/register_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class RegisterPage2 extends StatefulWidget {
  final String email;
  final String password;

  const RegisterPage2({super.key, required this.email, required this.password});

  @override
  State<RegisterPage2> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage2> {
  bool _savePassword = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void onCreateAccountPressed(BuildContext context) {
    final String email = widget.email;
    final String password = widget.password;
    final String username = _usernameController.text;
    final String fullname = _fullnameController.text;
    final int phoneNumber = int.tryParse(_phoneController.text) ?? 0;
    final String photo = '';

    BlocProvider.of<CreateAccountBloc>(context).add(
        CreateAccount(email, password, username, fullname, phoneNumber, photo));
  }

  @override
  void initState() {
    super.initState();

    // Print the values in the initState method
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    print('Email: ${widget.email}');
    print('Passs: ${widget.password}');

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<CreateAccountBloc, CreateAccountState>(
        listener: (context, state) async {
          if (state is CreateAccountError) {
            print('login LoginError');
            EasyLoading.showError('Lỗi');
          } else if (state is CreateAccountWaiting) {
            EasyLoading.show();
          } else if (state is CreateAccountSuccess) {
            EasyLoading.dismiss();
            EasyLoading.showSuccess(
                'Đăng ký tài khoản thành công, chuyển về trang đăng nhập trong 3s!');
            await Future.delayed(const Duration(seconds: 2));
            Navigator.popUntil(
                context, ModalRoute.withName(Navigator.defaultRouteName));

            Navigator.pushReplacement(
              context,
              ZoomPageRoute(
                page: LoginPage2(),
              ),
            );
          }
        },
        child: Stack(
          children: [
            // Đặt hình ảnh nền với độ mờ 20%
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.7),
                  BlendMode.srcOver,
                ),
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Positioned widget for header
            Positioned(
              top: statusBarHeight,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                            context, SlideFromLeftPageRoute(page: LoginPage()));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CustomIconButton(
                            icon: Icons.keyboard_arrow_left,
                            size: 25,
                            color: Colors.black,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 40, 0),
                          child: Text(
                            'Đăng ký tài khoản',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Main content
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 90, 20, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: keyboardHeight),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.message,
                              size: 100,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            // welcome back
                            Text(
                              'Chỉ còn 1 bước nữa thôi..!',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // username textfield
                            SizedBox(height: 20),
                            MyTextfield(
                              isPassword: false,
                              placeHolder: "Tên người dùng",
                              controller: _usernameController,
                              sendCode: false,
                            ),
                            SizedBox(height: 20),
                            MyTextfield(
                              isPassword: false,
                              placeHolder: "Họ tên",
                              controller: _fullnameController,
                              sendCode: false,
                            ),
                            const SizedBox(height: 20),
                            MyTextfield(
                              isPassword: false,
                              placeHolder: "Số điện thoại",
                              controller: _phoneController,
                              sendCode: false,
                              isPhone: true,
                            ),
                            const SizedBox(height: 20),
                            MyButton(
                              fontsize: 16,
                              paddingText: 16,
                              text: 'HOÀN TẤT',
                              showIcon: false, // Hiển thị biểu tượng
                              onTap: () => onCreateAccountPressed(context),
                            ),
                            const SizedBox(height: 40),
                            // Social Media Buttons
                          ],
                        ),
                      ),
                    ),
                    // Các phần tử cố định ở cuối màn hình
                    Column(
                      children: [
                        const Divider(
                          height: 20,
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                          color: Colors.black,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Đã có tài khoản?'),
                              SizedBox(width: 5),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    SlideFromLeftPageRoute(page: LoginPage()),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0XFF6F3CD7),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
