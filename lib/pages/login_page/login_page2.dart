import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/components/my_customIcon_keyboad_left.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/pages/login_page/loginBloc/login_bloc.dart';
import 'package:flutter_app_chat/pages/register_page/register_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginPage2 extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage2> {
  bool _savePassword = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // khai báo tiện ích API
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> futureData;
  late Future<User> futureUser;

  void _onLoginButtonPressed(BuildContext context) {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    BlocProvider.of<LoginBloc>(context).add(Login(email, password));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) async {
          if (state is LoginError) {
            print('login LoginError');
            EasyLoading.showError('Sai tài khoản hoặc mật khẩu');
          } else if (state is LoginWaiting) {
            EasyLoading.show();
          } else if (state is LoginSuccess) {
            EasyLoading.dismiss();
            await Future.delayed(Duration(milliseconds: 150));
            Navigator.pushReplacement(
              context,
              ZoomPageRoute(
                page: HomePage(),
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
            Positioned(
              top: statusBarHeight,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: const Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Text(
                            'Đăng nhập',
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
            // Positioned widget for header

            // Main content
            Positioned.fill(
              child: Padding(
                padding:
                    EdgeInsets.fromLTRB(20, 90, 20, 10), // Padding cho nội dung
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
                            // Welcome message
                            Text(
                              'Welcome back',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 80),

                            // Email textfield
                            MyTextfield(
                              placeHolder: "Email",
                              controller: _emailController,
                            ),
                            const SizedBox(height: 20),
                            // Password textfield
                            MyTextfield(
                              isPassword: true,
                              placeHolder: "Mật khẩu",
                              controller: _passwordController,
                            ),
                            _savePassForgotPassword(),
                            const SizedBox(height: 10),
                            MyButton(
                              fontsize: 16,
                              paddingText: 16,
                              text: 'ĐĂNG NHẬP',
                              onTap: () => _onLoginButtonPressed(context),
                            ),
                            const SizedBox(height: 40),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await ApiService();
                                  },
                                  icon: Image.asset(
                                    'assets/images/logo_google.png',
                                    width: 26,
                                    height: 26,
                                  ),
                                  label: const Text(
                                    'Google',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Handle Facebook login
                                  },
                                  icon: Image.asset(
                                    'assets/images/logo_facebook.png',
                                    width: 23,
                                    height: 23,
                                  ),
                                  label: const Text('Facebook'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Social Media Buttons

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
                          padding: const EdgeInsets.symmetric(
                              vertical: 0), // Padding dọc cho Row
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Chưa có tài khoản?'),
                              SizedBox(width: 5),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SlideFromRightPageRoute(
                                        page: RegisterPage()),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Text(
                                    'Đăng ký',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0XFF6F3CD7)),
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

  Widget _savePassForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _savePassword,
              onChanged: (bool? value) {
                setState(() {
                  _savePassword = value ?? false;
                });
              },
            ),
            const Text('Lưu mật khẩu'),
          ],
        ),
        TextButton(
          onPressed: () {
            // TODO: Handle forgot password action
            print('Quên mật khẩu');
          },
          child: const Text('Quên mật khẩu?'),
        ),
      ],
    );
  }
}
