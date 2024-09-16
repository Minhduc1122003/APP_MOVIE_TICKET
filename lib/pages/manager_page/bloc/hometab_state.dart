part of 'hometab_bloc.dart';

class HomeTabState extends Equatable {
  final String userName;
  final String greeting;
  final String dayOfWeek;
  final String dayMonth;
  final String nhanSu;
  final String tuyenDung;
  final String donTu;
  final String count; // Thêm count vào state

  const HomeTabState({
    required this.userName,
    required this.greeting,
    required this.dayOfWeek,
    required this.dayMonth,
    required this.nhanSu,
    required this.tuyenDung,
    required this.donTu,
    required this.count, // Thêm count vào constructor
  });

  @override
  List<Object> get props =>
      [userName, greeting, nhanSu, tuyenDung, donTu, count];
  HomeTabState copyWith({
    String? userName,
    String? greeting,
    String? dayOfWeek,
    String? dayMonth,
    String? nhanSu,
    String? tuyenDung,
    String? donTu,
    String? count, // Thêm count vào copyWith
  }) {
    return HomeTabState(
      userName: userName ?? this.userName,
      greeting: greeting ?? this.greeting,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayMonth: dayMonth ?? this.dayMonth,
      nhanSu: nhanSu ?? this.nhanSu,
      tuyenDung: tuyenDung ?? this.tuyenDung,
      donTu: donTu ?? this.donTu,
      count: count ?? this.count, // Thêm count vào copyWith
    );
  }
}
