part of 'createAccount_bloc.dart';

abstract class CreateAccountEvent {}

class CreateAccount extends CreateAccountEvent {
  final String email;
  final String password;
  final String username;
  final String fullname;
  final int phoneNumber;
  final String photo;

  CreateAccount(this.email, this.password, this.username, this.fullname,
      this.phoneNumber, this.photo);
}
