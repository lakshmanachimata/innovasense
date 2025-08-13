import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/device_model.dart';

class DeviceService {
  static Future<DeviceResponse> getDevices() async {
    try {
      print('Calling getDevices API...');
      print('API URL: ${ApiConfig.baseUrl}/Services/getDevices');
      
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/Services/getDevices'),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({}),
          )
          .timeout(const Duration(seconds: 30));

      print('getDevices API Response Status: ${response.statusCode}');
      print('getDevices API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final deviceResponse = DeviceResponse.fromJson(responseData);
        
        if (deviceResponse.code == 0) {
          print('Devices fetched successfully: ${deviceResponse.response.length} devices');
          return deviceResponse;
        } else {
          throw Exception('getDevices API failed: ${deviceResponse.message}');
        }
      } else {
        throw Exception(
          'getDevices API failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching devices: $e');
      rethrow;
    }
  }
}
