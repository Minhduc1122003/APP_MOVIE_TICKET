import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/pages/login_page/login_page.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../components/animation_page.dart';

class RegisterPage2 extends StatefulWidget {
  const RegisterPage2({super.key});

  @override
  State<RegisterPage2> createState() => _RegisterPageState2();
}

class _RegisterPageState2 extends State<RegisterPage2> {
  bool _savePassword = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _checkPassword = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _lastnameFocusNode = FocusNode();
  final FocusNode _firstnameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _checkPasswordFocusNode = FocusNode();

  // Tạo một Map để lưu trữ các lỗi
  Map<String, String?> errorMessages = {
    'email': null,
    'code': null,
    'lastname': null,
    'firstname': null,
    'password': null,
  };
  String codeIs = "1"; // Placeholder for the code received
  ValueNotifier<bool> isCodeNotifier =
      ValueNotifier(false); // Notifier for code matching

  // Trigger the Create Account Bloc event
  void onCreateAccountPressed(BuildContext context) {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String lastname = _lastnameController.text;
    final String firstname = _firstnameController.text;

    // Validate inputs

    //   BlocProvider.of<CreateAccountBloc>(context).add(
    //     CreateAccount(email, password, lastname, firstname),
    //   );
  }

  // Check if the entered code matches the received one
  void _checkCode() {
    isCodeNotifier.value = (_codeController.text == codeIs);
  }

  // Hàm kiểm tra lỗi cho các trường văn bản
  bool _validateFields() {
    setState(() {});
// Check if the passwords match
    if (_passwordController.text != _checkPassword.text) {
      errorMessages['password'] =
          'Mật khẩu nhập lại chưa đúng'; // Set error message
    } else if (_passwordController.text.isNotEmpty) {
      errorMessages['password'] =
          null; // Clear error message if passwords match
    }

    return errorMessages.values.every((error) => error == null);
  }

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_checkCode); // Listen to code changes\

    _checkPasswordFocusNode.addListener(() {
      if (!_checkPasswordFocusNode.hasFocus) {
        _validatePasswordMatch(); // Validate password match when focus is lost
      }
    });
  }

  void _validatePasswordMatch() {
    setState(() {
      if (_passwordController.text != _checkPassword.text) {
        errorMessages['password'] =
            'Mật khẩu nhập lại chưa đúng'; // Set error message
      } else {
        errorMessages['password'] = null; // Clear error message if they match
      }
    });
  }

  @override
  void dispose() {
    _codeController.removeListener(_checkCode);
    _checkPasswordFocusNode.dispose(); // Dispose of the focus node
    _codeController.dispose();
    isCodeNotifier.dispose();
    _emailFocusNode.dispose();
    _codeFocusNode.dispose();
    _lastnameFocusNode.dispose();
    _firstnameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _checkPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double bottomPadding = keyboardHeight > 0
        ? keyboardHeight + 20
        : 20; // Tính toán giá trị padding cho bottom

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0x0FF6439FF),
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
            size: 16,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: BlocListener<SendCodeBloc, SendCodeState>(
        listener: (context, state) async {
          if (state is SendCodeSuccess) {
            setState(() {
              codeIs = state.code!;
              _checkCode(); // Recheck the code after receiving it
            });
            EasyLoading.showSuccess(
                "Mã đã được gửi đến ${_emailController.text}!");
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x0FF6439FF), // Tím
                          Color(0xFF4F75FF), // Xanh ngọc
                          Color(0xFFFFFFFF), // Trắng
                        ],
                        stops: [0.0, 0.3, 1.0], // Phân bố đều hơn cho các màu
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                            child: Text(
                              'Chào mừng bạn đến với',
                              style: TextStyle(
                                color: Color(0xe0ffffff),
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                                height: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
                            child: Text(
                              'PANTHERs CINEMA!',
                              style: TextStyle(
                                color: Color(0xe0ffffff),
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                                height: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        15,
                        10,
                        15,
                        bottomPadding, // Sử dụng biến bottomPadding
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(height: 10),
                            ValueListenableBuilder<bool>(
                              valueListenable: isCodeNotifier,
                              builder: (context, isCode, child) {
                                return MyTextfield(
                                  isPassword: false,
                                  placeHolder: "Mã xác nhận",
                                  controller: _codeController,
                                  sendCode: false,
                                  isCode: isCode,
                                  focusNode: _codeFocusNode,
                                  errorMessage: errorMessages['code'],
                                  icon: Icons.privacy_tip_outlined,
                                );
                              },
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: MyButton(
                          fontsize: 16,
                          paddingText: 16,
                          text: 'Hoàn tất',
                          showIcon: false,
                          onTap: () async {
                            Navigator.push(
                              context,
                              SlideFromRightPageRoute(page: LoginPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (keyboardHeight == 0)
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
                              const SizedBox(width: 5),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4F75FF),
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
          ],
        ),
      ),
    );
  }
}
