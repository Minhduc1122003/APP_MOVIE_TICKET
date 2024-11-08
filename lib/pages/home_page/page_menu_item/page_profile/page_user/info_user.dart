import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';

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

  @override
  void initState() {
    _APIService = ApiService();
    _userFuture =
        _APIService.findByViewIDUser(UserManager.instance.user!.userId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
            final user = snapshot.data!; // Access the user object
            usernameController.text = user.userName;
            fullnameController.text = user.fullName;
            phoneController.text = user.phoneNumber.toString();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/${user.photo}',
                                fit: BoxFit
                                    .cover, // Ensures the image covers the entire circle
                                width: 80, // Should match 2 * radius
                                height: 80,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0, // Adjust distance from the bottom edge
                            right: 0, // Adjust distance from the right edge
                            child: CircleAvatar(
                              radius: 13, // Adjust size as needed
                              backgroundColor: Colors
                                  .grey, // Grey background color for the button
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit_square,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                onPressed: () {
                                  // Handle edit profile picture
                                },
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                iconSize: 16, // Adjust icon size as needed
                                tooltip: "Edit",
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.userName, // Display the user's name
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(user.email), // Display the user's email
                        ],
                      ),
                    ]),
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
                              // showDialog(
                              //   context: context,
                              //   builder: (BuildContext context) {
                              //     bool isOldPasswordVisible = false;
                              //     bool isNewPasswordVisible = false;
                              //
                              //     return StatefulBuilder(
                              //       builder:
                              //           (BuildContext context, StateSetter setState) {
                              //         return AlertDialog(
                              //           title: Center(
                              //             child: Text(
                              //               "Thay đổi mật khẩu",
                              //               style: TextStyle(fontSize: 20),
                              //             ),
                              //           ),
                              //           content: Column(
                              //             mainAxisSize: MainAxisSize.min,
                              //             children: [
                              //               TextField(
                              //                 obscureText: !isOldPasswordVisible,
                              //                 decoration: InputDecoration(
                              //                   labelText: 'Mật khẩu cũ',
                              //                   suffixIcon: IconButton(
                              //                     icon: Icon(
                              //                       isOldPasswordVisible
                              //                           ? Icons.visibility
                              //                           : Icons.visibility_off,
                              //                     ),
                              //                     onPressed: () {
                              //                       setState(() {
                              //                         isOldPasswordVisible =
                              //                             !isOldPasswordVisible;
                              //                       });
                              //                     },
                              //                   ),
                              //                 ),
                              //               ),
                              //               const SizedBox(height: 10),
                              //               TextField(
                              //                 obscureText: !isNewPasswordVisible,
                              //                 decoration: InputDecoration(
                              //                   labelText: 'Mật khẩu mới',
                              //                   suffixIcon: IconButton(
                              //                     icon: Icon(
                              //                       isNewPasswordVisible
                              //                           ? Icons.visibility
                              //                           : Icons.visibility_off,
                              //                     ),
                              //                     onPressed: () {
                              //                       setState(() {
                              //                         isNewPasswordVisible =
                              //                             !isNewPasswordVisible;
                              //                       });
                              //                     },
                              //                   ),
                              //                 ),
                              //               ),
                              //               ElevatedButton(
                              //                 onPressed: () {
                              //                   Navigator.of(context).pop();
                              //                 },
                              //                 child: const SizedBox(
                              //                   width: double.infinity,
                              //                   child: Center(
                              //                     child: Text(
                              //                       'Lưu thay đổi',
                              //                       style: TextStyle(
                              //                         color: Colors.white,
                              //                         fontSize: 18,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //         );
                              //       },
                              //     );
                              //   },
                              // );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(
                                color: mainColor, // Define your mainColor
                                width: 1, // Set border width to 5
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
                                  color: mainColor, // Define your mainColor
                                ),
                              ),
                            ),
                          ),
                        ), // Space between the buttons
                        const SizedBox(height: 10), // Space between the buttons
                        SizedBox(
                          width: double.infinity,
                          child: MyButton(
                            text: 'Lưu thay đổi',
                            fontsize: 16,
                            paddingText: 16,
                            onTap: () {
                              print('Save changes');
                            },
                          ),
                        ),
                      ],
                    ),
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
