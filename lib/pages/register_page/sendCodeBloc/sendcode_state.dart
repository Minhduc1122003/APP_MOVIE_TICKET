part of 'sendcode_bloc.dart';

abstract class SendCodeState {}

class SendCodeInitial extends SendCodeState {}

class SendCodeWaiting extends SendCodeState {}

class SendCodeSuccess extends SendCodeState {
  final String? code;

  SendCodeSuccess({this.code});
}

class SendCodeError extends SendCodeState {}
