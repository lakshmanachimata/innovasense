import 'package:flutter/material.dart';

import '../services/user_service.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      final userDetails = await UserService.getUserDetails();
      setState(() {
        _userDetails = userDetails;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user details: $e');
      setState(() {
        _isLoading = false;
      });
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
                        // Back Arrow
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        // Profile Text
                        const Text(
                          'My Profile',
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
                // Main Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : _userDetails == null
                        ? _buildNoDataView()
                        : _buildProfileTable(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, color: Colors.white70, size: 64),
          const SizedBox(height: 16),
          const Text(
            'No Profile Data Available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please complete your profile setup to view details',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadUserDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Refresh',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTable() {
    final profileData = [
      {'Name': 'Username', 'Value': _userDetails!['username'] ?? 'N/A'},
      {'Name': 'Age', 'Value': '${_userDetails!['age'] ?? 'N/A'} years'},
      {'Name': 'Gender', 'Value': _userDetails!['gender'] ?? 'N/A'},
      {'Name': 'Height', 'Value': '${_userDetails!['height'] ?? 'N/A'} cm'},
      {'Name': 'Weight', 'Value': '${_userDetails!['weight'] ?? 'N/A'} kg'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Header
        const Text(
          'Profile Information',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your account details and personal information',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 32),

        // Profile Table
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Name',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Value',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Table Rows
              ...profileData.map(
                (row) => Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            row['Name']!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            row['Value']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // const SizedBox(height: 32),

        // // Action Buttons
        // Row(
        //   children: [
        //     Expanded(
        //       child: ElevatedButton(
        //         onPressed: () {
        //           // TODO: Implement edit profile functionality
        //           ScaffoldMessenger.of(context).showSnackBar(
        //             const SnackBar(
        //               content: Text('Edit profile functionality coming soon!'),
        //               backgroundColor: Colors.blue,
        //             ),
        //           );
        //         },
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: const Color(0xFF1E3A8A),
        //           padding: const EdgeInsets.symmetric(vertical: 16),
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(8),
        //           ),
        //         ),
        //         child: const Text(
        //           'Edit Profile',
        //           style: TextStyle(
        //             color: Colors.white,
        //             fontSize: 16,
        //             fontWeight: FontWeight.w600,
        //           ),
        //         ),
        //       ),
        //     ),
        //     const SizedBox(width: 16),
        //     Expanded(
        //       child: ElevatedButton(
        //         onPressed: _loadUserDetails,
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: const Color(0xFF059669),
        //           padding: const EdgeInsets.symmetric(vertical: 16),
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(8),
        //           ),
        //         ),
        //         child: const Text(
        //           'Refresh',
        //           style: TextStyle(
        //             color: Colors.white,
        //             fontSize: 16,
        //             fontWeight: FontWeight.w600,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}
