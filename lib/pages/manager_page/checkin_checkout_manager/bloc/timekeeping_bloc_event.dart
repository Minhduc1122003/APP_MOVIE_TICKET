part of 'timekeeping_bloc.dart';

sealed class TimekeepingBlocEvent extends Equatable {
  const TimekeepingBlocEvent();

  @override
  List<Object> get props => [];
}

class InitTime extends TimekeepingBlocEvent {
  const InitTime();
  @override
  List<Object> get props => [];
}

class UpdateTime extends TimekeepingBlocEvent {
  const UpdateTime();
  @override
  List<Object> get props => [];
}
