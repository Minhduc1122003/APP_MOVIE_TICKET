import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/user_model.dart';

part 'login_state.dart';
part 'login_event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<Login>(_login);
  }

  void _login(Login event, Emitter<LoginState> emit) async {
    emit(LoginWaiting());

    // Đợi một thời gian ngắn (có thể là để hiển thị loading spinner)
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      // Lấy thông tin từ event
      final String username = event.username;
      final String password = event.password;
      print('Username: $username');
      print('Password: $password');

      // Gọi API để xác thực người dùng
      final ApiService apiService = ApiService();
      final Map<String, dynamic> response =
          await apiService.login(username, password);

      // Kiểm tra response có tồn tại và hợp lệ không
      if (response != null &&
          response.containsKey('message') &&
          response.containsKey('user')) {
        final String message = response['message'];
        final Map<String, dynamic> userMap = response['user'];

        // Chuyển đổi dữ liệu userMap thành đối tượng User
        final User user = User.fromJson(userMap);

        print('Response message: $message');
        print('User: ${user.email}');

        // Kiểm tra điều kiện đăng nhập thành công
        if (message == 'Login successful' && user != null) {
          UserManager.instance.setUser(user);

          emit(LoginSuccess()); // Truyền đối tượng user khi emit LoginSuccess
        } else {
          emit(LoginError()); // Truyền thông báo lỗi nếu có
        }
      } else {
        emit(LoginError()); // Thông báo lỗi nếu định dạng phản hồi không hợp lệ
      }
    } catch (e) {
      print('Login error: $e');
      emit(LoginError()); // Thông báo lỗi nếu có exception
    }
  }
}
