import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/banner_model.dart';
import '../config/api_config.dart';

class BannerService {
  Future<BannerResponse> getBannerImages() async {
    try {
      final url = ApiConfig.bannerEndpoint;
      print('BannerService: Attempting to fetch banners from $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      ).timeout(Duration(seconds: 10));

      print('BannerService: Response status: ${response.statusCode}');
      print('BannerService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return BannerResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load banner images: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('BannerService: Error occurred: $e');
      throw Exception('Error fetching banner images: $e');
    }
  }
}
