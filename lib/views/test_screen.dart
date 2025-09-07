import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../models/device_model.dart';
import '../models/sweat_image_model.dart';
import '../services/hydration_service.dart';
import '../services/image_upload_service.dart';
import '../services/sweat_images_service.dart';
import '../services/user_service.dart';
import '../viewmodels/device_viewmodel.dart';
import '../viewmodels/hydration_viewmodel.dart';
import 'device_selection_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'sweat_image_selection_screen.dart';
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

  int? imageId;

  // Sweat images state
  List<SweatImageModel> _sweatImages = [];
  bool _isLoadingSweatImages = false;
  String? _sweatImagesError;

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
    bool basicFieldsFilled =
        _selectedDeviceId != null &&
        _heightController.text.trim().isNotEmpty &&
        _sweatPositionController.text.trim().isNotEmpty &&
        _timeTakenController.text.trim().isNotEmpty &&
        _weightController.text.trim().isNotEmpty;

    // For pro devices, sweat image selection is mandatory
    if (_selectedDeviceId != null) {
      final deviceViewModel = Provider.of<DeviceViewModel>(
        context,
        listen: false,
      );
      final selectedDevice = deviceViewModel.devices.firstWhere(
        (device) => device.id == _selectedDeviceId,
        orElse: () => DeviceModel(id: 0, deviceName: '', deviceText: ''),
      );

      if (selectedDevice.deviceName.toLowerCase().contains('pro')) {
        return basicFieldsFilled && imageId != null && imageId != 0;
      }
    }

    return basicFieldsFilled;
  }

  // Helper method to check if sweat image selection is required and completed
  bool _isSweatImageSelectionValid() {
    if (_selectedDeviceId == null) return true; // No device selected yet

    final deviceViewModel = Provider.of<DeviceViewModel>(
      context,
      listen: false,
    );
    final selectedDevice = deviceViewModel.devices.firstWhere(
      (device) => device.id == _selectedDeviceId,
      orElse: () => DeviceModel(id: 0, deviceName: '', deviceText: ''),
    );

    // For pro devices, sweat image selection is mandatory
    if (selectedDevice.deviceName.toLowerCase().contains('pro')) {
      return imageId != null && imageId != 0;
    }

    return true; // Not a pro device, no sweat image required
  }

  // Navigate to device selection screen
  Future<void> _showDeviceSelection() async {
    final deviceViewModel = Provider.of<DeviceViewModel>(
      context,
      listen: false,
    );

    if (deviceViewModel.devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No devices available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceSelectionScreen(
          devices: deviceViewModel.devices,
          selectedDeviceId: _selectedDeviceId,
          onDeviceSelected: (selectedId) async {
            setState(() {
              _selectedDeviceId = selectedId;
              imageId = 0; // Reset imageId when device changes
            });

            // Check if the selected device is pro/pro plus
            final selectedDevice = deviceViewModel.devices.firstWhere(
              (device) => device.id == selectedId,
              orElse: () => DeviceModel(id: 0, deviceName: '', deviceText: ''),
            );

            if (selectedDevice.deviceName.toLowerCase().contains('pro')) {
              // Fetch sweat images for pro devices
              await _fetchSweatImages();
              // Show selection dialog after images are loaded
              if (_sweatImages.isNotEmpty) {
                await _showSweatImageSelection();
              }
            }
          },
        ),
      ),
    );
  }

  // Navigate to sweat image selection screen
  Future<void> _showSweatImageSelection() async {
    if (_sweatImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No sweat images available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SweatImageSelectionScreen(
          sweatImages: _sweatImages,
          selectedImageId: imageId,
          onImageSelected: (selectedId) {
            setState(() {
              imageId = selectedId;
            });
          },
        ),
      ),
    );
  }

  // Fetch sweat images for pro/pro plus devices
  Future<void> _fetchSweatImages() async {
    try {
      setState(() {
        _isLoadingSweatImages = true;
        _sweatImagesError = null;
      });

      // Get user details for API call
      final userDetails = await UserService.getUserDetails();
      if (userDetails == null) {
        throw Exception('User details not found');
      }

      final sweatImages = await SweatImagesService.getSweatImages(
        cnumber: userDetails['cnumber'] ?? '1234567890',
        username: userDetails['username'] ?? 'John Doe',
      );

      setState(() {
        _sweatImages = sweatImages;
        _isLoadingSweatImages = false;
      });
    } catch (e) {
      setState(() {
        _sweatImagesError = e.toString();
        _isLoadingSweatImages = false;
      });
      print('Error fetching sweat images: $e');
    }
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

    // Image upload is now optional - no validation required

    // Check if sweat image selection is required and completed
    if (!_isSweatImageSelectionValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a sweat level for Pro devices'),
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

      // Handle image upload (optional)
      String fullImagePath = '';
      Map<String, dynamic>? uploadResponse;

      if (_selectedImage != null) {
        print('Starting image upload...');
        uploadResponse = await ImageUploadService.uploadImage(_selectedImage!);

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

        // Construct the full image path using base URL and uploaded filepath
        fullImagePath =
            '${ApiConfig.baseUrl.replaceAll(':8500', ':8500')}/assets/innovo/${uploadResponse['response']['filename']}';
        print('Full image path for hydration API: $fullImagePath');
      } else {
        print('No image selected - proceeding without image upload');
        fullImagePath = ''; // Empty image path
      }

      // Now call the hydration API with the image path (empty if no image)
      print('Calling hydration API...');

      // Call hydration API
      final hydrationResponse = await HydrationService.submitHydrationData(
        deviceType:
            _selectedDeviceId ?? 1, // Use selected device ID or default to 1
        height: int.tryParse(_heightController.text) ?? 0,
        sweatPosition: int.tryParse(_sweatPositionController.text) ?? 0,
        timeTaken: int.tryParse(_timeTakenController.text) ?? 0,
        weight: int.tryParse(_weightController.text) ?? 0,
        imageId: imageId ?? 0,
        imagePath: fullImagePath,
      );

      print('Hydration API response received: ${hydrationResponse['code']}');

      // Store the hydration response in the ViewModel
      final hydrationViewModel = Provider.of<HydrationViewModel>(
        context,
        listen: false,
      );
      hydrationViewModel.setHydrationData(hydrationResponse);

      // Store the responses for later use
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
                                      (_areAllFieldsFilled() && !_isSubmitting)
                                      ? _handleSubmit
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        (_areAllFieldsFilled() &&
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
                                            (_areAllFieldsFilled() &&
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
                          const SizedBox(height: 2),
                          // Note about optional image upload
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Upload a picture if you have any',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
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
                                _buildDeviceSelection(),
                                const SizedBox(height: 20),
                                _buildSweatImageSelection(),
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
                                  'Enter sweat position (1-9)',
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
                'Processing Hydrosense Data...',
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
              // Special validation for sweat position
              if (label.toLowerCase().contains('sweat position')) {
                final sweatValue = int.tryParse(value.trim());
                if (sweatValue != null && sweatValue <= 0) {
                  return 'Sweat position must be greater than 0';
                }
              }
              // Special validation for time taken
              if (label.toLowerCase().contains('time taken')) {
                final timeValue = int.tryParse(value.trim());
                if (timeValue != null && timeValue <= 0) {
                  return 'Time taken must be greater than 0';
                }
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

  Widget _buildDeviceSelection() {
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
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedDeviceId != null
                  ? Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Selected: ${deviceViewModel.devices.firstWhere(
                              (device) => device.id == _selectedDeviceId,
                              orElse: () => DeviceModel(id: 0, deviceName: '', deviceText: ''),
                            ).deviceName}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: _showDeviceSelection,
                          child: const Text(
                            'Change',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _showDeviceSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Select Device Type'),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSweatImageSelection() {
    // Only show for pro devices
    if (_selectedDeviceId == null) return const SizedBox.shrink();

    final deviceViewModel = Provider.of<DeviceViewModel>(
      context,
      listen: false,
    );
    final selectedDevice = deviceViewModel.devices.firstWhere(
      (device) => device.id == _selectedDeviceId,
      orElse: () => DeviceModel(id: 0, deviceName: '', deviceText: ''),
    );

    if (!selectedDevice.deviceName.toLowerCase().contains('pro')) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Sweat Level Selection',
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
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _isSweatImageSelectionValid() ? Colors.white : Colors.red,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _isLoadingSweatImages
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : _sweatImagesError != null
              ? Column(
                  children: [
                    Text(
                      'Error: $_sweatImagesError',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _fetchSweatImages,
                      child: const Text('Retry'),
                    ),
                  ],
                )
              : imageId != null && imageId != 0
              ? Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Selected: ${_sweatImages.firstWhere(
                          (img) => img.id == imageId,
                          orElse: () => SweatImageModel(id: 0, imagePath: '', sweatRange: '', implications: '', recomm: '', strategy: '', result: 'Unknown', colorcode: ''),
                        ).result}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: _showSweatImageSelection,
                      child: const Text(
                        'Change',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    ElevatedButton(
                      onPressed: _showSweatImageSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Select Sweat Level *'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sweat level selection is mandatory for Pro devices',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
