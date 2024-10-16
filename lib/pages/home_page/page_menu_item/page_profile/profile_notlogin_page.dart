import 'package:flutter/material.dart';
import 'package:flutter_app_chat/components/my_InfoCard.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/components/my_customIcon_keyboad_left.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/pages/login_page/login_page.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/pages/register_page/register_page_2.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ProfileNotloginPage extends StatefulWidget {
  const ProfileNotloginPage({super.key});

  @override
  State<ProfileNotloginPage> createState() => _ProfileNotLoginPage();
}

class _ProfileNotLoginPage extends State<ProfileNotloginPage> {
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

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
          automaticallyImplyLeading: false,
          title: Text(
            'Trang cá nhân',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
        ),
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

              // Main content
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                              buildUserInfoCard(),
                              UtilitySection(
                                title: 'Trợ giúp & hỗ trợ',
                                buttons: [
                                  UtilityButton(
                                    color: Colors.pink,
                                    title: 'Trung tâm trợ giúp',
                                    icon: Icons.help_center,
                                    onPressed: () {},
                                  ),
                                  UtilityButton(
                                    color: Colors.pink,
                                    title: 'Điều khoản & chính sách',
                                    icon: Icons.policy,
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              UtilitySection(
                                title: 'Cài đặt chung',
                                buttons: [
                                  UtilityButton(
                                    trailingIconType: TrailingIconType.toggle,
                                    color: Colors.pink,
                                    title: 'Chế độ tối',
                                    icon: Icons.dark_mode,
                                    onPressed: () {},
                                  ),
                                  UtilityButton(
                                    trailingIconType: TrailingIconType.toggle,
                                    color: Colors.pink,
                                    title: 'Ngôn ngữ',
                                    icon: Icons.language,
                                    isToggled: true,
                                    onPressed: () {
                                      print("Nút 'Ngôn ngữ' đã được nhấn");
                                    },
                                    onToggleChanged: (bool newState) {
                                      print(
                                          "Trạng thái toggle đã thay đổi: $newState");
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: MyButton(
                                  fontsize: 16,
                                  paddingText: 16,
                                  text: 'ĐĂNG NHẬP',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SlideFromRightPageRoute(
                                          page: LoginPage()),
                                    );
                                  },
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
      ),
    );
  }

  Widget buildUserInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Bạn chưa đăng nhập',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            'Vui lòng bấm đăng nhập hoặc đăng ký để trải nghiệm dịch vụ của',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            'PANTHERs CINEMA!',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0XFF6F3CD7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
