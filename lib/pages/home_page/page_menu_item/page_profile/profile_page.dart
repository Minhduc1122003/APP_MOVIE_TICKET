import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/chat_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_chat/chat_online_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_profile/page_user/info_user.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../../components/my_InfoCard.dart';

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
    print(UserManager.instance.user?.role);

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
                                        .support, // Đổi thành icon phù hợp với "Trung tâm trợ giúp"
                                    onPressed: () {
                                      _chatService
                                          .connect(); // Kết nối khi khởi tạo

                                      Navigator.push(
                                        context,
                                        SlideFromRightPageRoute(
                                          page: ChatPage(
                                              userId: UserManager
                                                  .instance.user!.userId),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              if (UserManager.instance.user?.role == 3)
                                UtilitySection(
                                  title: 'Quản trị',
                                  buttons: [
                                    UtilityButton(
                                      color: Colors.pink,
                                      title: 'Quản lý người dùng',
                                      icon: Icons
                                          .people_alt_outlined, // Đổi thành icon phù hợp với "Quản lý người dùng"
                                      isExpandable: true,
                                      expandedItems: [
                                        UtilityButton(
                                          color: Colors.pink,
                                          title: 'Thống kê người dùng',
                                          icon: Icons
                                              .bar_chart, // Đổi thành icon phù hợp với "Thống kê người dùng"
                                          textStyle: TextStyle(fontSize: 16),
                                          onPressed: () {},
                                        ),
                                        UtilityButton(
                                          color: Colors.pink,
                                          title: 'Chi tiết người dùng',
                                          icon: Icons
                                              .account_box, // Đổi thành icon phù hợp với "Chi tiết người dùng"
                                          textStyle: TextStyle(fontSize: 16),
                                          onPressed: () {},
                                        ),
                                        // Add more sub-items here as needed
                                      ],
                                      onPressed:
                                          () {}, // This will be called when the item is tapped, even if it's expandable
                                    ),
                                    UtilityButton(
                                      color: Colors.pink,
                                      title: 'Quản lý phim',
                                      icon: Icons
                                          .movie, // Đổi thành icon phù hợp với "Quản lý phim"
                                      isExpandable: true,
                                      expandedItems: [
                                        UtilityButton(
                                          color: Colors.pink,
                                          title: 'Thêm phim sắp chiếu',
                                          icon: Icons
                                              .add, // Đổi thành icon phù hợp với "Thêm phim sắp chiếu"
                                          textStyle: TextStyle(fontSize: 16),
                                          onPressed: () {},
                                        ),
                                        UtilityButton(
                                          color: Colors.pink,
                                          title: 'Chỉnh sửa nội dung',
                                          icon: Icons
                                              .mode_edit_outline_rounded, // Đổi thành icon phù hợp với "Chỉnh sửa nội dung"
                                          textStyle: TextStyle(fontSize: 16),
                                          onPressed: () {},
                                        ),
                                        UtilityButton(
                                          color: Colors.pink,
                                          title: 'Quản lý xuất chiếu',
                                          icon: Icons
                                              .event, // Đổi thành icon phù hợp với "Quản lý xuất chiếu"
                                          textStyle: TextStyle(fontSize: 16),
                                          onPressed: () {},
                                        ),
                                        // Add more sub-items here as needed
                                      ],
                                      onPressed:
                                          () {}, // This will be called when the item is tapped, even if it's expandable
                                    ),
                                    UtilityButton(
                                      color: Colors.pink,
                                      title: 'Quản lý phòng chiếu',
                                      icon: Icons
                                          .account_box, // Đổi thành icon phù hợp với "Chi tiết người dùng"
                                      onPressed: () {},
                                    ),
                                    UtilityButton(
                                      color: Colors.pink,
                                      title: 'Báo cáo &  thống kê doanh thu',
                                      icon: Icons
                                          .account_box, // Đổi thành icon phù hợp với "Chi tiết người dùng"
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              UtilitySection(
                                title: 'Trợ giúp & hỗ trợ',
                                buttons: UserManager.instance.user?.role == true
                                    ? [
                                        UtilityButton(
                                          color: Colors.pink,
                                          title: 'Tiếp nhận hỗ trợ',
                                          icon: Icons.email_outlined,
                                          onPressed: () {},
                                        ),
                                        UtilityButton(
                                          color: Colors.pink,
                                          title: 'Tiếp nhận sự cố',
                                          icon: Icons.warning_amber_outlined,
                                          onPressed: () {},
                                        ),
                                      ]
                                    : [
                                        UtilityButton(
                                          color: Colors.pink,
                                          title: 'Trung tâm trợ giúp',
                                          icon: Icons
                                              .help, // Đổi thành icon phù hợp với "Trung tâm trợ giúp"
                                          onPressed: () {},
                                        ),
                                        UtilityButton(
                                          color: Colors.pink,
                                          title: 'Hộp thư trợ',
                                          icon: Icons
                                              .support, // Giữ nguyên icon nếu cảm thấy phù hợp
                                          onPressed: () {},
                                        ),
                                        UtilityButton(
                                          color: Colors.pink,
                                          title: 'Báo cáo sự cố',
                                          icon: Icons
                                              .report, // Đổi thành icon phù hợp với "Báo cáo sự cố"
                                          onPressed: () {},
                                        ),
                                        UtilityButton(
                                          color: Colors.pink,
                                          title: 'Điều khoản & chính sách',
                                          icon: Icons
                                              .description, // Đổi thành icon phù hợp với "Điều khoản & chính sách"
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
                                        .account_circle_outlined, // Đổi thành icon phù hợp với "Trung tâm tài khoản"
                                    onPressed: () {},
                                  ),
                                  UtilityButton(
                                    trailingIconType: TrailingIconType.toggle,
                                    color: Colors.pink,
                                    title: 'Chế độ tối',
                                    icon: Icons
                                        .nightlight_round, // Đổi thành icon phù hợp với "Chế độ tối"
                                    onPressed: () {},
                                  ),
                                  UtilityButton(
                                    trailingIconType: TrailingIconType
                                        .toggle, // Sử dụng kiểu toggle cho icon phía sau
                                    color:
                                        Colors.pink, // Màu của icon và toggle
                                    title: 'Ngôn ngữ', // Tiêu đề của nút
                                    icon: Icons
                                        .translate, // Đổi thành icon phù hợp với "Ngôn ngữ"
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
                                    icon: Icons
                                        .exit_to_app, // Đổi thành icon phù hợp với "Đăng xuất"
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Xác nhận đăng xuất'),
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
                                                  UserManager.instance
                                                      .clearUser();
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    SlideFromLeftPageRoute(
                                                        page: HomePage()),
                                                    (Route<dynamic> route) =>
                                                        false, // Xóa tất cả các route trước đó
                                                  );
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
            child: (UserManager.instance.user?.photo != null)
                ? Image.asset('assets/images/avatar.jpg')
                : Image.asset(
                    'assets/images/${UserManager.instance.user?.photo}'),
          ),
          const SizedBox(height: 8),
          Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Căn giữa các phần tử trong cột
            crossAxisAlignment:
                CrossAxisAlignment.center, // Căn giữa các phần tử trong hàng
            children: [
              Text(
                '${UserManager.instance.user?.fullName}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5), // Khoảng cách giữa fullName và Container
              Visibility(
                visible: UserManager.instance.user?.role ==
                    true, // Kiểm tra điều kiện
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Text(
                    'Quản trị viên', // Hiển thị "Quản trị viên" khi điều kiện là true
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                UserManager.instance.user!.email,
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
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideFromRightPageRoute(
                          page: const InfoUser(),
                        ),
                      );
                    },
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
