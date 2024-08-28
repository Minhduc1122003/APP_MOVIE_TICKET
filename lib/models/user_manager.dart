import 'package:flutter_app_chat/models/user_model.dart';

class UserManager {
  // Singleton instance
  static final UserManager _instance = UserManager._internal();

  // Private constructor
  UserManager._internal();

  // Singleton accessor
  static UserManager get instance => _instance;

  // Private user variable
  User? _user;

  // Getter for the user
  User? get user => _user;

  // Setter for the user
  void setUser(User user) {
    _user = user;
  }

  void clearUser() {
    _user = null;
  }
}
