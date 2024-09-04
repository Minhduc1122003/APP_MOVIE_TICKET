part of 'buyTicket_Bloc.dart';

class BuyticketBlocState extends Equatable {
  final String today;
  final String thu_today;
  const BuyticketBlocState({required this.today, required this.thu_today});

  @override
  List<Object?> get props => [today, thu_today];

  BuyticketBlocState copyWith({
    String? today,
    String? thu_today,
  }) {
    return BuyticketBlocState(
        today: today ?? this.today, thu_today: thu_today ?? this.thu_today);
  }
}
