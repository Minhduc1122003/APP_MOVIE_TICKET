import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:equatable/equatable.dart';

// Phần định nghĩa của state
part 'film_info_Bloc_State.dart';
// Phần định nghĩa của event
part 'film_info_Bloc_event.dart';

class FilmInfoBloc extends Bloc<FilmInfoBlocEvent, FilmInfoBlocState> {
  FilmInfoBloc() : super(FilmFavouriteInitial()) {
    on<LoadData>(_onLoadData);
    on<ClickFavourite>(_onClickFavourite);
  }

  void _onLoadData(LoadData event, Emitter<FilmInfoBlocState> emit) {
    // Cập nhật thông tin phim mà không thay đổi trạng thái loading
    emit(state.copyWith(movieDetails: event.movieDetails));
  }

  void _onClickFavourite(
      ClickFavourite event, Emitter<FilmInfoBlocState> emit) async {
    emit(state.copyWith(favouriteLoading: true)); // Đặt trạng thái loading

    final bool currentFavourite = event.movieDetails?.favourite ?? false;

    try {
      final ApiService apiService = ApiService();
      final Map<String, dynamic> response;

      if (currentFavourite) {
        response =
            await apiService.removeFavourite(event.movieId, event.userId);
      } else {
        response = await apiService.addFavourite(event.movieId, event.userId);
      }

      if (response != null) {
        final String message = response['message'];
        if ((currentFavourite && message == 'Favourite removed successfully') ||
            (!currentFavourite && message == 'Favourite added successfully')) {
          final updatedMovieDetails = event.movieDetails?.copyWith(
            favourite: !currentFavourite,
          );
          emit(state.copyWith(
            movieDetails: updatedMovieDetails,
            favouriteLoading: false,
          ));
        }
      }
    } catch (e) {
      emit(state.copyWith(favouriteLoading: false));
      emit(FilmFavouriteFailure(error: e.toString()));
    }
  }
}
