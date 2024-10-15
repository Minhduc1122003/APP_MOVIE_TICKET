import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
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
    if (email.isEmpty ||
        password.isEmpty ||
        lastname.isEmpty ||
        firstname.isEmpty == 0) {
      EasyLoading.showError("Vui lòng điền đầy đủ thông tin!");
      return;
    }

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
    setState(() {
      errorMessages['email'] = _emailController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : null;
      errorMessages['code'] = _codeController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : null;
      errorMessages['lastname'] = _lastnameController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : null;
      errorMessages['firstname'] = _firstnameController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : null;

      errorMessages['password'] = _passwordController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : null;
    });
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
    // _codeController.removeListener(_checkCode);
    // _checkPasswordFocusNode.dispose(); // Dispose of the focus node
    // _codeController.dispose();
    // isCodeNotifier.dispose();
    // _emailFocusNode.dispose();
    // _codeFocusNode.dispose();
    // _lastnameFocusNode.dispose();
    // _firstnameFocusNode.dispose();
    // _passwordFocusNode.dispose();
    // _checkPassword.dispose();
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
                    height: 240,
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
                    child: Column(
                      children: [
                        Transform.translate(
                          offset:
                              Offset(0, -80), // Di chuyển container lên 100px
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Column(
                                children: [
                                  ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                          Colors.white, BlendMode.srcIn),
                                      child: Image.asset(
                                        'assets/images/logoText2.png',
                                        width: 200, // Đặt chiều rộng tối đa
                                        height: 200, // Đặt chiều rộng tối đa
                                      )),
                                  Transform.translate(
                                    offset: Offset(0, -30),
                                    child: const Text(
                                      'Đăng ký tài khoản',
                                      style: TextStyle(
                                        color: Colors
                                            .white, // Đảm bảo màu sắc khác biệt
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.1,
                                        height: 2.0,
                                        decoration: TextDecoration.none,
                                        fontStyle: FontStyle.normal,
                                      ),
                                      textAlign:
                                          TextAlign.center, // Căn giữa văn bản
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        15,
                        10,
                        15,
                        20, // Điều chỉnh với chiều cao của bàn phím
                      ),
                      child: Center(
                        child: Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: [
                                  Expanded(
                                    child: MyTextfield(
                                      isPassword: false,
                                      placeHolder: "Họ",
                                      controller: _firstnameController,
                                      sendCode: false,
                                      focusNode: _firstnameFocusNode,
                                      errorMessage: errorMessages['firstname'],
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          10), // Khoảng cách giữa 2 textfield
                                  Expanded(
                                    child: MyTextfield(
                                      isPassword: false,
                                      placeHolder: "Tên",
                                      controller: _lastnameController,
                                      sendCode: false,
                                      focusNode: _lastnameFocusNode,
                                      errorMessage: errorMessages['lastname'],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              MyTextfield(
                                isPassword: false,
                                placeHolder: "Email",
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                errorMessage: errorMessages['email'],
                                icon: Icons.email_outlined,
                              ),
                              const SizedBox(height: 10),
                              MyTextfield(
                                isPassword: true,
                                placeHolder: "Mật khẩu",
                                controller: _passwordController,
                                sendCode: false,
                                focusNode: _passwordFocusNode,
                                errorMessage: errorMessages['password'],
                                icon: Icons.lock_outline,
                              ),
                              const SizedBox(height: 10),
                              MyTextfield(
                                isPassword: true,
                                placeHolder: "Nhập lại mật khẩu",
                                controller: _checkPassword,
                                sendCode: false,
                                focusNode: _checkPasswordFocusNode,
                                errorMessage: errorMessages['password'],
                                icon: Icons.lock_outline,
                              ),
                              const SizedBox(height: 30),
                              MyButton(
                                fontsize: 16,
                                paddingText: 16,
                                text: 'Đăng ký',
                                showIcon: false,
                                onTap: () async {
                                  Navigator.push(
                                    context,
                                    SlideFromRightPageRoute(
                                        page: RegisterPage2()),
                                    // (Route<dynamic> route) => false,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
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
