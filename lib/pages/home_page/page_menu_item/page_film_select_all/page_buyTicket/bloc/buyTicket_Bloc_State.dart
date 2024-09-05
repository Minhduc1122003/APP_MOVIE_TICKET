part of 'buyTicket_Bloc.dart';

class BuyticketBlocState extends Equatable {
  final List<Map<String, String>> daysList;

  const BuyticketBlocState({
    required this.daysList,
  });

  @override
  List<Object> get props => [daysList];
}
