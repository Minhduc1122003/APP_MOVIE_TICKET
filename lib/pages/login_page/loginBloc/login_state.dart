part of 'login_bloc.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginWaiting extends LoginState {}

class LoginError extends LoginState {}

class LoginSuccess extends LoginState {}
