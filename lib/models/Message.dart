class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final DateTime sentAt;
  final int conversationId;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.sentAt,
    required this.conversationId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['Id'], // Sửa lại tên thuộc tính để khớp với dữ liệu JSON
      senderId: json['SenderId'],
      receiverId: json['ReceiverId'],
      message: json['Message'],
      sentAt: DateTime.parse(json['SentAt']),
      conversationId: json['ConversationId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'SenderId': senderId,
      'ReceiverId': receiverId,
      'Message': message,
      'SentAt': sentAt.toIso8601String(), // Chuyển đổi DateTime thành chuỗi
      'ConversationId': conversationId,
    };
  }
}
