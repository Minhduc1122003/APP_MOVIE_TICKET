import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app_chat/models/Movie_modal.dart';
import 'package:equatable/equatable.dart';
import 'package:socket_io_client/socket_io_client.dart';

// Phần định nghĩa của state
part 'film_info_Bloc_State.dart';
// Phần định nghĩa của event
part 'film_info_Bloc_event.dart';

class FilmInfoBloc extends Bloc<FilmInfoBlocEvent, FilmInfoBlocState> {
  FilmInfoBloc() : super(FilmInfoBlocState()) {
    on<LoadData>(_onLoadData);
    on<ClickFavourite>(_onClickFavourite);
  }

  void _onLoadData(LoadData event, Emitter<FilmInfoBlocState> emit) {
    print('onloadData: ${event.movieDetails?.favourite}');
    emit(FilmInfoBlocState(
      movieDetails: event.movieDetails,
    ));
  }

  void _onClickFavourite(
      ClickFavourite event, Emitter<FilmInfoBlocState> emit) async {
    // Phát sự kiện loading khi bắt đầu
    emit(FilmFavouriteLoading());

    final bool currentFavourite = event.movieDetails?.favourite ?? false;

    try {
      final ApiService apiService = ApiService();
      final Map<String, dynamic> response;

      // Xử lý thêm hoặc xóa favourite dựa trên trạng thái hiện tại
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
          final bool newFavourite = !currentFavourite;

          // Cập nhật thuộc tính favourite trong state
        } else {
          emit(FilmFavouriteFailure(error: 'Operation failed'));
        }
      } else {
        emit(FilmFavouriteFailure(error: 'No response from server'));
      }
    } catch (e) {
      emit(FilmFavouriteFailure(error: e.toString()));
    }
  }
}
