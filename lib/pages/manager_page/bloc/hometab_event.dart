part of 'hometab_bloc.dart';

class IncrementCount extends HomeTabEvent {} // Thêm event mới

sealed class HomeTabEvent extends Equatable {
  const HomeTabEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeTabData extends HomeTabEvent {
  final String userName;
  final String nhanSu;
  final String tuyenDung;
  final String donTu;
  final String count; // Thêm count vào event

  const LoadHomeTabData(
    this.userName,
    this.nhanSu,
    this.tuyenDung,
    this.donTu,
    this.count,
  );

  @override
  List<Object> get props => [userName, nhanSu, tuyenDung, donTu, count];
}
