import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user_history_model.dart';
import 'encrypt_decrypt_service.dart';
import 'user_service.dart';

class UserHistoryService {
  static Future<UserHistoryResponse> getUserHistory() async {
    try {
      // Get JWT token and user details
      final jwtToken = await UserService.getJwtToken();
      if (jwtToken == null) {
        throw Exception('No JWT token found. Please login again.');
      }

      final userDetails = await UserService.getUserDetails();
      if (userDetails == null) {
        throw Exception('No user details found. Please login again.');
      }

      // Prepare the request payload
      final payload = {
        'email': EncryptDecryptService().getEncryptData(userDetails['email'] ?? ''),
        'username': userDetails['username'] ?? '',
      };

      print('User History API payload: $payload');
      print(
        'User History API URL: ${ApiConfig.baseUrl}/Services/protected/getClientHistory',
      );

      // Make the API call
      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}/Services/protected/getClientHistory',
            ),
            headers: {
              'accept': 'application/json',
              'Authorization': 'Bearer $jwtToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      print('User History API Response Status: ${response.statusCode}');
      print('User History API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Raw API response data: $responseData');
        print('Response type: ${responseData.runtimeType}');
        print('Response field type: ${responseData['response']?.runtimeType}');

        final userHistoryResponse = UserHistoryResponse.fromJson(responseData);

        if (userHistoryResponse.code == 0) {
          print(
            'User history fetched successfully: ${userHistoryResponse.response.length} records',
          );
          return userHistoryResponse;
        } else {
          throw Exception(
            'User History API failed: ${userHistoryResponse.message}',
          );
        }
      } else {
        final respBody = response.body.isNotEmpty
            ? response.body
            : 'No response body';
        throw Exception(
          'User History API failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching user history: $e');
      rethrow;
    }
  }
}
