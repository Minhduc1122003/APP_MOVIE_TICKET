part of 'film_info_Bloc.dart';

class FilmInfoBlocState extends Equatable {
  final MovieDetails? movieDetails;
  final bool favouriteLoading;

  const FilmInfoBlocState({
    this.movieDetails,
    this.favouriteLoading = false,
  });

  FilmInfoBlocState copyWith({
    MovieDetails? movieDetails,
    bool? favouriteLoading,
  }) {
    return FilmInfoBlocState(
      movieDetails: movieDetails ?? this.movieDetails,
      favouriteLoading: favouriteLoading ?? this.favouriteLoading,
    );
  }

  @override
  List<Object?> get props => [movieDetails, favouriteLoading];
}

class FilmFavouriteInitial extends FilmInfoBlocState {}

class FilmFavouriteLoading extends FilmInfoBlocState {}

class FilmFavouriteSuccess extends FilmInfoBlocState {}

class FilmFavouriteFailure extends FilmInfoBlocState {
  final String error;

  const FilmFavouriteFailure({required this.error});

  @override
  List<Object> get props => [error];
}
