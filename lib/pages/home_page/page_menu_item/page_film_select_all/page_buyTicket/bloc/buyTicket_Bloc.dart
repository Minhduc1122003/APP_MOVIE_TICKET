import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

// Phần định nghĩa của state
part 'buyTicket_Bloc_event.dart';
// Phần định nghĩa của event
part 'buyTicket_Bloc_State.dart';

class BuyticketBloc extends Bloc<BuyticketBlocEvent, BuyticketBlocState> {
  BuyticketBloc() : super(BuyticketBlocState(today: '', thu_today: '')) {
    on<LoadData1>(_onLoadData);
  }

  void _onLoadData(LoadData1 event, Emitter<BuyticketBlocState> emit) {
    // Lấy ngày hiện tại
    final now = DateTime.now();

    // Định dạng thứ trong tuần (vi_VN là ngôn ngữ Tiếng Việt)
    final dayOfWeek = DateFormat('EEEE', 'vi_VN').format(now);
    print("Bloc: $dayOfWeek");

    // Định dạng ngày tháng theo kiểu dd/MM/yyyy (hoặc có thể dùng kiểu khác như d/M)
    final dayMonth = DateFormat('dd/MM/yyyy').format(now);
    print(dayMonth);

    // Cập nhật thông tin phim mà không thay đổi trạng thái loading
    emit(BuyticketBlocState(today: dayMonth, thu_today: dayOfWeek));
  }
}
