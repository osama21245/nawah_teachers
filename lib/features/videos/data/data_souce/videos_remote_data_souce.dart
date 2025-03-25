import 'dart:io';

import '../../../../core/constants/api_links.dart';
import '../../../../core/utils/crud.dart';
import '../../../../core/utils/try_and_catch.dart';
import '../model/video_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class VideosRemoteDataSouce {
  Future<Map<String, dynamic>> addVideo(VideoModel video);
  Future<List<Map<String, dynamic>>> getVideos();
  Future<Map<String, dynamic>> uploadVideoFile({
    required File videoFile,
    required String title,
    required int teachingLevelId,
    required String teacherId,
    String? description,
    Function(double)? onProgress,
  });
}

class VideosRemoteDataSouceImpl extends VideosRemoteDataSouce {
  final Crud crud;

  VideosRemoteDataSouceImpl(this.crud);

  @override
  Future<Map<String, dynamic>> addVideo(VideoModel video) async {
    return executeTryAndCatchForDataLayer(() async {
      final response = await crud.postData(
        ApiLinks.addVideo,
        video.toMap(),
      );
      return response;
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getVideos() async {
    return executeTryAndCatchForDataLayer(() async {
      final response = await crud.postData(ApiLinks.getVideos, {});
      return (response['data'] as List)
          .map((video) => video as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Future<Map<String, dynamic>> uploadVideoFile({
    required File videoFile,
    required String title,
    required int teachingLevelId,
    required String teacherId,
    String? description,
    Function(double)? onProgress,
  }) async {
    return executeTryAndCatchForDataLayer(() async {
      // Prepare data for the request
      final data = {
        'title': title,
        'teaching_level_id': teachingLevelId,
        'teacher_id': teacherId,
        'description': description ?? '',
      };

      // Use the crud.uploadFile method
      final response = await crud.uploadFile(
        link: ApiLinks.uploadVideo,
        file: videoFile,
        fileField: 'video',
        data: data,
        onProgress: onProgress,
      );

      return response;
    });
  }
}
