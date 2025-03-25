import 'package:bloc/bloc.dart';
import 'get_videos_state.dart';
import '../../../data/repository/videos_repository.dart';

class GetVideosCubit extends Cubit<GetVideosCubitState> {
  GetVideosCubit(this.videosRepository)
      : super(GetVideosCubitState(state: GetVideosState.initial));

  final VideosRepository videosRepository;

  Future<void> getVideos() async {
    emit(state.copyWith(state: GetVideosState.loading));
    print('Cubit: Getting videos');
    final result = await videosRepository.getVideos();
    result.fold(
      (failure) {
        print('Cubit: Failed to get videos - ${failure.message}');
        emit(state.copyWith(
          state: GetVideosState.failure,
          errorMessage: failure.message,
        ));
      },
      (videos) {
        print('Cubit: Successfully got videos');
        emit(state.copyWith(
          state: GetVideosState.success,
          videos: videos,
        ));
      },
    );
  }
}
