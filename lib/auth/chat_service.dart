import 'package:flutter_app_chat/models/message.dart'; // Import lớp Message
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  IO.Socket? socket;
  late String baseUrl;

  ChatService() {
    _initBaseUrl();
  }

  Future<void> _initBaseUrl() async {
    baseUrl = 'http://192.168.100.24:8081'; // Cập nhật URL nếu cần
    print(baseUrl);
  }

  bool get isConnected => socket != null && socket!.connected;

  void connect() {
    if (isConnected) {
      return; // Nếu đã kết nối thì không làm gì cả
    }

    socket =
        IO.io(baseUrl, IO.OptionBuilder().setTransports(['websocket']).build());

    socket!.onConnect((_) {
      print('Connected to server');
    });

    socket!.on('messageChatData', (data) {
      print('Messages received: $data');
      // Đẩy sự kiện đến nơi cần cập nhật UI
      _onMessageChatData(data);
    });

    socket!.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  void requestChatMessages(int conversationId) {
    if (isConnected) {
      socket!.emit('getMessageChat', {'id': conversationId});
    }
  }

  // Callback để xử lý dữ liệu tin nhắn từ server
  void Function(List<Message>)? onMessageChatData;

  void _onMessageChatData(dynamic data) {
    if (onMessageChatData != null) {
      List<Message> messages =
          (data as List).map((item) => Message.fromJson(item)).toList();
      onMessageChatData!(messages);
    }
  }

  void disconnect() {
    if (isConnected) {
      socket!.disconnect();
      print('Disconnected from server');
    }
  }

  void sendMessage(int senderId, int receiverId, String message) {
    if (isConnected) {
      socket!.emit('message', {
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
      });
    } else {
      print('Socket is not connected');
    }
  }
}
