import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/components/my_customIcon_keyboad_left.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/pages/login_page/login_page.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/pages/register_page/register_page_2.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _savePassword = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String codeIs = "1"; // Khai báo biến để lưu mã code
  ValueNotifier<bool> isCodeNotifier =
      ValueNotifier(false); // Khai báo ValueNotifier

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự thay đổi của _codeController
    _codeController.addListener(_checkCode);
  }

  @override
  void dispose() {
    _codeController.removeListener(_checkCode);
    _codeController.dispose();
    isCodeNotifier.dispose();
    super.dispose();
  }

  void _checkCode() {
    print('_codeController đã thay đổi: ${_codeController.text}');
    isCodeNotifier.value = (_codeController.text == codeIs) ? true : false;
    print('value đã thay đổi: ${isCodeNotifier.value}');
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<SendCodeBloc, SendCodeState>(
        listener: (context, state) async {
          if (state is SendCodeError) {
            print('login LoginError');
            EasyLoading.showError('Sai tài khoản hoặc mật khẩu');
          } else if (state is SendCodeWaiting) {
            EasyLoading.show(status: 'Loading...');
          } else if (state is SendCodeSuccess) {
            final codeIS = state.code;
            setState(() {
              codeIs = codeIS!; // Gán giá trị của mã code cho biến codeIs
              _checkCode(); // Cập nhật giá trị isCodeNotifier
            });
            EasyLoading.showSuccess(
                "Đã gửi mã đến địa chỉ ${_emailController?.text}!");
            print('Mã code: $codeIS');

            await Future.delayed(Duration(milliseconds: 150));
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
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {},
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
                padding: EdgeInsets.fromLTRB(20, 80, 20, 0),
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
                              'Chào mừng bạn đến với PANTHERs Cinema!',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Điền các thông tin để hoàn tất việc đăng ký.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            // email textfield
                            SizedBox(height: 40),
                            MyTextfield(
                              isPassword: false,
                              placeHolder: "Nhập địa chỉ email",
                              controller: _emailController,
                              sendCode: true,
                            ),
                            const SizedBox(height: 20),
                            ValueListenableBuilder<bool>(
                              valueListenable: isCodeNotifier,
                              builder: (context, isCode, child) {
                                return MyTextfield(
                                  isPassword: false,
                                  placeHolder: "Mã xác nhận",
                                  controller: _codeController,
                                  sendCode: false,
                                  isCode: isCode,
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            MyTextfield(
                                isPassword: true,
                                placeHolder: "Mật khẩu",
                                controller: _passwordController,
                                sendCode: false),

                            const SizedBox(height: 40),
                            MyButton(
                                fontsize: 16,
                                paddingText: 16,
                                text: 'TIẾP TỤC',
                                showIcon: true,
                                onTap: () async {
                                  EasyLoading.show(status: 'Loading...');
                                  if (codeIs == _codeController.text) {
                                    EasyLoading.dismiss();
                                    await Future.delayed(
                                        Duration(milliseconds: 200));
                                    EasyLoading.show();

                                    Navigator.push(
                                      context,
                                      SlideFromRightPageRoute(
                                          page: RegisterPage2(
                                        email: _emailController!.text,
                                        password: _passwordController!.text,
                                      )),
                                    );
                                    EasyLoading.dismiss();
                                  } else {
                                    await Future.delayed(
                                        Duration(milliseconds: 200));
                                    EasyLoading.dismiss();

                                    EasyLoading.showError(
                                        ("Mã xác nhận không đúng!"));
                                  }
                                }),
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
                                  Navigator.pop(context);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Text(
                                    'Đăng nhập',
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
}
