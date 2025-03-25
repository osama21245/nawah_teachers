import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/erorr/failure.dart';
import '../../../../core/utils/try_and_catch.dart';
import '../data_souce/videos_remote_data_souce.dart';
import '../model/video_model.dart';

class VideosRepository {
  final VideosRemoteDataSouce remoteDataSouce;

  VideosRepository(this.remoteDataSouce);

  Future<Either<Failure, VideoModel>> addVideo(VideoModel video) async {
    return executeTryAndCatchForRepository(() async {
      final response = await remoteDataSouce.addVideo(video);
      return VideoModel.fromMap(response['video'] as Map<String, dynamic>);
    });
  }

  Future<Either<Failure, List<VideoModel>>> getVideos() async {
    return executeTryAndCatchForRepository(() async {
      final videos = await remoteDataSouce.getVideos();
      return videos.map((video) => VideoModel.fromMap(video)).toList();
    });
  }

  Future<Either<Failure, VideoModel>> uploadVideoFile({
    required File videoFile,
    required String title,
    required int teachingLevelId,
    required String teacherId,
    String? description,
    Function(double)? onProgress,
  }) async {
    return executeTryAndCatchForRepository(() async {
      final response = await remoteDataSouce.uploadVideoFile(
        videoFile: videoFile,
        title: title,
        teachingLevelId: teachingLevelId,
        teacherId: teacherId,
        description: description,
        onProgress: onProgress,
      );

      if (response['success'] == true && response['video'] != null) {
        return VideoModel.fromMap(response['video'] as Map<String, dynamic>);
      } else {
        throw Exception(response['error'] ?? 'Upload failed');
      }
    });
  }
}
