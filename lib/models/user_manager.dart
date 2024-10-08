import 'package:flutter_app_chat/models/user_model.dart';

class UserManager {
  // Singleton instance
  static final UserManager _instance = UserManager._internal();

  // Private constructor
  UserManager._internal();

  // Singleton accessor
  static UserManager get instance => _instance;

  // Private user and token variables
  User? _user;
  String? _token;

  // Getter for the user
  User? get user => _user;

  // Setter for the user
  void setUser(User user, String token) {
    _user = user;
    _token = token; // Set token when user is set
  }

  // Getter for the token
  String? get token => _token;

  // Clear user and token
  void clearUser() {
    _user = null;
    _token = null; // Clear token as well
  }
}
