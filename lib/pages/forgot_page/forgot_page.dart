import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/pages/login_page/login_page.dart';

class ForgotPage extends StatefulWidget {
  const ForgotPage({super.key});

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _passwordConfirmFocusNode = FocusNode();
  late ApiService _APIService = ApiService();

  Map<String, String?> errorMessages = {
    'email': null,
    'code': null,
    'password': null,
    'passwordConfirm': null,
  };

  String codeIs = "1"; // Placeholder for the code received
  ValueNotifier<bool> isCodeNotifier =
      ValueNotifier(false); // Notifier for code matching

  void _checkCode() {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String passwordConfirm = _passwordConfirmController.text;
    isCodeNotifier.value = codeIs == _codeController.text;
  }

  bool _validateFields() {
    setState(() {
      errorMessages['email'] =
          _emailController.text.isEmpty ? 'Vui lòng nhập email' : null;
      errorMessages['code'] =
          _codeController.text.isEmpty ? 'Vui lòng nhập mã xác nhận' : null;
      errorMessages['password'] = _passwordController.text.isEmpty
          ? 'Vui lòng nhập mật khẩu mới'
          : null;
      errorMessages['passwordConfirm'] = _passwordConfirmController.text.isEmpty
          ? 'Vui lòng nhập lại mật khẩu mới'
          : null;

      // Check if passwords match
      if (_passwordController.text != _passwordConfirmController.text) {
        errorMessages['passwordConfirm'] = 'Mật khẩu không khớp';
      } else if (_passwordController.text.isNotEmpty &&
          _passwordConfirmController.text.isNotEmpty) {
        errorMessages['passwordConfirm'] =
            null; // Clear the error if passwords match
      }
    });

    return errorMessages.values.every((error) => error == null);
  }

  Future<void> changePasswordForEmail() async {
    try {
      EasyLoading.show(status: 'Đang lưu...'); // Hiển thị thông báo đang lưu

      final email = _emailController.text;
      final password = _passwordController.text;

      // Call the API to update user info
      final response =
          await _APIService.changePasswordForEmail(email, password);

      EasyLoading.showSuccess(response); // Hiển thị thông báo thành công
    } catch (e) {
      EasyLoading.showError('Lỗi: $e'); // Hiển thị thông báo lỗi
    } finally {
      // Đảm bảo luôn ẩn EasyLoading sau khi xử lý xong
      Future.delayed(Duration(seconds: 2), () {
        EasyLoading.dismiss();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_checkCode);
  }

  @override
  void dispose() {
    _codeController.removeListener(_checkCode);
    _codeController.dispose();
    _emailController.dispose();
    isCodeNotifier.dispose();
    _emailFocusNode.dispose();
    _codeFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfirmFocusNode.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
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
                              'Hãy điền để hoàn tất việc đổi mật khẩu',
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
                                placeHolder: "Mã code",
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
                            isPassword: true,
                            placeHolder: "Mật khẩu mới",
                            controller: _passwordController,
                            sendCode: false,
                            focusNode: _passwordFocusNode,
                            errorMessage: errorMessages['password'],
                          ),
                          const SizedBox(height: 10),
                          MyTextfield(
                            isPassword: true,
                            placeHolder: "Xác nhận mật khẩu",
                            controller: _passwordConfirmController,
                            sendCode: false,
                            focusNode: _passwordConfirmFocusNode,
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
                                EasyLoading.show(status: 'Đang xử lý...');
                                if (codeIs == _codeController.text) {
                                  try {
                                    await changePasswordForEmail();
                                    EasyLoading.dismiss();
                                    EasyLoading.showSuccess(
                                        "Đổi mật khẩu thành công!");
                                    Navigator.push(
                                      context,
                                      SlideFromRightPageRoute(
                                        page: LoginPage(),
                                      ),
                                    );
                                  } catch (e) {
                                    EasyLoading.dismiss();
                                    EasyLoading.showError(
                                        "Đổi mật khẩu thất bại: $e");
                                  }
                                } else {
                                  EasyLoading.dismiss();
                                  EasyLoading.showError(
                                      "Mã xác nhận không đúng!");
                                }
                              } else {
                                EasyLoading.showError(
                                    'Thông tin chưa đúng. Vui lòng kiểm tra lại');
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
