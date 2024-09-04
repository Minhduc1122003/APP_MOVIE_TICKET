part of 'buyTicket_Bloc.dart';

sealed class BuyticketBlocEvent extends Equatable {
  const BuyticketBlocEvent();

  @override
  List<Object> get props => [];
}

class LoadData1 extends BuyticketBlocEvent {
  final String today;
  final String thu_today;
  const LoadData1({required this.today, required this.thu_today});

  @override
  List<Object?> get prop => [today, thu_today];
}
