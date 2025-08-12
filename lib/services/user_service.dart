import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _jwtTokenKey = 'jwt_token';
  static const String _userDetailsKey = 'user_details';
  static const String _isLoggedInKey = 'is_logged_in';

  // Store JWT token
  static Future<void> storeJwtToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_jwtTokenKey, token);
    } catch (e) {
      print('Error storing JWT token: $e');
      // Fallback: store in memory or handle error gracefully
    }
  }

  // Get JWT token
  static Future<String?> getJwtToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_jwtTokenKey);
    } catch (e) {
      print('Error getting JWT token: $e');
      return null;
    }
  }

  // Store user details
  static Future<void> storeUserDetails(Map<String, dynamic> userDetails) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDetailsKey, jsonEncode(userDetails));
    } catch (e) {
      print('Error storing user details: $e');
      // Fallback: store in memory or handle error gracefully
    }
  }

  // Get user details
  static Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDetailsString = prefs.getString(_userDetailsKey);
      if (userDetailsString != null) {
        return jsonDecode(userDetailsString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user details: $e');
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isLoggedin = prefs.getBool(_isLoggedInKey) ?? false;
      return isLoggedin;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Set login status
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, isLoggedIn);
    } catch (e) {
      print('Error setting login status: $e');
      // Fallback: store in memory or handle error gracefully
    }
  }

  // Store complete login response
  static Future<void> storeLoginResponse(Map<String, dynamic> response) async {
    if (response['code'] == 0) {
      await storeJwtToken(response['jwt_token']);
      await storeUserDetails(response['userdetails']);
      await setLoggedIn(true);
    }
  }

  // Clear all user data (logout)
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_jwtTokenKey);
      await prefs.remove(_userDetailsKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      print('Error during logout: $e');
      // Fallback: clear in memory or handle error gracefully
    }
  }

  // Get authorization header for API calls
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getJwtToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    return {'Content-Type': 'application/json'};
  }
}
