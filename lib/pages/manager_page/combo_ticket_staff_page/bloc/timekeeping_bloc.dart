import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

part 'timekeeping_bloc_event.dart';
part 'timekeeping_bloc_state.dart';

class TimekeepingBloc extends Bloc<TimekeepingBlocEvent, TimekeepingBlocState> {
  Timer? _timer;

  TimekeepingBloc()
      : super(TimekeepingBlocState(
          dateFormat: '',
          realTimeClock: '',
        )) {
    on<InitTime>(_onInitTime);
    on<UpdateTime>(_onUpdateTime);
    _startClock();
  }

  void _onInitTime(InitTime event, Emitter<TimekeepingBlocState> emit) {
    _updateTime(emit);
  }

  void _onUpdateTime(UpdateTime event, Emitter<TimekeepingBlocState> emit) {
    _updateTime(emit);
  }

  void _startClock() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      add(UpdateTime());
    });
  }

  void _updateTime(Emitter<TimekeepingBlocState> emit) {
    final Map<String, String> shortDayMap = {
      'Thứ Hai': 'Thứ 2',
      'Thứ Ba': 'Thứ 3',
      'Thứ Tư': 'Thứ 4',
      'Thứ Năm': 'Thứ 5',
      'Thứ Sáu': 'Thứ 6',
      'Thứ Bảy': 'Thứ 7',
      'Chủ Nhật': 'Chủ Nhật',
    };
    final now = DateTime.now();
    final dayOfWeek = DateFormat('EEEE', 'vi_VN').format(now);
    final shortDayOfWeek = shortDayMap[dayOfWeek] ?? dayOfWeek;
    final dayMonth = DateFormat('dd/MM/yyyy', 'vi_VN').format(now);
    final String fullDate = '$shortDayOfWeek, $dayMonth';

    final String realTimeClock = DateFormat('HH:mm:ss').format(now);

    emit(TimekeepingBlocState(
      dateFormat: fullDate,
      realTimeClock: realTimeClock,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
