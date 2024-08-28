import 'package:bloc/bloc.dart';

// State class
class CodeState {
  final String code;
  CodeState(this.code);
}

// Cubit class
class CodeCubit extends Cubit<CodeState> {
  CodeCubit() : super(CodeState(''));

  void updateCode(String newCode) {
    emit(CodeState(newCode));
  }
}
