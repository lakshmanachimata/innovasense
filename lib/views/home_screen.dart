import 'package:FitApp/views/IntroScreen.dart';
import 'package:flutter/material.dart';
import '../services/user_service.dart';

import 'test_screen.dart';
import 'profile_screen.dart';
import 'otp_screen.dart';
import 'user_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userDetails;
  String _username = 'User Name';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final userDetails = await UserService.getUserDetails();
    if (userDetails != null) {
      setState(() {
        _userDetails = userDetails;
        _username = userDetails['username'] ?? 'User Name';
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Clear all SharedPreferences
      await UserService.logout();
      
      // Navigate to OTPScreen and clear all previous routes
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const OTPScreen(),
          ),
          (route) => false, // This removes all previous routes
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      // Even if there's an error, still navigate to OTPScreen
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const OTPScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logged_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header Bar
                Container(
                  width: double.infinity,
                  height: 60,
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logout Icon
                        GestureDetector(
                          onTap: () {
                            _logout(context);
                          },
                          child: const Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        // innovosens Text
                        const Text(
                          'innovosens',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Logo
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/i_top.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Welcome Section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Welcome',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _username,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Navigation Buttons Grid
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TestScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                height: 140,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.withOpacity(0.3),
                                      Colors.blue.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Take a Test',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Top Right - History
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UserHistoryScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                height: 140,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.withOpacity(0.3),
                                      Colors.blue.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.history,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'History',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Bottom Left - My Profile
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                height: 140,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.withOpacity(0.3),
                                      Colors.blue.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'My Profile',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Bottom Right - Logout
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _showLogoutDialog(context);
                              },
                              child: Container(
                                height: 140,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.withOpacity(0.3),
                                      Colors.blue.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await UserService.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const IntroScreen()),
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
