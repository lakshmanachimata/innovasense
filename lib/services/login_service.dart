import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'encrypt_decrypt_service.dart';
import 'user_service.dart';

class LoginService {
  static Future<Map<String, dynamic>> login(
    String cnumber,
    String userpin,
  ) async {
    try {
      // Initialize encryption service
      final encryptService = EncryptDecryptService();

      // Encrypt sensitive data
      final encryptedCNumber = encryptService.getEncryptData(cnumber);
      final encryptedUserPin = encryptService.getEncryptData(userpin);

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/Services/innovologin'),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'cnumber': encryptedCNumber,
              'userpin': encryptedUserPin,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout. Please check your connection.');
            },
          );

      print('Login API Response Status: ${response.statusCode}');
      print('Login API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Store login response if successful
        if (responseData['code'] == 0) {
          await UserService.storeLoginResponse(responseData);
        }
        
        return responseData;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Login service error: $e');
      rethrow;
    }
  }
}
