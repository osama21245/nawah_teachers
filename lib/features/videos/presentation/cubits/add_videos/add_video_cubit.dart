import 'dart:io';

import 'package:bloc/bloc.dart';
import '../add_video_state.dart';
import '../../../data/model/video_model.dart';
import '../../../data/repository/videos_repository.dart';

class AddVideoCubit extends Cubit<AddVideoCubitState> {
  AddVideoCubit(this.videosRepository)
      : super(AddVideoCubitState(state: AddVideoState.initial));

  final VideosRepository videosRepository;

  Future<void> addVideo(VideoModel video) async {
    emit(state.copyWith(state: AddVideoState.loading));
    print('Cubit: Adding video');
    final result = await videosRepository.addVideo(video);
    result.fold(
      (failure) {
        print('Cubit: Failed to add video - ${failure.message}');
        emit(state.copyWith(
          state: AddVideoState.failure,
          errorMessage: failure.message,
        ));
      },
      (video) {
        print('Cubit: Successfully added video');
        emit(state.copyWith(
          state: AddVideoState.success,
          video: video,
        ));
      },
    );
  }

  Future<void> uploadVideoFile({
    required File videoFile,
    required String title,
    required int teachingLevelId,
    required String teacherId,
    String? description,
  }) async {
    emit(state.copyWith(
      state: AddVideoState.uploading,
      uploadProgress: 0.0,
    ));

    print('Cubit: Uploading video file');

    final result = await videosRepository.uploadVideoFile(
      videoFile: videoFile,
      title: title,
      teachingLevelId: teachingLevelId,
      teacherId: teacherId,
      description: description,
      onProgress: (progress) {
        emit(state.copyWith(uploadProgress: progress));
      },
    );

    result.fold(
      (failure) {
        print('Cubit: Failed to upload video - ${failure.message}');
        emit(state.copyWith(
          state: AddVideoState.failure,
          errorMessage: failure.message,
        ));
      },
      (video) {
        print('Cubit: Successfully uploaded video');
        emit(state.copyWith(
          state: AddVideoState.success,
          video: video,
        ));
      },
    );
  }
}
