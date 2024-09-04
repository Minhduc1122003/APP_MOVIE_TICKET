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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    _emailController.text = 'orcinus10';
    _passwordController.text = '123123';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          'Đăng nhập',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
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
            Navigator.pushAndRemoveUntil(
              context,
              ZoomPageRoute(page: HomePage()),
              (Route<dynamic> route) => false, // Xóa tất cả các route trước đó
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
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
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
                            Text(
                              'Welcome back',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 40),

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
                            const SizedBox(height: 20),

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
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Column(
                                children: [
                                  const Divider(
                                    height: 20,
                                    thickness: 1,
                                    indent: 20,
                                    endIndent: 20,
                                    color: Colors.black,
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                            ),
                          ],
                        ),
                      ),
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
