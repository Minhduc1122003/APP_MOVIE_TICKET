import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/chat_service.dart';
import 'package:flutter_app_chat/models/chat_item_model.dart';
import 'package:flutter_app_chat/models/message.dart'; // Import lớp Message

class UserChatForm extends StatefulWidget {
  final ChatItem chatItem;

  UserChatForm({required this.chatItem});

  @override
  _UserChatFormState createState() => _UserChatFormState();
}

class _UserChatFormState extends State<UserChatForm> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = []; // Sử dụng List<Message>
  late ChatService _chatService; // Khởi tạo `ChatService` ở đây

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(); // Tạo đối tượng mới
    _chatService.connect();

    // Đăng ký callback để xử lý dữ liệu tin nhắn từ server
    _chatService.onMessageChatData = (messages) {
      setState(() {
        _messages.clear(); // Xóa tin nhắn cũ nếu cần
        _messages.addAll(messages);
      });
    };

    // Gửi yêu cầu để lấy tin nhắn khi khởi tạo
    _chatService.requestChatMessages(widget.chatItem.id);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      if (widget.chatItem.requesterId == widget.chatItem.user1Id) {
        _chatService.sendMessage(
          widget.chatItem.user1Id, // Thay thế bằng ID thực tế của người gửi
          widget.chatItem.user2Id, // Thay thế bằng ID thực tế của người nhận
          message,
        );
      } else {
        _chatService.sendMessage(
          widget.chatItem.user2Id, // Thay thế bằng ID thực tế của người gửi
          widget.chatItem.user1Id, // Thay thế bằng ID thực tế của người nhận
          message,
        );
      }

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.chatItem.otherUserName}'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: _messages
                    .map((message) => MessageBubble(message: message))
                    .toList(),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;

  MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      alignment: message.senderId == 1
          ? Alignment.centerRight
          : Alignment.centerLeft, // Điều chỉnh theo ID người gửi
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: message.senderId == 1
              ? Colors.blue[200]
              : Colors.grey[300], // Điều chỉnh theo ID người gửi
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          message.message,
          style: TextStyle(
              color: message.senderId == 1
                  ? Colors.white
                  : Colors.black), // Điều chỉnh theo ID người gửi
        ),
      ),
    );
  }
}
