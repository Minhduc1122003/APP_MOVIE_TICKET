import 'package:bloc/bloc.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:meta/meta.dart';

part 'sendcode_event.dart';
part 'sendcode_state.dart';

class SendCodeBloc extends Bloc<SendCodeEvent, SendCodeState> {
  SendCodeBloc() : super(SendCodeInitial()) {
    on<SendCode>(_sendcode);
  }
  void _sendcode(SendCode event, Emitter<SendCodeState> emit) async {
    emit(SendCodeWaiting());
    print('Đã vào _sendcode');
    try {
      // Lấy thông tin từ event
      String title = event.title;
      String content = event.content;
      String recipient = event.recipient;

      // Gọi API để xác thực người dùng
      final apiService = ApiService();
      final response =
          await apiService.sendCodeToEmail(title, content, recipient);

      if (response['message'] == 'Email sent successfully') {
        print("Gửi mail thành công");
        final code = response['code'];

        // Phát ra trạng thái SendCodeSuccess với mã code
        emit(SendCodeSuccess(code: code));
      } else {
        emit(SendCodeError());
      }
    } catch (e) {
      emit(SendCodeError()); // Xử lý lỗi khi gọi API
    }
  }
}
