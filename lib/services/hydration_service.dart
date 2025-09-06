import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'user_service.dart';

class HydrationService {
  static Future<Map<String, dynamic>> submitHydrationData({
    required int deviceType,
    required int height,
    required int sweatPosition,
    required int timeTaken,
    required int weight,
    required int imageId,
    required String imagePath,
  }) async {
    try {
      // Get JWT token for authorization
      final jwtToken = await UserService.getJwtToken();
      if (jwtToken == null) {
        throw Exception('No JWT token found. Please login again.');
      }

      // Get user details for cnumber, userid, and username
      final userDetails = await UserService.getUserDetails();
      if (userDetails == null) {
        throw Exception('No user details found. Please login again.');
      }

      // Prepare the request payload
      final payload = {
        "cnumber": userDetails['cnumber'] ?? '',
        "device_type": deviceType,
        "height": height,
        "image_id": imageId,
        "image_path": imagePath,
        "sweat_position": sweatPosition,
        "time_taken": timeTaken,
        "userid": userDetails['id'] ?? 0,
        "username": userDetails['username'] ?? '',
        "weight": weight,
      };

      print('Hydration API payload: $payload');
      print(
        'Hydration API URL: ${ApiConfig.baseUrl}/Services/protected/newinnovoHyderation',
      );

      // Make the API call
      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}/Services/protected/newinnovoHyderation',
            ),
            headers: {
              'accept': 'application/json',
              'Authorization': 'Bearer $jwtToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      print('Hydration API Response Status: ${response.statusCode}');
      print('Hydration API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 0) {
          print(
            'Hydration data submitted successfully: ${responseData['response']['id']}',
          );
          return responseData;
        } else {
          throw Exception('Hydration API failed: ${responseData['message']}');
        }
      } else {
        final respBody = response.body.isNotEmpty
            ? response.body
            : 'No response body';
        throw Exception(
          'Hydration API failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error submitting hydration data: $e');
      rethrow;
    }
  }
}
