import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../services/hydration_service.dart';
import '../services/image_upload_service.dart';
import '../services/user_service.dart';
import '../viewmodels/hydration_viewmodel.dart';
import '../viewmodels/device_viewmodel.dart';
import '../models/device_model.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'test_summary_screen.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Store uploaded image response
  Map<String, dynamic>? _uploadedImageResponse;

  // Track submission state
  bool _isSubmitting = false;

  // Form controllers for the 5 test parameters
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _sweatPositionController =
      TextEditingController();
  final TextEditingController _timeTakenController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  // Selected device ID for the dropdown
  int? _selectedDeviceId;

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Add listeners to all text controllers to update UI when text changes
    _heightController.addListener(() => setState(() {}));
    _sweatPositionController.addListener(() => setState(() {}));
    _timeTakenController.addListener(() => setState(() {}));
    _weightController.addListener(() => setState(() {}));

    // Load user details and prefill height and weight fields
    _loadUserDetails();
    
    // Fetch devices for the dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceViewModel>().fetchDevices();
    });
  }

  @override
  void dispose() {
    _heightController.dispose();
    _sweatPositionController.dispose();
    _timeTakenController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // Helper method to check if all form fields are filled
  bool _areAllFieldsFilled() {
    return _selectedDeviceId != null &&
        _heightController.text.trim().isNotEmpty &&
        _sweatPositionController.text.trim().isNotEmpty &&
        _timeTakenController.text.trim().isNotEmpty &&
        _weightController.text.trim().isNotEmpty;
  }

  // Load user details and prefill height and weight fields
  Future<void> _loadUserDetails() async {
    try {
      final userDetails = await UserService.getUserDetails();
      if (userDetails != null) {
        setState(() {
          // Prefill height if available
          if (userDetails['height'] != null) {
            _heightController.text = userDetails['height'].toString();
          }

          // Prefill weight if available
          if (userDetails['weight'] != null) {
            _weightController.text = userDetails['weight'].toString();
          }
        });

        print(
          'User details loaded and prefilled: height=${userDetails['height']}, weight=${userDetails['weight']}',
        );
      } else {
        print('No user details found to prefill');
      }
    } catch (e) {
      print('Error loading user details: $e');
    }
  }

  // Handle image upload and form submission
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading state
      setState(() {
        _isSubmitting = true;
      });

      // First upload the image
      print('Starting image upload...');
      final uploadResponse = await ImageUploadService.uploadImage(
        _selectedImage!,
      );

      // Store the upload response
      _uploadedImageResponse = uploadResponse;

      print(
        'Image uploaded successfully: ${uploadResponse['response']['filename']}',
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Image uploaded: ${uploadResponse['response']['filename']}',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Now call the hydration API with the uploaded image path
      print('Calling hydration API...');

      // Construct the full image path using base URL and uploaded filepath
      final fullImagePath =
          '${ApiConfig.baseUrl.replaceAll(':8500', ':8500')}/assets/innovo/${uploadResponse['response']['filename']}';
      print('Full image path for hydration API: $fullImagePath');

      // Call hydration API
      final hydrationResponse = await HydrationService.submitHydrationData(
        deviceType: _selectedDeviceId ?? 1, // Use selected device ID or default to 1
        height: int.tryParse(_heightController.text) ?? 0,
        sweatPosition: int.tryParse(_sweatPositionController.text) ?? 0,
        timeTaken: int.tryParse(_timeTakenController.text) ?? 0,
        weight: int.tryParse(_weightController.text) ?? 0,
        imagePath: fullImagePath,
      );

      print('Hydration API response received: ${hydrationResponse['code']}');

      // Store the hydration response in the ViewModel
      final hydrationViewModel = Provider.of<HydrationViewModel>(
        context,
        listen: false,
      );
      hydrationViewModel.setHydrationData(hydrationResponse);

      // Store the image upload response for later use
      _uploadedImageResponse = {
        'image_upload': uploadResponse,
        'hydration_data': hydrationResponse,
      };

      // Show success message for hydration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hydration analysis completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to TestSummaryScreen - data is now available in HydrationViewModel
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TestSummaryScreen(hydrationViewModel: hydrationViewModel),
        ),
      );
    } catch (e) {
      print('Error during submit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Reset loading state
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _uploadPicture() async {
    try {
      // Request storage permission
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      // Show error if permission denied or other error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error: Please grant storage permission to upload image',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
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
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        top: 24.0,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Headline Text
                          const Text(
                            'Hydrate Smarter.\nPerform Better.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Picture Placeholder
                          Center(
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.landscape,
                                      color: Colors.grey,
                                      size: 80,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Upload Picture and Submit Buttons
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : _uploadPicture,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A8A),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: const BorderSide(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _selectedImage != null
                                        ? 'Change Picture'
                                        : 'Upload Picture',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed:
                                      (_selectedImage != null &&
                                          _areAllFieldsFilled() &&
                                          !_isSubmitting)
                                      ? _handleSubmit
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        (_selectedImage != null &&
                                            _areAllFieldsFilled() &&
                                            !_isSubmitting)
                                        ? const Color(0xFF059669)
                                        : Colors.grey,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color:
                                            (_selectedImage != null &&
                                                _areAllFieldsFilled() &&
                                                !_isSubmitting)
                                            ? Colors.white
                                            : Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Test Parameters Form
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Test Parameters',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _loadUserDetails,
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      tooltip: 'Refresh profile data',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'All fields are mandatory *',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Height and Weight are prefilled from your profile',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildDeviceTypeDropdown(),
                                const SizedBox(height: 20),
                                _buildTestParameterField(
                                  'Height (from profile)',
                                  _heightController,
                                  'Enter height in cm',
                                  isNumber: true,
                                ),
                                const SizedBox(height: 20),
                                _buildTestParameterField(
                                  'Sweat Position',
                                  _sweatPositionController,
                                  'Enter sweat position (0-9)',
                                  isNumber: true,
                                ),
                                const SizedBox(height: 20),
                                _buildTestParameterField(
                                  'Time Taken',
                                  _timeTakenController,
                                  'Enter time taken in minutes',
                                  isNumber: true,
                                ),
                                const SizedBox(height: 20),
                                _buildTestParameterField(
                                  'Weight (from profile)',
                                  _weightController,
                                  'Enter weight in kg',
                                  isNumber: true,
                                ),
                                const SizedBox(
                                  height: 40,
                                ), // Extra padding at bottom
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom Navigation Bar
                Container(
                  width: double.infinity,
                  height: 80,
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // Home
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.home,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Home',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Test
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.science,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Test',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Profile
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'My Profile',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Logout
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.logout,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Full-screen loader overlay during image upload
          if (_isSubmitting) _buildUploadLoader(),
        ],
      ),
    );
  }

  // Build upload loader overlay
  Widget _buildUploadLoader() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                strokeWidth: 4,
              ),
              const SizedBox(height: 24),
              const Text(
                'Processing Test Data...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please wait while we upload your image and\nanalyze your hydration data. This may take a few moments.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // Progress indicator with dots animation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 600),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(
                        (DateTime.now().millisecondsSinceEpoch / 600 + index) %
                                    2 ==
                                0
                            ? 1.0
                            : 0.3,
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestParameterField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white, width: 1)),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              if (isNumber && int.tryParse(value.trim()) == null) {
                return '$label must be a valid number';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white70),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              errorStyle: TextStyle(color: Colors.red[300]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceTypeDropdown() {
    return Consumer<DeviceViewModel>(
      builder: (context, deviceViewModel, child) {
        if (deviceViewModel.isLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Device Type',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
          );
        }

        if (deviceViewModel.error != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Device Type',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Error loading devices: ${deviceViewModel.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Device Type',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white, width: 1)),
              ),
              child: DropdownButtonFormField<int>(
                value: _selectedDeviceId,
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedDeviceId = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Device Type is required';
                  }
                  return null;
                },
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                items: deviceViewModel.devices.map<DropdownMenuItem<int>>((DeviceModel device) {
                  return DropdownMenuItem<int>(
                    value: device.id,
                    child: Text(
                      device.deviceName,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
