import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/chat_service.dart';
import 'package:flutter_app_chat/components/animation_page.dart';
import 'package:flutter_app_chat/models/chat_item_model.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'user_chat_form.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_customIcon_keyboad_left.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ChatPage extends StatefulWidget {
  final int userId;

  ChatPage({required this.userId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ApiService _apiService;
  late Future<List<ChatItem>> _futureConversations;
  late ChatService _chatService;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(); // Khởi tạo ChatService
    _apiService = ApiService();
    _futureConversations = _apiService.getConversations(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<SendCodeBloc, SendCodeState>(
        listener: (context, state) async {
          if (state is SendCodeError) {
            EasyLoading.showError('Sai tài khoản hoặc mật khẩu');
          } else if (state is SendCodeWaiting) {
            EasyLoading.show(status: 'Loading...');
          } else if (state is SendCodeSuccess) {
            final codeIS = state.code;
            setState(() {});
            EasyLoading.showSuccess('Success');
            await Future.delayed(Duration(milliseconds: 150));
          }
        },
        child: Stack(
          children: [
            // Đặt hình ảnh nền với độ mờ 20%
            const Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcOver,
                ),
              ),
            ),
            // Positioned widget for header
            Positioned(
              top: statusBarHeight,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CustomIconButton(
                            icon: Icons.keyboard_arrow_left,
                            size: 25,
                            color: Colors.black,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Trang cá nhân',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Main content
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 90, 0, 0),
                child: FutureBuilder<List<ChatItem>>(
                  future: _futureConversations,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No conversations found.'));
                    }

                    List<ChatItem> conversations = snapshot.data!;

                    return SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: keyboardHeight),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: conversations.map((chatItem) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Container(
                              color:
                                  Colors.white, // Màu nền trắng cho từng item
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blue,
                                  child: (chatItem.otherUserPhoto != '')
                                      ? Image.asset(
                                          'assets/images/${chatItem.otherUserPhoto}')
                                      : const Icon(
                                          Icons
                                              .person, // Icon mặc định là biểu tượng avatar
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                ),
                                title: Text(chatItem.otherUserName),
                                subtitle: Text(chatItem.lastMessage),
                                trailing: Text('${chatItem.lastMessageTime}'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SlideFromRightPageRoute(
                                      page: UserChatForm(chatItem: chatItem),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
