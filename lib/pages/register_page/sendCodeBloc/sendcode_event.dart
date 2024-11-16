part of 'sendcode_bloc.dart';

abstract class SendCodeEvent {}

class SendCode extends SendCodeEvent {
  final String title;
  final String content;
  final String recipient;
  SendCode(this.title, this.content, this.recipient);
}
