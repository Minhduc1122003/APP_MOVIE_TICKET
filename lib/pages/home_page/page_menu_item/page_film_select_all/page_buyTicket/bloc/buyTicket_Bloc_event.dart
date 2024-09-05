part of 'buyTicket_Bloc.dart';

sealed class BuyticketBlocEvent extends Equatable {
  const BuyticketBlocEvent();

  @override
  List<Object> get props => [];
}

class LoadData1 extends BuyticketBlocEvent {
  final List<Map<String, String>> daysList;

  const LoadData1(this.daysList);

  @override
  List<Object> get props => [daysList];
}
