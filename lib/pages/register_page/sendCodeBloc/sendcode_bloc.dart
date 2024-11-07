import 'package:bloc/bloc.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:logger/logger.dart';

part 'sendcode_event.dart';
part 'sendcode_state.dart';

class SendCodeBloc extends Bloc<SendCodeEvent, SendCodeState> {
  SendCodeBloc() : super(SendCodeInitial()) {
    on<SendCode>(_sendcode);
  }
  final logger = Logger();
  void _sendcode(SendCode event, Emitter<SendCodeState> emit) async {
    emit(SendCodeWaiting());
    logger.d(
        'Đã vào _sendcode'); // d là viết tắt của debug, có thể dùng e cho error hoặc w cho warning
    try {
      // Lấy thông tin từ event
      String title = event.title;
      String content = event.content;
      String recipient = event.recipient;

      // Gọi API để xác thực người dùng
      final apiService = ApiService();
      final response =
          await apiService.sendCodeToEmail(title, content, recipient);
      print(response['message']);
      if (response['message'] == 'Email sent successfully') {
        print("Gửi mail thành công");
        final code = response['code'];
        print(response['code']);

        emit(SendCodeSuccess(code: code));
      } else {
        emit(SendCodeError());
      }
    } catch (e) {
      emit(SendCodeError()); // Xử lý lỗi khi gọi API
    }
  }
}
