class User {
  final int userId;
  final String userName;
  final String password;
  final String email;
  final String fullName;
  final int phoneNumber; // Đảm bảo phoneNumber là int
  final String photo;
  final bool role;
  final DateTime createDate;
  final DateTime updateDate;
  final String updateBy;
  final String status;
  User({
    required this.userId,
    required this.userName,
    required this.password,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.photo,
    required this.role,
    required this.createDate,
    required this.updateDate,
    required this.updateBy,
    required this.status,
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
      photo: json['Photo'] as String,
      role: json['Role'] as bool,
      createDate: DateTime.parse(json['CreateDate'] as String),
      updateDate: DateTime.parse(json['UpdateDate'] as String),
      updateBy: json['UpdateBy'] as String,
      status: json['Status'] as String,
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
