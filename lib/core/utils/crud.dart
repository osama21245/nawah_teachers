import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:dio/io.dart';

import '../constants/api_links.dart';

String _basicAuth = 'Basic ${base64Encode(utf8.encode("osama:osama1234"))}';

Map<String, String> myheaders = {'authorization': _basicAuth};

class Crud {
  final Dio dio;

  Crud({required this.dio}) {
    // Configure Dio defaults
    dio.options.followRedirects = true;
    dio.options.maxRedirects = 5;
    dio.options.validateStatus = (status) {
      return status != null && status < 500;
    };
  }

  Future<Map<String, dynamic>> postData(
      String link, Map<String, dynamic> data) async {
    try {
      print('Making POST request to: $link');
      print('Request data: $data');

      final response = await dio.post(
        link,
        data: data,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else if (response.statusCode == 301 || response.statusCode == 302) {
        // Handle redirect manually
        final newUrl = response.headers.value('location');
        print('Redirect URL: $newUrl');

        if (newUrl != null) {
          final redirectResponse = await dio.post(
            newUrl,
            data: data,
            options: Options(
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          );

          print('Redirect response status: ${redirectResponse.statusCode}');
          print('Redirect response data: ${redirectResponse.data}');

          return redirectResponse.data;
        }
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Server returned status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      print('DioException details:');
      print('Type: ${e.type}');
      print('Message: ${e.message}');
      print('Error: ${e.error}');
      print('Response: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
      print('Response headers: ${e.response?.headers}');
      print('Request: ${e.requestOptions.uri}');
      print('Request data: ${e.requestOptions.data}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getData(String link) async {
    try {
      print('Making GET request to: $link');

      final response = await dio.get(
        link,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Server returned status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      print('DioException details:');
      print('Type: ${e.type}');
      print('Message: ${e.message}');
      print('Error: ${e.error}');
      print('Response: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
      print('Request: ${e.requestOptions.uri}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadFile({
    required String link,
    required File file,
    required String fileField,
    required Map<String, dynamic> data,
    Function(double)? onProgress,
  }) async {
    try {
      print('Uploading file to: $link');

      // Create form data
      final formData = FormData.fromMap({
        ...data,
        fileField: await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await dio.post(
        link,
        data: formData,
        onSendProgress: (sent, total) {
          if (total != -1) {
            final progress = (sent / total);
            print('Upload Progress: ${(progress * 100).toStringAsFixed(2)}%');
            onProgress?.call(progress);
          }
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Server returned status code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      print('DioException details:');
      print('Type: ${e.type}');
      print('Message: ${e.message}');
      print('Error: ${e.error}');
      print('Response: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
      print('Request: ${e.requestOptions.uri}');
      rethrow;
    }
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final response = await http
          .get(Uri.parse('https://google.com'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Future<Map> multiPostData(File imageFile, String link, Map data) async {
  //   final url = Uri.parse(link);
  //   var request = http.MultipartRequest('POST', url)
  //     ..fields['name'] = data["name"] // إضافة الاسم كحقل نصي
  //     ..files.add(await http.MultipartFile.fromPath(
  //       'image',
  //       imageFile.path,
  //     ));
  //   var response = await request.send();

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     var responseBody = await response.stream.bytesToString();
  //     var decodedResponse = jsonDecode(responseBody);
  //     print(decodedResponse);
  //     final res = decodedResponse;
  //     return res;
  //   } else {
  //     throw const ServerException(message: "Server Error");
  //   }
  // }

  Future<Map> multiListPostData(
      List<File> imageFiles, String link, Map data) async {
    final url = Uri.parse(link);
    var request = http.MultipartRequest('POST', url)
      ..fields['name'] = data["name"]; // Add the name as a text field

    for (var imageFile in imageFiles) {
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        imageFile.path,
      ));
    }

    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      var responseBody = await response.stream.bytesToString();
      var decodedResponse = jsonDecode(responseBody);
      print(decodedResponse);
      final res = decodedResponse;
      return res;
    } else {
      throw Exception("Server Error");
    }
  }

  // Future<Either<StatusRequest, Map>> postDataPayment(
  //   String linkurl,
  //   Map data,
  // ) async {
  //   if (await checkInternet()) {
  //     var response = await http.post(Uri.parse(linkurl),
  //         body: jsonEncode(data),
  //         headers: {'Content-Type': 'application/json'});
  //     print(response.statusCode);

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       Map responsebody = jsonDecode(response.body);
  //       print(responsebody);

  //       return right(responsebody);
  //     } else {
  //       return const Left(StatusRequest.serverfailure);
  //     }
  //   } else {
  //     return const Left(StatusRequest.offlinefaliure);
  //   }
  // }

  Future<bool> testConnection() async {
    try {
      print('Testing connection to: ${ApiLinks.baseUrl}');
      final response = await dio.get(ApiLinks.baseUrl);
      print('Test connection successful: ${response.statusCode}');
      return true;
    } catch (e) {
      print('Test connection failed: $e');
      return false;
    }
  }
}
