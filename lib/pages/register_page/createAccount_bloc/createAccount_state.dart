part of 'createAccount_bloc.dart';

abstract class CreateAccountState {}

class CreateAccountInitial extends CreateAccountState {}

class CreateAccountWaiting extends CreateAccountState {}

class CreateAccountSuccess extends CreateAccountState {}

class CreateAccountError extends CreateAccountState {}
