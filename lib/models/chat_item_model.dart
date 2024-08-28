class ChatItem {
  final int id;
  final int user1Id;
  final int user2Id;
  final DateTime startedAt;
  final DateTime lastMessageTime;
  final String lastMessage;
  final int otherUserId;
  final String otherUserPhoto;
  final String otherUserName;
  final int requesterId; // Thêm trường requesterId

  ChatItem({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.startedAt,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.otherUserId,
    required this.otherUserPhoto,
    required this.otherUserName,
    required this.requesterId, // Thêm trường requesterId
  });

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      id: json['Id'],
      user1Id: json['User1Id'],
      user2Id: json['User2Id'],
      startedAt: DateTime.parse(json['StartedAt']),
      lastMessageTime: DateTime.parse(json['LastMessageTime']),
      lastMessage: json['LastMessage'],
      otherUserId: json['OtherUserId'],
      otherUserPhoto: json['OtherUserPhoto'],
      otherUserName: json['OtherUserName'],
      requesterId: json['RequesterId'], // Thêm trường requesterId
    );
  }
}
