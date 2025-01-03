import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/components/spinkit.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/pages/manager_page/home_manager_page.dart';
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
  ApiService apiService = ApiService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _checkPassword = TextEditingController();

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _lastnameFocusNode = FocusNode();
  final FocusNode _firstnameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _checkPasswordFocusNode = FocusNode();
  Timer? _debounceTimer;
  bool _isCheckingUsername = false;
  Timer? _usernameDebouncer;
  String? _usernameError;

  String generateSuggestedUsername(String firstName, String lastName) {
    if (firstName.isEmpty || lastName.isEmpty) return '';

    // Chuẩn hóa và loại bỏ dấu
    String normalizedFirstName =
        removeDiacritics(firstName.trim().toLowerCase());
    String normalizedLastName = removeDiacritics(lastName.trim().toLowerCase());

    // Tách tên thành các phần và lấy phần cuối
    String lastPartOfFirstName = '';
    if (normalizedFirstName.contains(' ')) {
      List<String> parts = normalizedFirstName.split(' ');
      lastPartOfFirstName = parts.last; // Lấy phần tử cuối cùng của mảng
    } else {
      lastPartOfFirstName = normalizedFirstName;
    }

    // Lấy chữ cái đầu của họ
    String firstLetterOfLastName = normalizedLastName[0];

    // Kết hợp theo format: [từ cuối của tên][chữ cái đầu của họ]
    return '$lastPartOfFirstName$firstLetterOfLastName';
  }

  // Hàm bỏ dấu tiếng Việt
  String removeDiacritics(String text) {
    final diacritics = {
      'a': 'áàảãạâấầẩẫậăắằẳẵặ',
      'e': 'éèẻẽẹêếềểễệ',
      'i': 'íìỉĩị',
      'o': 'óòỏõọôốồổỗộơớờởỡợ',
      'u': 'úùủũụưứừửữự',
      'y': 'ýỳỷỹỵ',
      'd': 'đ',
      // Thêm chữ hoa
      'A': 'ÁÀẢÃẠÂẤẦẨẪẬĂẮẰẲẴẶ',
      'E': 'ÉÈẺẼẸÊẾỀỂỄỆ',
      'I': 'ÍÌỈĨỊ',
      'O': 'ÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢ',
      'U': 'ÚÙỦŨỤƯỨỪỬỮỰ',
      'Y': 'ÝỲỶỸỴ',
      'D': 'Đ',
      // Các ký tự đặc biệt khác
      '': ' -_.,@#%^&*()+=[]{}|\\/<>?!\'"`~:;' // Loại bỏ các ký tự đặc biệt
    };

    String result = text;

    // Xử lý các ký tự có dấu
    diacritics.forEach((key, value) {
      for (var letter in value.split('')) {
        result = result.replaceAll(letter, key);
      }
    });

    result = result.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ');

    return result.toLowerCase(); // Chuyển tất cả về chữ thường
  }

  void showEmailExistsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thông báo'),
        content: Text('Email đã tồn tại. Vui lòng sử dụng email khác!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void checkAndSuggestUsername() {
    _debounceTimer?.cancel();

    if (_firstnameController.text.isNotEmpty &&
        _lastnameController.text.isNotEmpty) {
      _debounceTimer = Timer(const Duration(milliseconds: 2000), () async {
        String suggestedUsername = generateSuggestedUsername(
            _firstnameController.text, _lastnameController.text);

        if (suggestedUsername.isEmpty) return;

        print('Generated username: $suggestedUsername');

        setState(() {
          _isCheckingUsername = true;
          if (_usernameController.text.isEmpty) {
            _usernameController.text = suggestedUsername;
          }
        });

        try {
          String result = await apiService.checkUsername(suggestedUsername);
          if (result.contains("exists")) {
            // Nếu username đã tồn tại và trường username đang hiển thị username được đề xuất
            if (_usernameController.text == suggestedUsername) {
              int random = Random().nextInt(999) + 1;
              String newUsername = '$suggestedUsername$random';
              _usernameController.text = newUsername;
            }
          }
        } catch (e) {
          print('Error checking username: $e');
        } finally {
          setState(() {
            _isCheckingUsername = false;
          });
        }
      });
    }
  }

  // Tạo một Map để lưu trữ các lỗi
  Map<String, String?> errorMessages = {
    'email': null,
    'code': null,
    'lastname': null,
    'firstname': null,
    'username': null,
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
    final String username = _usernameController.text;

    // Validate inputs
    if (email.isEmpty ||
        password.isEmpty ||
        username.isEmpty ||
        lastname.isEmpty ||
        firstname.isEmpty == 0) {
      EasyLoading.showError("Vui lòng điền đầy đủ thông tin!");
      return;
    }
  }

  // Hàm kiểm tra lỗi cho các trường văn bản
  bool _validateFields() {
    setState(() {
      errorMessages['email'] = _emailController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : null;
      errorMessages['lastname'] = _lastnameController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : null;
      errorMessages['firstname'] = _firstnameController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : null;
      errorMessages['username'] = _usernameController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : errorMessages['username']; // Không ghi đè lỗi đã có sẵn

      errorMessages['password'] = _passwordController.text.isEmpty
          ? 'Thông tin bạn điền chưa đầy đủ'
          : null;
    });

    // Kiểm tra mật khẩu nhập lại
    if (_passwordController.text != _checkPassword.text) {
      errorMessages['password'] = 'Mật khẩu nhập lại chưa đúng';
    } else if (_passwordController.text.isNotEmpty) {
      errorMessages['password'] = null; // Xóa lỗi nếu mật khẩu khớp
    }

    // Trả về false nếu có bất kỳ lỗi nào
    return errorMessages.values.every((error) => error == null);
  }

  void _checkCode() {
    final String passwordConfirm = _codeController.text;
    isCodeNotifier.value = codeIs == _codeController.text;
  }

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_checkCode);
    _checkPasswordFocusNode.addListener(() {
      if (!_checkPasswordFocusNode.hasFocus) {
        _validatePasswordMatch(); // Validate password match when focus is lost
      }
    });
    _lastnameController.addListener(() {
      checkAndSuggestUsername();
    });
    _firstnameController.addListener(() {
      checkAndSuggestUsername();
    });
    // Thêm listener cho username textfield
    _usernameController.addListener(() {
      _usernameDebouncer?.cancel();

      if (_usernameController.text.isNotEmpty) {
        setState(() {
          _isCheckingUsername = true;
        });

        _usernameDebouncer = Timer(const Duration(milliseconds: 2), () async {
          try {
            String result =
                await apiService.checkUsername(_usernameController.text);
            setState(() {
              _isCheckingUsername = false;
              if (result.contains("exists") || result.contains("tồn tại")) {
                _usernameError = "Username đã tồn tại";
                errorMessages['username'] = _usernameError;
              } else {
                _usernameError = null;
                errorMessages['username'] = null;
              }
            });
          } catch (e) {
            setState(() {
              _isCheckingUsername = false;
              _usernameError = null;
              errorMessages['username'] = null;
            });
          }
        });
      } else {
        setState(() {
          _isCheckingUsername = false;
          _usernameError = null;
          errorMessages['username'] = null;
        });
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
    _debounceTimer?.cancel();
    _firstnameController.removeListener(checkAndSuggestUsername);
    _lastnameController.removeListener(checkAndSuggestUsername);
    _debounceTimer?.cancel();
    _usernameDebouncer?.cancel();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _usernameController.dispose();
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
                                      controller: _lastnameController,
                                      sendCode: false,
                                      focusNode: _lastnameFocusNode,
                                      errorMessage: errorMessages['lastname'],
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          10), // Khoảng cách giữa 2 textfield
                                  Expanded(
                                    child: MyTextfield(
                                      isPassword: false,
                                      placeHolder: "Tên",
                                      controller: _firstnameController,
                                      sendCode: false,
                                      focusNode: _firstnameFocusNode,
                                      errorMessage: errorMessages['firstname'],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              MyTextfield(
                                isPassword: false,
                                placeHolder: "Username",
                                controller: _usernameController,
                                focusNode: _usernameFocusNode,
                                errorMessage: errorMessages['username'],
                                icon: Icons.person,
                                suffix: _isCheckingUsername
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<
                                                  Color>(
                                              Theme.of(context).primaryColor),
                                        ),
                                      )
                                    : null,
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
                                  String email = _emailController
                                      .text; // Lấy email từ TextField
                                  try {
                                    bool emailExists =
                                        await apiService.checkEmail(email);

                                    if (emailExists) {
                                      showEmailExistsDialog(context);
                                    } else {
                                      // Nếu email không tồn tại, thực hiện logic đăng ký ở đây
                                      if (_validateFields()) {
                                        try {
                                          BlocProvider.of<SendCodeBloc>(context)
                                              .add(SendCode('', '',
                                                  _emailController.text));

                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Nhập mã xác nhận'),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ValueListenableBuilder<
                                                          bool>(
                                                        valueListenable:
                                                            isCodeNotifier,
                                                        builder: (context,
                                                            isCode, child) {
                                                          return MyTextfield(
                                                            isPassword: false,
                                                            placeHolder:
                                                                "Mã xác nhận",
                                                            controller:
                                                                _codeController,
                                                            sendCode: false,
                                                            isCode: isCode,
                                                            focusNode:
                                                                _codeFocusNode,
                                                            errorMessage:
                                                                errorMessages[
                                                                    'code'],
                                                            icon: Icons
                                                                .privacy_tip_outlined,
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: Text('Hủy'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Xác nhận'),
                                                    onPressed: () async {
                                                      if (_codeController
                                                          .text.isEmpty) {
                                                        EasyLoading.showError(
                                                            "Vui lòng nhập mã xác nhận!");
                                                        isCodeNotifier.value =
                                                            false; // Hiển thị x đỏ
                                                      } else if (_codeController
                                                              .text ==
                                                          codeIs) {
                                                        isCodeNotifier.value =
                                                            true; // Hiển thị tích xanh
                                                        try {
                                                          final String
                                                              CreateAccount =
                                                              await apiService
                                                                  .createAccount(
                                                            _emailController
                                                                .text,
                                                            _passwordController
                                                                .text,
                                                            _usernameController
                                                                .text,
                                                            "${_lastnameController.text} ${_firstnameController.text}",
                                                            '',
                                                          );

                                                          if (CreateAccount ==
                                                              'Account created successfully') {
                                                            EasyLoading.showSuccess(
                                                                "Đăng ký thành công!");
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Đóng dialog
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Đóng dialog
                                                          }
                                                        } catch (e) {
                                                          EasyLoading.showError(
                                                              "Đăng ký thất bại: ${e.toString()}");
                                                        }
                                                      } else {
                                                        EasyLoading.showError(
                                                            "Mã xác nhận không đúng!");
                                                        isCodeNotifier.value =
                                                            false; // Hiển thị x đỏ
                                                      }
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } catch (e) {
                                          EasyLoading.showError(
                                              "Có lỗi xảy ra: ${e.toString()}");
                                        }
                                      } else {
                                        EasyLoading.showError(
                                            "Vui lòng điền đúng thông tin!");
                                      }
                                    }
                                  } catch (e) {
                                    print('Lỗi khi kiểm tra email: $e');
                                  }
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
