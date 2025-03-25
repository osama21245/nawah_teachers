class VideoModel {
  final String? id;
  final String title;
  final String description;
  final String teacherId;
  final String videoUrl;
  final String? thumbnailUrl;
  final int teachingLevelId;
  final double? uploadProgress;

  VideoModel({
    this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.teachingLevelId,
    this.uploadProgress,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'teacher_id': teacherId,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'teaching_level_id': teachingLevelId,
    };
  }

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id']?.toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      teacherId: map['teacher_id']?.toString() ?? '',
      videoUrl: map['video_url'] ?? '',
      thumbnailUrl: map['thumbnail_url'],
      teachingLevelId: map['teaching_level_id'] ?? 0,
    );
  }

  VideoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? teacherId,
    String? videoUrl,
    String? thumbnailUrl,
    int? teachingLevelId,
    double? uploadProgress,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      teachingLevelId: teachingLevelId ?? this.teachingLevelId,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}
