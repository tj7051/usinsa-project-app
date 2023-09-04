import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageUploader {
  static Future<String?> uploadImage(Uint8List imageBytes, String bid, String uploaderId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token") ?? "";
      String url = 'http://10.0.2.2:8000/file-service/fileupload';

      var formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(imageBytes, filename: 'image.jpg'),
        'bid': bid,
        'uploaderId': uploaderId,
      });

      Dio dio = Dio();
      dio.options.headers['Authorization'] = token;

      var response = await dio.post(url, data: formData);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.data);
        String imageUrl = responseData['imageUrl'];
        return imageUrl;
      } else {
        print('Failed to upload image');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  static Future<bool> deleteImage(String bid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token") ?? "";
      String url = 'http://10.0.2.2:8000/file-service/filedelete';

      Map<String, dynamic> body = {
        'bid': bid,
      };

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept-Charset": "utf-8",
          "Authorization": token,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('이미지 삭제 성공');
        return true;
      } else {
        print('이미지 삭제 실패');
        return false;
      }
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}