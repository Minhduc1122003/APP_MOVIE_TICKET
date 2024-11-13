import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/spinkit.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/forgot_page/forgot_page.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/pages/login_page/loginBloc/login_bloc.dart';
import 'package:flutter_app_chat/pages/manager_page/home_manager_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../components/my_button.dart';
import '../../components/my_textfield.dart';
import '../register_page/register_page.dart';

class LoginPage extends StatefulWidget {
  final bool isBack;

  LoginPage({this.isBack = false});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
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
                Color(0xFF6439FF),
              ],
              stops: [0.66],
              begin: Alignment.topCenter,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) async {
          if (state is LoginError) {
            hideLoadingSpinner(context);

            EasyLoading.showError('Sai tài khoản hoặc mật khẩu');
          } else if (state is LoginWaiting) {
            showLoadingSpinner(context);
          } else if (state is LoginSuccess) {
            // Fetch data after successful login
            if (widget.isBack) {
              Navigator.of(context).pop();
            } else {
              if (UserManager.instance.user?.role == 0) {
                ApiService apiService = ApiService();
                final moviesDangChieu = await apiService.getMoviesDangChieu();
                final moviesSapChieu = await apiService.getMoviesSapChieu();
                hideLoadingSpinner(context);

                Navigator.pushAndRemoveUntil(
                  context,
                  SlideFromLeftPageRoute(
                      page: HomePage(
                    filmDangChieu: moviesDangChieu,
                    filmSapChieu: moviesSapChieu,
                  )),
                  (Route<dynamic> route) =>
                      false, // Xóa tất cả các route trước đó
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  ZoomPageRoute(page: HomeTab()),
                  (Route<dynamic> route) => false,
                );
              }
            }
          }
        },
        child: Stack(
          children: [
            // Background gradient
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x0FF6439FF),
                    Color(0xFFF7CF5FF),
                  ],
                  stops: [0.10, 1],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Welcome message

// Welcome message
// Welcome message
// Welcome message
            Transform.translate(
              offset: Offset(0, -150), // Di chuyển container lên 100px
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      ColorFiltered(
                        colorFilter:
                            ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        child: Image.asset(
                          'assets/images/logoText.png',
                          width: 450,
                          height: 450,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, -170),
                        child: const Text(
                          'Chào mừng bạn quay trở lại...',
                          style: TextStyle(
                            color: Colors.white, // Đảm bảo màu sắc khác biệt
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                            height: 2.0,
                            decoration: TextDecoration.none,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center, // Căn giữa văn bản
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                                icon: Icons
                                    .email_outlined, // Hiển thị biểu tượng người ở bên trái
                              ),
                              const SizedBox(height: 20),
                              MyTextfield(
                                isPassword: true,
                                placeHolder: "Mật khẩu",
                                controller: _passwordController,
                                icon: Icons
                                    .lock_outline, // Hiển thị biểu tượng người ở bên trái
                              ),
                              const SizedBox(height: 20),
                              MyButton(
                                fontsize: 18,
                                paddingText: 16,
                                text: 'ĐĂNG NHẬP',
                                onTap: () => _onLoginButtonPressed(context),
                              ),
                              const SizedBox(height: 10),
                              _ForgotPassword(context),
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
            if (bottomInset == 0)
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
                          label: const Text(
                            'Facebook',
                            style: TextStyle(color: Colors.black),
                          ),
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
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
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
                                  color: Color(0xFF4F75FF),
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
            // if (_isLoading)
            //   const Positioned.fill(
            //     child: Center(
            //       child: SpinKitSpinningLines(
            //         color: Color(0xe06f3cd7), // Màu sắc của spinner
            //         size: 50.0, // Kích thước của spinner
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _ForgotPassword(BuildContext context) {
    return Row(
      children: [
        Expanded(
          // Đảm bảo nút chiếm toàn bộ chiều rộng
          child: TextButton(
            onPressed: () {
              // Điều hướng tới trang ForgotPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgotPage()),
              );
            },
            style: TextButton.styleFrom(
              side: const BorderSide(
                color: Color(0xFF4F75FF), // Màu viền
                width: 1.0, // Độ dày viền
              ),
            ),
            child: const Text(
              'Quên mật khẩu?',
              style: TextStyle(color: Color(0xFF4F75FF)),
            ),
          ),
        ),
      ],
    );
  }
}
