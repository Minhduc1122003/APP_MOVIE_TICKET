class User {
  final int userId;
  final String userName;
  final String email;
  final String fullName;
  final int phoneNumber; // Đảm bảo phoneNumber là int
  final String? photo; // Đổi thành String? để cho phép giá trị null
  final int role;
  final DateTime createDate;
  final String status;
  final bool isDelete;
  final String? token;
  final String? password;

  User({
    required this.userId,
    required this.userName,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.photo, // Không cần `required` vì giá trị có thể null
    required this.role,
    required this.createDate,
    required this.status,
    required this.isDelete,
    this.token,
    this.password,
  });

  // Factory constructor to create a User instance from JSON
  // java server:
  // factory User.fromJson(Map<String, dynamic> json) {
  //   return User(
  //     userId: json['userId'] as int,
  //     userName: json['userName'] as String,
  //     email: json['email'] as String,
  //     fullName: json['fullName'] as String,
  //     phoneNumber: json['phoneNumber'] is int
  //         ? json['phoneNumber'] as int
  //         : int.tryParse(json['phoneNumber'].toString()) ?? 0,
  //     photo: json['photo'] as String?, // Cập nhật để có thể là null
  //     role: json['role'] as int,
  //     createDate: DateTime.parse(json['createDate'] as String),
  //     status: json['status'] as String,
  //     isDelete: json['isDelete'] as bool,
  //   );
  // }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['UserId'] as int,
      userName: json['UserName'] as String,
      email: json['Email'] as String,
      fullName: json['FullName'] as String,
      phoneNumber: json['PhoneNumber'] is int
          ? json['PhoneNumber'] as int
          : int.tryParse(json['PhoneNumber'].toString()) ?? 0,
      photo: json['Photo'] as String?, // Cập nhật để có thể là null
      role: json['Role'] as int,
      createDate: DateTime.parse(json['CreateDate'] as String),
      status: json['Status'] as String,
      isDelete: json['IsDelete'] as bool,
      password: json['Password'] as String,
    );
  }
}
