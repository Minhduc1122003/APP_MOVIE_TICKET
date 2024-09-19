import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
// Phần định nghĩa của state
part 'buyTicket_Bloc_event.dart';
// Phần định nghĩa của event
part 'buyTicket_Bloc_State.dart';

class BuyticketBloc extends Bloc<BuyticketBlocEvent, BuyticketBlocState> {
  BuyticketBloc() : super(BuyticketBlocState(daysList: [])) {
    on<LoadData1>(_onLoadData);
  }

  void _onLoadData(LoadData1 event, Emitter<BuyticketBlocState> emit) async {
    print("Đã vào BloC");
    await initializeDateFormatting('vi_VN', null);

    // Lấy ngày hiện tại
    final now = DateTime.now();

    // Tạo danh sách chứa ngày và thứ trong tuần
    List<Map<String, String>> daysList = [];

    // Bản đồ rút gọn tên thứ
    final Map<String, String> shortDayMap = {
      'Thứ Hai': 'Thứ 2',
      'Thứ Ba': 'Thứ 3',
      'Thứ Tư': 'Thứ 4',
      'Thứ Năm': 'Thứ 5',
      'Thứ Sáu': 'Thứ 6',
      'Thứ Bảy': 'Thứ 7',
      'Chủ Nhật': 'C.Nhật',
    };

    for (int i = 0; i < 8; i++) {
      // Tính ngày tiếp theo
      final date = now.add(Duration(days: i));

      // Định dạng thứ trong tuần (vi_VN là ngôn ngữ Tiếng Việt)
      final dayOfWeek = DateFormat('EEEE', 'vi_VN').format(date);

      // Rút gọn tên thứ bằng cách sử dụng shortDayMap
      final shortDayOfWeek = shortDayMap[dayOfWeek] ?? dayOfWeek;

      // Định dạng ngày tháng theo kiểu d/M
      final dayMonth = DateFormat('d').format(date);

      // Thêm vào danh sách
      daysList.add({
        'dayOfWeek': shortDayOfWeek,
        'dayMonth': dayMonth,
      });
    }

    // In ra danh sách các ngày và thứ trong tuần
    daysList.forEach((day) {
      print("Thứ: ${day['dayOfWeek']}, Ngày: ${day['dayMonth']}");
    });

    // Cập nhật trạng thái với danh sách ngày và thứ trong tuần
    emit(BuyticketBlocState(daysList: daysList));
  }
}
