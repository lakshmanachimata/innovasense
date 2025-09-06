import 'dart:convert';

import 'package:FitApp/services/user_service.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/sweat_image_model.dart';

class SweatImagesService {
  static Future<List<SweatImageModel>> getSweatImages({
    required String cnumber,
    required String username,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/Services/protected/getSweatImages',
      );
      final jwtToken = await UserService.getJwtToken();
      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode({'cnumber': cnumber, 'username': username}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 0 && data['response'] != null) {
          final List<dynamic> responseList = data['response'];
          return responseList
              .map((json) => SweatImageModel.fromJson(json))
              .toList();
        } else {
          throw Exception(
            'API returned error: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to load sweat images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sweat images: $e');
    }
  }
}
