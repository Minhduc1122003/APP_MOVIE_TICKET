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
  });

  // Factory constructor to create a User instance from JSON
  // Factory constructor to create a User instance from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] is int
          ? json['phoneNumber'] as int
          : int.tryParse(json['phoneNumber'].toString()) ?? 0,
      photo: json['photo'] as String?, // Cập nhật để có thể là null
      role: json['role'] as int,
      createDate: DateTime.parse(json['createDate'] as String),
      status: json['status'] as String,
      isDelete: json['isDelete'] as bool,
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'UserId': userId,
  //     'UserName': userName,
  //     'Password': password,
  //     'Email': email,
  //     'FullName': fullName,
  //     'PhoneNumber': phoneNumber.toString(),
  //     'Photo': photo,
  //     'Role': role,
  //     'CreateDate': createDate.toIso8601String(),
  //     'UpdateDate': updateDate.toIso8601String(),
  //     'UpdateBy': updateBy,
  //     'Status': status,
  //   };
  // }
}
