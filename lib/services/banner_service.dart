import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/banner_model.dart';

class BannerService {
  Future<BannerResponse> getBannerImages() async {
    try {
      final url = ApiConfig.bannerEndpoint;
      print('BannerService: Attempting to fetch banners from $url');

      // Get auth headers with JWT token if available
      // final headers = await UserService.getAuthHeaders();
      // headers['accept'] = 'application/json';

      final response = await http
          .post(Uri.parse(url), body: jsonEncode({}))
          .timeout(Duration(seconds: 10));

      print('BannerService: Response status: ${response.statusCode}');
      print('BannerService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return BannerResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load banner images: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('BannerService: Error occurred: $e');
      throw Exception('Error fetching banner images: $e');
    }
  }
}
