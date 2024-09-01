part of 'film_info_Bloc.dart';

sealed class FilmInfoBlocEvent extends Equatable {
  const FilmInfoBlocEvent();

  @override
  List<Object> get props => [];
}

class LoadData extends FilmInfoBlocEvent {
  final MovieDetails? movieDetails;

  const LoadData(
    this.movieDetails,
  );
}
