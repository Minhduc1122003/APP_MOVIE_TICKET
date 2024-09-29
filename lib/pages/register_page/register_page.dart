import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/pages/login_page/login_page.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'createAccount_bloc/createAccount_bloc.dart';

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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _fullnameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  // Tạo một Map để lưu trữ các lỗi
  Map<String, String?> errorMessages = {
    'email': null,
    'code': null,
    'username': null,
    'fullname': null,
    'phone': null,
    'password': null,
  };
  String codeIs = "1"; // Placeholder for the code received
  ValueNotifier<bool> isCodeNotifier =
      ValueNotifier(false); // Notifier for code matching

  // Trigger the Create Account Bloc event
  void onCreateAccountPressed(BuildContext context) {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String username = _usernameController.text;
    final String fullname = _fullnameController.text;
    final int phoneNumber = int.tryParse(_phoneController.text) ?? 0;
    final String photo = '';

    // Validate inputs
    if (email.isEmpty ||
        password.isEmpty ||
        username.isEmpty ||
        fullname.isEmpty ||
        phoneNumber == 0) {
      EasyLoading.showError("Vui lòng điền đầy đủ thông tin!");
      return;
    }

    BlocProvider.of<CreateAccountBloc>(context).add(
      CreateAccount(email, password, username, fullname, phoneNumber, photo),
    );
  }

  // Check if the entered code matches the received one
  void _checkCode() {
    isCodeNotifier.value = (_codeController.text == codeIs);
  }

  // Hàm kiểm tra lỗi cho các trường văn bản
  bool _validateFields() {
    setState(() {
      errorMessages['email'] = _emailController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : null;
      errorMessages['code'] = _codeController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : null;
      errorMessages['username'] = _usernameController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : null;
      errorMessages['fullname'] = _fullnameController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : null;
      errorMessages['phone'] = _phoneController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : null;
      errorMessages['password'] = _passwordController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : null;
    });

    return errorMessages.values.every((error) => error == null);
  }

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_checkCode); // Listen to code changes
  }

  @override
  void dispose() {
    _codeController.removeListener(_checkCode);
    _codeController.dispose();
    isCodeNotifier.dispose();
    _emailFocusNode.dispose();
    _codeFocusNode.dispose();
    _usernameFocusNode.dispose();
    _fullnameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xe06f3cd7),
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
          if (state is SendCodeError) {
            EasyLoading.showError('Sai tài khoản hoặc mật khẩu');
          } else if (state is SendCodeWaiting) {
            EasyLoading.show(status: 'Loading...');
          } else if (state is SendCodeSuccess) {
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xe06f3cd7),
                          Color(0xe0ffffff),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
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
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0,
                                10), // Thêm padding đều cho tất cả các cạnh
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
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0,
                                20), // Thêm padding theo hướng tùy chỉnh
                            child: Text(
                              'Hãy điền các thông tin còn thiếu để hoàn tất việc đăng ký',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
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
                        20,
                        50,
                        20,
                        MediaQuery.of(context)
                            .viewInsets
                            .bottom, // Điều chỉnh với chiều cao của bàn phím
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          MyTextfield(
                            isPassword: false,
                            placeHolder: "Nhập địa chỉ email",
                            controller: _emailController,
                            sendCode: true,
                            focusNode: _emailFocusNode,
                            errorMessage: errorMessages['email'],
                          ),
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
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          MyTextfield(
                            isPassword: false,
                            placeHolder: "Tên người dùng",
                            controller: _usernameController,
                            sendCode: false,
                            focusNode: _usernameFocusNode,
                            errorMessage: errorMessages['username'],
                          ),
                          const SizedBox(height: 10),
                          MyTextfield(
                            isPassword: false,
                            placeHolder: "Họ tên",
                            controller: _fullnameController,
                            sendCode: false,
                            focusNode: _fullnameFocusNode,
                            errorMessage: errorMessages['fullname'],
                          ),
                          const SizedBox(height: 10),
                          MyTextfield(
                            isPassword: false,
                            placeHolder: "Số điện thoại",
                            controller: _phoneController,
                            sendCode: false,
                            isPhone: true,
                            focusNode: _phoneFocusNode,
                            errorMessage: errorMessages['phone'],
                          ),
                          const SizedBox(height: 10),
                          MyTextfield(
                            isPassword: true,
                            placeHolder: "Mật khẩu",
                            controller: _passwordController,
                            sendCode: false,
                            focusNode: _passwordFocusNode,
                            errorMessage: errorMessages['password'],
                          ),
                          const SizedBox(height: 20),
                          MyButton(
                            fontsize: 16,
                            paddingText: 16,
                            text: 'HOÀN TẤT',
                            showIcon: false,
                            onTap: () async {
                              if (_validateFields()) {
                                EasyLoading.show(status: 'Loading...');
                                if (codeIs == _codeController.text) {
                                  EasyLoading.dismiss();
                                  await Future.delayed(
                                    const Duration(milliseconds: 200),
                                  );
                                  EasyLoading.show();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    SlideFromRightPageRoute(
                                        page: LoginPage(
                                      isBack: true,
                                    )),
                                    (Route<dynamic> route) => false,
                                  );
                                  EasyLoading.dismiss();
                                } else {
                                  EasyLoading.dismiss();
                                  EasyLoading.showError(
                                      "Mã xác nhận không đúng!");
                                }
                              } else {
                                EasyLoading.showError(
                                    'Thông tin bạn điền chưa đầy đủ');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
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
                                    color: Color(0XFF6F3CD7),
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
