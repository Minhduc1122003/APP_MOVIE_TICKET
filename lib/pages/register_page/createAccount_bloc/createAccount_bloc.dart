import 'package:bloc/bloc.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/models/user_manager.dart';
import 'package:flutter_app_chat/models/user_model.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

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

      // Gọi API để xác thực người dùng
      final apiService = ApiService();
      final response = await apiService.createAccount(
          email, password, username, fullname, phoneNumber, photo);

      if (response['message'] == 'Account created successfully') {
        print("Đăng ký tài khoan thành công");

        emit(CreateAccountSuccess());
      } else {
        emit(CreateAccountError());
      }
    } catch (e) {
      emit(CreateAccountError()); // Xử lý lỗi khi gọi API
    }
  }
}
