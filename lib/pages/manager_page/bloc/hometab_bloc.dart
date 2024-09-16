import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

part 'hometab_event.dart';
part 'hometab_state.dart';

class HomeTabBloc extends Bloc<HomeTabEvent, HomeTabState> {
  HomeTabBloc()
      : super(HomeTabState(
          userName: '',
          greeting: '',
          dayOfWeek: '',
          dayMonth: '',
          nhanSu: '',
          tuyenDung: '',
          donTu: '',
          count: '0', // Thêm count vào state ban đầu
        )) {
    on<LoadHomeTabData>(_onLoadHomeData);
    on<IncrementCount>(
        _onIncrementCount); // Đăng ký event handler cho IncrementCount
  }

  void _onLoadHomeData(LoadHomeTabData event, Emitter<HomeTabState> emit) {
    final greeting = _getGreeting();
    // Lấy ngày hiện tại
    final now = DateTime.now();
    // Định dạng thứ trong tuần
    final dayOfWeek = DateFormat('EEEE', 'vi_VN').format(now);
    // Định dạng ngày tháng
    final dayMonth = DateFormat('d/M').format(now);
    emit(HomeTabState(
      userName: event.userName,
      greeting: greeting,
      dayOfWeek: dayOfWeek,
      dayMonth: dayMonth,
      nhanSu: event.nhanSu,
      tuyenDung: event.tuyenDung,
      donTu: event.donTu,
      count: event.count, // Thêm count vào state
    ));
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) {
      return 'Chào buổi sáng';
    } else if (hour >= 11 && hour < 17) {
      return 'Chào buổi chiều';
    } else if (hour >= 17 && hour < 23) {
      return 'Chào buổi tối';
    } else {
      return 'Xin chào';
    }
  }

  void _onIncrementCount(IncrementCount event, Emitter<HomeTabState> emit) {
    final newCount = int.parse(state.count) + 1;
    print('newCount $newCount');
    emit(state.copyWith(count: newCount.toString()));
  }
}
