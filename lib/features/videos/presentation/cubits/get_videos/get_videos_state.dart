import '../../../data/model/video_model.dart';

enum GetVideosState {
  initial,
  loading,
  success,
  failure,
}

extension GetVideosStateExtension on GetVideosCubitState {
  bool isInitial() => state == GetVideosState.initial;
  bool isLoading() => state == GetVideosState.loading;
  bool isSuccess() => state == GetVideosState.success;
  bool isFailure() => state == GetVideosState.failure;
}

class GetVideosCubitState {
  final GetVideosState state;
  final List<VideoModel>? videos;
  final String? errorMessage;

  GetVideosCubitState({
    required this.state,
    this.videos,
    this.errorMessage,
  });

  GetVideosCubitState copyWith({
    GetVideosState? state,
    List<VideoModel>? videos,
    String? errorMessage,
  }) {
    return GetVideosCubitState(
      state: state ?? this.state,
      videos: videos ?? this.videos,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() =>
      'GetVideosCubitState(state: $state, videos: $videos, errorMessage: $errorMessage)';

  @override
  bool operator ==(covariant GetVideosCubitState other) {
    if (identical(this, other)) return true;

    return other.state == state &&
        other.videos == videos &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => state.hashCode ^ videos.hashCode ^ errorMessage.hashCode;
}
