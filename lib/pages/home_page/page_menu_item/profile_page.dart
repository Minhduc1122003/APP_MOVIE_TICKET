import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/chat_service.dart';
import 'package:flutter_app_chat/components/my_customIcon_keyboad_left.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_chat/chat_online_page.dart';
import 'package:flutter_app_chat/pages/login_page/login_page.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../components/my_InfoCard.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  ValueNotifier<bool> isCodeNotifier =
      ValueNotifier(false); // Khai báo ValueNotifier
  late ChatService _chatService;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(); // Khởi tạo ChatService

    // Lắng nghe sự thay đổi của _codeController
  }

  @override
  void dispose() {
    _codeController.dispose();
    isCodeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFF6F3CD7),
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
            setState(() {});
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
                              title: 'Tiện ích',
                              buttons: [
                                UtilityButton(
                                  color: Colors.pink,
                                  title: 'Chat trực tuyến',
                                  icon: Icons
                                      .chat, // Thay đổi icon để phù hợp với "Trung tâm trợ giúp"
                                  onPressed: () {
                                    _chatService
                                        .connect(); // Kết nối khi khởi tạo

                                    Navigator.push(
                                      context,
                                      SlideFromRightPageRoute(
                                          page: ChatPage(
                                              userId: UserManager
                                                  .instance.user!.userId)),
                                    );
                                  },
                                ),
                              ],
                            ),
                            UtilitySection(
                              title: 'Trợ giúp & hỗ trợ',
                              buttons: [
                                UtilityButton(
                                  color: Colors.pink,
                                  title: 'Trung tâm trợ giúp',
                                  icon: Icons
                                      .help_center, // Thay đổi icon để phù hợp với "Trung tâm trợ giúp"
                                  onPressed: () {},
                                ),
                                UtilityButton(
                                  color: Colors.pink,
                                  title: 'Hộp thư trợ',
                                  icon: Icons
                                      .mail, // Thay đổi icon để phù hợp với "Hộp thư trợ"
                                  onPressed: () {},
                                ),
                                UtilityButton(
                                  color: Colors.pink,
                                  title: 'Báo cáo sự cố',
                                  icon: Icons
                                      .report_problem, // Thay đổi icon để phù hợp với "Báo cáo sự cố"
                                  onPressed: () {},
                                ),
                                UtilityButton(
                                  color: Colors.pink,
                                  title: 'Điều khoản & chính sách',
                                  icon: Icons
                                      .policy, // Thay đổi icon để phù hợp với "Điều khoản & chính sách"
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            UtilitySection(
                              title: 'Cài đặt & quyền riêng tư',
                              buttons: [
                                UtilityButton(
                                  color: Colors.pink,
                                  title: 'Trung tâm tài khoản',
                                  icon: Icons
                                      .account_circle, // Thay đổi icon để phù hợp với "Trung tâm tài khoản"
                                  onPressed: () {},
                                ),
                                UtilityButton(
                                  trailingIconType: TrailingIconType.toggle,

                                  color: Colors.pink,
                                  title: 'Chế độ tối',
                                  icon: Icons
                                      .dark_mode, // Giữ nguyên icon cho "Cài đặt chung"
                                  onPressed: () {},
                                ),
                                UtilityButton(
                                  trailingIconType: TrailingIconType
                                      .toggle, // Sử dụng kiểu toggle cho icon phía sau
                                  color: Colors.pink, // Màu của icon và toggle
                                  title: 'Ngôn ngữ', // Tiêu đề của nút
                                  icon: Icons.language, // Icon chính cho nút
                                  isToggled: true,
                                  onPressed: () {
                                    print("Nút 'Ngôn ngữ' đã được nhấn");
                                  },
                                  onToggleChanged: (bool newState) {
                                    print(
                                        "Trạng thái toggle đã thay đổi: $newState");
                                  },
                                ),
                                UtilityButton(
                                  color: Colors.pink,
                                  trailingIconType: TrailingIconType.none,
                                  title: 'Đăng xuất',
                                  icon: Icons.logout,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              const Text('Xác nhận đăng xuất'),
                                          content: const Text(
                                              'Bạn có muốn đăng xuất không?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                // Hành động khi người dùng nhấn "Không"

                                                Navigator.of(context)
                                                    .pop(); // Đóng hộp thoại
                                              },
                                              child: const Text('Hủy'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                EasyLoading.show();
                                                await Future.delayed(
                                                    const Duration(
                                                        milliseconds: 800));
                                                EasyLoading.dismiss();
                                                print(
                                                    'User đã tồn tại: ${UserManager.instance.user?.email}');
                                                UserManager.instance
                                                    .clearUser();
                                                print(
                                                    'User đã clear: ${UserManager.instance.user?.email}');
                                                Navigator.pushReplacement(
                                                    context,
                                                    SlideFromLeftPageRoute(
                                                        page: LoginPage()));
                                              },
                                              child: const Text(
                                                'Đăng xuất',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Các phần tử cố định ở cuối màn hình
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserInfoCard() {
    // Hàm để format số điện thoại từ int thành String
    String formatPhoneNumber(int? phoneNumber) {
      if (phoneNumber == null) return '';

      // Chuyển đổi số điện thoại thành String và thêm số 0 ở đầu
      String phoneString = '0$phoneNumber';

      // Sử dụng RegExp để thêm dấu chấm giữa các nhóm số
      return phoneString.replaceAllMapped(
        RegExp(r'(\d{3})(\d{3})(\d{3,})'),
        (Match match) => '${match[1]}.${match[2]}.${match[3]}',
      );
    }

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
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue,
            child: (UserManager.instance.user?.photo != '')
                ? Image.asset(
                    'assets/images/${UserManager.instance.user?.photo}')
                : const Icon(
                    Icons.person, // Icon mặc định là biểu tượng avatar
                    color: Colors.white,
                    size: 30,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            '${UserManager.instance.user?.fullName}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatPhoneNumber(UserManager.instance.user?.phoneNumber),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Bên trái chứa icon QR và text Trang cá nhân
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Màu nền xám
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(0),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Căn giữa nội dung
                    children: [
                      Icon(Icons.qr_code, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Trang cá nhân'),
                    ],
                  ),
                ),
              ),

              // Spacer để tạo khoảng cách giữa 2 phần
              const SizedBox(width: 8),

              // Bên phải chứa @username
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Màu nền xám
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Căn giữa nội dung
                    children: [
                      Text('@${UserManager.instance.user?.userName}',
                          style: TextStyle(color: Colors.grey)),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
