part of 'film_info_Bloc.dart';

class FilmInfoBlocState extends Equatable {
  final MovieDetails? movieDetails;

  const FilmInfoBlocState({
    this.movieDetails,
  });

  @override
  List<Object?> get props => [movieDetails];
}

class FilmFavouriteInittial extends FilmInfoBlocState {}

class FilmFavouriteLoading extends FilmInfoBlocState {}

class FilmFavouriteSuccess extends FilmInfoBlocState {}

class FilmFavouriteFailure extends FilmInfoBlocState {
  final String error;

  const FilmFavouriteFailure({required this.error});

  @override
  List<Object> get props => [error];
}
