part of 'film_info_Bloc.dart';

sealed class FilmInfoBlocEvent extends Equatable {
  const FilmInfoBlocEvent();

  @override
  List<Object> get props => [];
}

class LoadData extends FilmInfoBlocEvent {
  final MovieDetails? movieDetails;

  const LoadData(this.movieDetails);

  @override
  List<Object?> get prop => [movieDetails];
}

class ClickFavourite extends FilmInfoBlocEvent {
  final MovieDetails? movieDetails;
  final int movieId;
  final int userId;

  const ClickFavourite(this.movieDetails, this.movieId, this.userId);

  @override
  List<Object?> get props1 => [movieDetails, movieId, userId];
}
