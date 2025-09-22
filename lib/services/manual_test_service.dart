import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/manual_test_model.dart';
import '../config/api_config.dart';

class ManualTestService {
  static Future<Map<String, dynamic>> submitManualTest({
    required ManualTestModel manualTestData,
    required String email,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/Services/submitManualTest');
      
      final payload = {
        'email': email,
        'waterIntake': manualTestData.waterIntake,
        'sleepHours': manualTestData.sleepHours,
        'steps': manualTestData.steps,
      };

      print('ManualTestService: Submitting manual test data');
      print('ManualTestService: URL: $url');
      print('ManualTestService: Payload: $payload');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      print('ManualTestService: Response status: ${response.statusCode}');
      print('ManualTestService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to submit manual test data. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('ManualTestService: Error submitting manual test: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}
