class User {
  final int userId;
  final String userName;
  final String password;
  final String email;
  final String fullName;
  final int phoneNumber; // Đảm bảo phoneNumber là int
  final String? photo; // Đổi thành String? để cho phép giá trị null
  final int role;
  final DateTime createDate;

  final String status;
  final bool isDelete;
  User({
    required this.userId,
    required this.userName,
    required this.password,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.photo, // Không cần `required` vì giá trị có thể null
    required this.role,
    required this.createDate,
    required this.status,
    required this.isDelete,
  });

  // Factory constructor to create a User instance from JSON
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
      photo: json['Photo'] as String?, // Cập nhật để có thể là null
      role: json['Role'] as int,
      createDate: DateTime.parse(json['CreateDate'] as String),
      status: json['Status'] as String,
      isDelete: json['IsDelete'] as bool,
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
