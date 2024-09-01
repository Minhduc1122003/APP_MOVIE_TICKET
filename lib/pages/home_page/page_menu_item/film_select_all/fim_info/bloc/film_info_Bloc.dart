import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:equatable/equatable.dart';

// Phần định nghĩa của state
part 'film_info_Bloc_State.dart';
// Phần định nghĩa của event
part 'film_info_Bloc_event.dart';

class FilmInfoBloc extends Bloc<FilmInfoBlocEvent, FilmInfoBlocState> {
  FilmInfoBloc() : super(const FilmInfoBlocState()) {
    on<LoadData>(_onLoadData);
  }

  void _onLoadData(LoadData event, Emitter<FilmInfoBlocState> emit) {
    print('onloadData: ${event.movieDetails?.posterUrl}');
    emit(FilmInfoBlocState(
      movieDetails: event.movieDetails,
    ));
  }
}
