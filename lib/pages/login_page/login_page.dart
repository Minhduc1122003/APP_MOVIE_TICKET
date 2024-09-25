import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/pages/login_page/loginBloc/login_bloc.dart';
import 'package:flutter_app_chat/pages/manager_page/home_manager_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../components/my_button.dart';
import '../../components/my_textfield.dart';
import '../register_page/register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _savePassword = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _onLoginButtonPressed(BuildContext context) {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    BlocProvider.of<LoginBloc>(context).add(Login(email, password));
  }

  @override
  void initState() {
    _emailController.text = 'minhduc1122003';
    _passwordController.text = '123123';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff6750a4),
                Color(0xffb2aad5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
        title: const Text(
          'Đăng nhập',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) async {
          if (state is LoginError) {
            EasyLoading.showError('Sai tài khoản hoặc mật khẩu');
          } else if (state is LoginWaiting) {
            EasyLoading.show();
          } else if (state is LoginSuccess) {
            EasyLoading.dismiss();
            await Future.delayed(const Duration(milliseconds: 150));
            if (UserManager.instance.user?.role == 0) {
              Navigator.pushAndRemoveUntil(
                context,
                ZoomPageRoute(page: HomePage()),
                (Route<dynamic> route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                ZoomPageRoute(page: HomeTab()),
                (Route<dynamic> route) => false,
              );
            }
          }
        },
        child: Stack(
          children: [
            // Background gradient
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xe06f3cd7),
                    Color(0xe8cfb3f6),
                  ],
                  stops: [0.66, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            // Welcome message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(30, 40, 50, 0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Chào mừng bạn quay lại với PANTHERs CINEMA!',
                  style: TextStyle(
                    color: const Color(0xf2ffffff),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                    height: 2.0,
                    decoration: TextDecoration.none,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            // Main login form container

            Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              MyTextfield(
                                placeHolder: "Email",
                                controller: _emailController,
                              ),
                              const SizedBox(height: 20),
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer that disappears when keyboard is visible
            if (bottomInset == 0) // Only show this when keyboard is not visible
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Xử lý đăng nhập Facebook
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
                    const Divider(
                      height: 20,
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.black,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Chưa có tài khoản?'),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                SlideFromRightPageRoute(
                                  page: RegisterPage(),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                'Đăng ký',
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
            print('Quên mật khẩu');
          },
          child: const Text('Quên mật khẩu?'),
        ),
      ],
    );
  }
}
