part of 'timekeeping_bloc.dart';

class TimekeepingBlocState extends Equatable {
  final String dateFormat;
  final String realTimeClock;

  const TimekeepingBlocState({
    required this.dateFormat,
    required this.realTimeClock,
  });

  @override
  List<Object> get props => [];
}
