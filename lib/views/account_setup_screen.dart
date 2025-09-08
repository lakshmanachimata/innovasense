import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user_model.dart';
import '../services/encrypt_decrypt_service.dart';
import 'otp_screen.dart';

class AccountSetupScreen extends StatefulWidget {
  const AccountSetupScreen({super.key});

  @override
  State<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends State<AccountSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cnumberController = TextEditingController();
  final _userpinController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedGender = 'Male';
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _cnumberController.dispose();
    _userpinController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize encryption service
      final encryptService = EncryptDecryptService();

      // Encrypt sensitive data
      final encryptedEmail = encryptService.getEncryptData(
        _emailController.text.trim(),
      );
      final encryptedUserPin = encryptService.getEncryptData(
        _userpinController.text,
      );
      final encryptedName = encryptService.getEncryptData(
        _usernameController.text,
      );
      
      // Encrypt contact number only if provided
      String? encryptedCNumber;
      if (_cnumberController.text.trim().isNotEmpty) {
        encryptedCNumber = encryptService.getEncryptData(
          _cnumberController.text.trim(),
        );
      }

      // Prepare user data
      final userData = UserModel(
        username: encryptedName,
        email: encryptedEmail,
        cnumber: encryptedCNumber,
        userpin: encryptedUserPin,
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
        height: double.parse(_heightController.text.trim()),
        weight: int.parse(_weightController.text.trim()),
      );

      print('Creating account with data: ${userData.toJson()}');
      print('Raw CNumber: "${_cnumberController.text.trim()}"');
      print('Raw UserPin: "${_userpinController.text}"');
      print('Encrypted CNumber: "$encryptedCNumber"');
      print('Encrypted UserPin: "$encryptedUserPin"');
      print('API URL: ${ApiConfig.baseUrl}/Services/innovoregister');

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/Services/innovoregister'),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(userData.toJson()),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout. Please check your connection.');
            },
          );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Account created successfully!');

        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to OTP screen (login screen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OTPScreen()),
        );
      } else {
        final errorResponse = jsonDecode(response.body);
        final error = errorResponse['message'] ?? 'Unknown error occurred';
        throw Exception('Failed to create account: $error');
      }
    } catch (e) {
      print('Error creating account: $e');

      // Show error message
      String errorMessage = 'Error creating account';

      if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please check your connection.';
      } else if (e.toString().contains('Failed to create account')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      } else if (e.toString().contains('SocketException')) {
        errorMessage =
            'Connection failed. Please check your internet connection.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
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
                image: AssetImage('assets/images/otp_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    // Header
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join Hydrosense today',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Username Field
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Username',
                      hint: 'Enter your username',
                      enabled: !_isLoading,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Email Field
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email ID *',
                      hint: 'Enter your Email ID',
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // CNumber Field (Optional)
                    _buildTextField(
                      controller: _cnumberController,
                      label: 'Contact Number (Optional)',
                      hint: 'Enter your Contact Number',
                      enabled: !_isLoading,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        // Contact number is optional, but if provided, validate it
                        if (value != null && value.trim().isNotEmpty) {
                          if (value.trim().length < 10) {
                            return 'Contact number must be at least 10 digits';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // UserPin Field
                    _buildTextField(
                      controller: _userpinController,
                      label: 'User PIN',
                      hint: 'Enter your User PIN',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      enabled: !_isLoading,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'UserPin is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Age Field
                    _buildTextField(
                      controller: _ageController,
                      label: 'Age',
                      hint: 'Enter your age',
                      enabled: !_isLoading,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Age is required';
                        }
                        final age = int.tryParse(value.trim());
                        if (age == null || age < 13 || age > 120) {
                          return 'Please enter a valid age (13-120)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Gender Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gender',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildGenderOption(
                                value: 'Male',
                                label: 'Male',
                                icon: Icons.male,
                                enabled: !_isLoading,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildGenderOption(
                                value: 'Female',
                                label: 'Female',
                                icon: Icons.female,
                                enabled: !_isLoading,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Height Field
                    _buildTextField(
                      controller: _heightController,
                      label: 'Height (cm)',
                      hint: 'Enter your height in cm (e.g., 170.5)',
                      enabled: !_isLoading,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Height is required';
                        }
                        final height = double.tryParse(value.trim());
                        if (height == null ||
                            height < 100.0 ||
                            height > 250.0) {
                          return 'Please enter a valid height (100.0-250.0 cm)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Weight Field
                    _buildTextField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      hint: 'Enter your weight in kg',
                      enabled: !_isLoading,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Weight is required';
                        }
                        final weight = int.tryParse(value.trim());
                        if (weight == null || weight < 30 || weight > 300) {
                          return 'Please enter a valid weight (30-300 kg)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Create Account Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Creating Account...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Back to Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isPassword = false,
    bool enabled = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white, width: 1)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            enabled: enabled,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            style: TextStyle(
              color: enabled ? Colors.white : Colors.white.withOpacity(0.5),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required String value,
    required String label,
    required IconData icon,
    bool enabled = true,
  }) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: enabled
          ? () {
              setState(() {
                _selectedGender = value;
              });
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled
                ? (isSelected ? Colors.white : Colors.white.withOpacity(0.5))
                : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: enabled
              ? (isSelected
                    ? Colors.white.withOpacity(0.1)
                    : Colors.transparent)
              : Colors.white.withOpacity(0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: enabled
                  ? (isSelected ? Colors.white : Colors.white.withOpacity(0.7))
                  : Colors.white.withOpacity(0.4),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: enabled
                    ? (isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.7))
                    : Colors.white.withOpacity(0.4),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
