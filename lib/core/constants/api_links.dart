class ApiLinks {
  static const String baseUrl =
      'https://ghostwhite-penguin-556356.hostingersite.com';

  // Quiz endpoints
  static const String getQuizzes = '$baseUrl/get-quizzes';
  static const String addQuiz = '$baseUrl/store-quiz';

  // Video endpoints
  static const String getVideos = '$baseUrl/get-videos';
  static const String addVideo = '$baseUrl/store-video';
  static const String uploadVideo = '$baseUrl/api/upload-video';
}
