import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/home_page/home_page.dart';
import 'package:flutter_app_chat/pages/home_page/page_menu_item/page_profile/page_user/forgot_user/forgot_pass_user.dart';
import 'package:flutter_app_chat/pages/login_page/login_page.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Import the image picker package
import 'dart:io'; // Add this for mobile
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class InfoUser extends StatefulWidget {
  const InfoUser({
    Key? key,
  }) : super(key: key);

  @override
  State<InfoUser> createState() => _InfoUser();
}

class _InfoUser extends State<InfoUser> {
  late ApiService _APIService;
  late final Future<User> _userFuture;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  late TextEditingController createDateController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
  final ImagePicker _picker = ImagePicker();
  File? _image; // Biến lưu ảnh dưới dạng File

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
    _userFuture =
        _APIService.findByViewIDUser(UserManager.instance.user!.userId);
  }

  Uint8List? _webImage; // Ảnh trên web

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // Đọc dữ liệu ảnh dưới dạng Uint8List cho web
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        // Chuyển đổi sang File cho Mobile/Desktop
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    try {
      EasyLoading.show(status: 'Đang lưu...'); // Show loading status

      final userId = UserManager.instance.user!.userId;
      final userName = usernameController.text;
      final fullName = fullnameController.text;
      final phoneNumber = int.tryParse(phoneController.text) ?? 0;
      final photo = ''; // Placeholder for photo URL or file
      print(_image);
      // try {
      //   // Chuyển đường dẫn thành đối tượng File
      //   if (_image != null) {
      //     try {
      //       // Chuyển từ XFile sang File
      //       File imageFile = File(_image!.path);
      //       print(imageFile);
      //       // Gửi file để upload
      //       final imageUploadResponsePhoto =
      //           await _APIService.uploadImage(imageFile);
      //
      //       print('Image upload response: $imageUploadResponsePhoto');
      //     } catch (e) {
      //       print('Error uploading image: $e');
      //     }
      //   }
      // } catch (e) {
      //   print('Error uploading image for');
      // }

      String image = '';
      // if (_imageFile != null) {
      //   // Chờ kết quả từ hàm uploadImage
      //   image = await _APIService.uploadImage(File(_imageFile!.path));
      // }
      // else {
      //   print('Không có ảnh để upload');
      // }

      final response = await _APIService.updateInfoUser(
        userId,
        userName,
        fullName,
        phoneNumber,
        image,
      );

      // Hiển thị thông báo thành công
      EasyLoading.showSuccess("Thay đổi thông tin thành công");
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Thông báo'),
            content: const Text('Bạn cần đăng nhập lại để sử dụng dịch vụ!'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  UserManager.instance.clearUser();
                  Navigator.pushAndRemoveUntil(
                    context,
                    SlideFromLeftPageRoute(page: LoginPage()),
                    (Route<dynamic> route) =>
                        false, // Xóa tất cả các route trước đó
                  );
                },
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      EasyLoading.showError('Lỗi: $e'); // Show error message
    } finally {
      Future.delayed(Duration(seconds: 2), () {
        EasyLoading.dismiss(); // Dismiss loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F75FF),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 16,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No user data available.'));
          } else {
            final user = snapshot.data!;
            usernameController.text = user.userName;
            fullnameController.text = user.fullName;
            phoneController.text = user.phoneNumber.toString();
            createDateController.text = dateFormatter.format(user.createDate);

            // If user.photo is null, use a default image
            String imageUrl =
                user.photo ?? 'https://example.com/path_to_default_image';

            print(
                "Current selected image: ${_image?.path ?? 'No image selected'}"); // Debug print to check selected image

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.blue,
                              child: ClipOval(
                                child: kIsWeb // Kiểm tra nếu là Web
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80,
                                      )
                                    : (_image == null
                                        ? Image.network(
                                            imageUrl, // ảnh mặc định nếu chưa chọn
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height: 80,
                                          )
                                        : Image.file(
                                            File(_image!
                                                .path), // Hiển thị ảnh đã chọn
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height: 80,
                                          )),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 13,
                                backgroundColor: Colors.grey,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.edit_square,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  onPressed: _pickImage, // Khi nhấn sẽ chọn ảnh
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  iconSize: 16,
                                  tooltip: "Edit",
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.userName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(user.email),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 15),
                    MyTextfield(
                      placeHolder: 'Tên người dùng',
                      controller: usernameController,
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      placeHolder: 'Họ tên người dùng',
                      controller: fullnameController,
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      placeHolder: 'Số điện thoại',
                      controller: phoneController,
                      isPhone: true,
                    ),
                    const SizedBox(height: 10),
                    MyTextfield(
                      placeHolder: 'Ngày tạo',
                      isEdit: false,
                      controller: createDateController,
                    ),
                    const SizedBox(height: 30),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                SlideFromRightPageRoute(
                                  page: ForgotPassUser(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(
                                color: mainColor,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Đổi mật khẩu',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: mainColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: MyButton(
                            text: 'Lưu thay đổi',
                            fontsize: 16,
                            paddingText: 16,
                            onTap: _saveChanges, // Save changes
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
