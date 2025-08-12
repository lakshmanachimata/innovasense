import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'user_service.dart';

class ImageUploadService {
  static Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    try {
      // Get JWT token for authorization
      final jwtToken = await UserService.getJwtToken();
      if (jwtToken == null) {
        throw Exception('No JWT token found. Please login again.');
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/Services/protected/uploadInnovoImage'),
      );

      // Add headers
      request.headers['accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $jwtToken';

      // Add image file
      final imageStream = http.ByteStream(imageFile.openRead());
      final imageLength = await imageFile.length();
      
      final multipartFile = http.MultipartFile(
        'image',
        imageStream,
        imageLength,
        filename: imageFile.path.split('/').last,
      );
      
      request.files.add(multipartFile);

      print('Uploading image: ${imageFile.path}');
      print('Image size: $imageLength bytes');
      print('JWT Token: ${jwtToken.substring(0, 20)}...');

      // Send request
      final response = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();

      print('Upload response status: ${response.statusCode}');
      print('Upload response body: $responseBody');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        if (responseData['code'] == 0) {
          print('Image uploaded successfully: ${responseData['response']['filename']}');
          return responseData;
        } else {
          throw Exception('Upload failed: ${responseData['message']}');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }
}
