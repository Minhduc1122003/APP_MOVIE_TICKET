class User {
  final int userId;
  final String userName;
  final String password;
  final String email;
  final String fullName;
  final int phoneNumber; // Đảm bảo phoneNumber là int
  final String photo;
  final bool role;
  User({
    required this.userId,
    required this.userName,
    required this.password,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.photo,
    required this.role,
  });

  // Factory constructor to create a User instance from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['UserId'] as int,
      userName: json['UserName'] as String,
      password: json['Password'] as String,
      email: json['Email'] as String,
      fullName: json['FullName'] as String,
      phoneNumber: json['PhoneNumber'] is int
          ? json['PhoneNumber'] as int
          : int.tryParse(json['PhoneNumber'].toString()) ?? 0,
      photo: json['Photo'] as String,
      role: json['Role'] as bool,
    );
  }
}
