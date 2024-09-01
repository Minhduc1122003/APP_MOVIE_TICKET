part of 'film_info_Bloc.dart';

class FilmInfoBlocState extends Equatable {
  final MovieDetails? movieDetails;
  final bool isLoading;
  final String? errorMessage;

  const FilmInfoBlocState({
    this.movieDetails,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [movieDetails, isLoading, errorMessage];

  FilmInfoBlocState copyWith({
    MovieDetails? movieDetails,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FilmInfoBlocState(
      movieDetails: movieDetails ?? this.movieDetails,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
