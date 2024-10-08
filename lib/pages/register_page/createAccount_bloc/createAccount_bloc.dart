import 'package:bloc/bloc.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/user_model.dart';

part 'createAccount_event.dart';
part 'createAccount_state.dart';

class CreateAccountBloc extends Bloc<CreateAccountEvent, CreateAccountState> {
  CreateAccountBloc() : super(CreateAccountInitial()) {
    on<CreateAccount>(_createAccount);
  }

  void _createAccount(
      CreateAccount event, Emitter<CreateAccountState> emit) async {
    emit(CreateAccountWaiting());
    print('Đã vào _Createaccount');

    try {
      // Lấy thông tin từ event
      String email = event.email;
      String password = event.password;
      String username = event.username;
      String fullname = event.fullname;
      int phoneNumber = event.phoneNumber;
      String photo = event.photo;

      // Gọi API để tạo tài khoản người dùng
      final ApiService apiService = ApiService();
      final User? user = await apiService.createAccount(
          email, password, username, fullname, phoneNumber, photo);

      if (user != null) {
        print("Đăng ký tài khoản thành công");

        // Lưu thông tin người dùng sau khi tạo tài khoản thành công
        // UserManager.instance.setUser(user);

        emit(CreateAccountSuccess()); // Phát sự kiện thành công
      } else {
        emit(CreateAccountError()); // Xử lý lỗi nếu việc tạo tài khoản thất bại
      }
    } catch (e) {
      print('Create account error: $e');
      emit(CreateAccountError()); // Xử lý lỗi khi gọi API
    }
  }
}
