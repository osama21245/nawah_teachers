import '../../data/model/video_model.dart';

enum AddVideoState {
  initial,
  loading,
  uploading,
  success,
  failure,
}

extension AddVideoStateExtension on AddVideoCubitState {
  bool isInitial() => state == AddVideoState.initial;
  bool isLoading() => state == AddVideoState.loading;
  bool isUploading() => state == AddVideoState.uploading;
  bool isSuccess() => state == AddVideoState.success;
  bool isFailure() => state == AddVideoState.failure;
}

class AddVideoCubitState {
  final AddVideoState state;
  final VideoModel? video;
  final String? errorMessage;
  final double? uploadProgress;

  AddVideoCubitState({
    required this.state,
    this.video,
    this.errorMessage,
    this.uploadProgress,
  });

  AddVideoCubitState copyWith({
    AddVideoState? state,
    VideoModel? video,
    String? errorMessage,
    double? uploadProgress,
  }) {
    return AddVideoCubitState(
      state: state ?? this.state,
      video: video ?? this.video,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  @override
  String toString() =>
      'AddVideoCubitState(state: $state, video: $video, errorMessage: $errorMessage, uploadProgress: $uploadProgress)';

  @override
  bool operator ==(covariant AddVideoCubitState other) {
    if (identical(this, other)) return true;

    return other.state == state &&
        other.video == video &&
        other.errorMessage == errorMessage &&
        other.uploadProgress == uploadProgress;
  }

  @override
  int get hashCode =>
      state.hashCode ^
      video.hashCode ^
      errorMessage.hashCode ^
      (uploadProgress?.hashCode ?? 0);
}
