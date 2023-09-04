import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ImageBuilder {
  static Future<Uint8List?> loadImageFromServer(String id) async {
    try {
      String url = 'http://10.0.2.2:8000/file-service/image/$id';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image from server');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  static Widget buildItemImage(Uint8List? imageBytes) {
    if (imageBytes != null) {
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'asset/image2.jpg',
        fit: BoxFit.cover,
      );
    }
  }
}