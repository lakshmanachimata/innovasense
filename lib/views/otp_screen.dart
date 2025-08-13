import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/image_url_service.dart';
import '../services/login_service.dart';
import '../viewmodels/banner_viewmodel.dart';
import 'account_setup_screen.dart';
import 'home_screen.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _cnumberController = TextEditingController();
  final TextEditingController _userpinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Timer? _autoPlayTimer;
  bool _autoPlayStarted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch banner images when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bannerViewModel = context.read<BannerViewModel>();
      bannerViewModel.fetchBannerImages();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cnumberController.dispose();
    _userpinController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await LoginService.login(
        _cnumberController.text.trim(),
        _userpinController.text,
      );

      print('Login response: $response');

      if (response['code'] == 0) {
        // Login successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to home screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        // Login failed
        final errorMessage = response['message'] ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Login error: $e');
      String errorMessage = 'Login failed';

      if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please check your connection.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage =
            'Connection failed. Please check your internet connection.';
      } else if (e.toString().contains('Invalid credentials')) {
        errorMessage = 'Invalid CNumber or UserPin. Please try again.';
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

  void _startAutoPlay(BannerViewModel bannerViewModel) {
    // Only start auto-play once
    if (_autoPlayStarted) return;

    _autoPlayTimer?.cancel();
    if (bannerViewModel.banners.length > 1) {
      _autoPlayStarted = true;
      _autoPlayTimer = Timer.periodic(Duration(seconds: 3), (timer) {
        if (bannerViewModel.currentIndex < bannerViewModel.banners.length - 1) {
          _pageController.animateToPage(
            bannerViewModel.currentIndex + 1,
            duration: Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
          );
        }
      });
      print('Auto-play started with ${bannerViewModel.banners.length} banners');
    }
  }

  Widget _buildBannerImage(String imagePath) {
    // Convert asset path to remote URL if needed
    String finalImagePath = ImageUrlService.getBannerUrl(imagePath);

    return Image.network(
      finalImagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[800],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $finalImagePath - $error');
        return Container(
          color: Colors.grey[800],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, color: Colors.white, size: 50),
                SizedBox(height: 8),
                Text(
                  'Image not found',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              child: Column(
                children: [
                  // Top Section - Banner Slider
                  Container(
                    height: 200,
                    child: Consumer<BannerViewModel>(
                      builder: (context, bannerViewModel, child) {
                        if (bannerViewModel.isLoading) {
                          return Container(
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Loading banners...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (bannerViewModel.error != null) {
                          return Container(
                            height: 200,
                            child: Center(
                              child: Text(
                                'Failed to load banners',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }

                        if (bannerViewModel.banners.isEmpty) {
                          return Container(
                            height: 200,
                            child: Center(
                              child: Text(
                                'No banners available',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }

                        // Filter to only numbered images (non-banner)
                        final numberedBanners = bannerViewModel.allBanners.where((
                          banner,
                        ) {
                          final filename = banner.imagePath.split('/').last;
                          // Check if filename contains only numbers (1.jpg, 2.jpg, etc.)
                          return RegExp(
                            r'^\d+\.(jpg|png|jpeg)$',
                          ).hasMatch(filename);
                        }).toList();

                        if (numberedBanners.isEmpty) {
                          return Container(
                            height: 200,
                            child: Center(
                              child: Text(
                                'No numbered images found',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }

                        // Start auto-play when banners are loaded
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (numberedBanners.length > 1 && !_autoPlayStarted) {
                            _startAutoPlay(bannerViewModel);
                          }
                        });

                        return Column(
                          children: [
                            // Banner Slider
                            Container(
                              height: 180,
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  bannerViewModel.setCurrentIndex(index);
                                },
                                itemCount: numberedBanners.length,
                                itemBuilder: (context, index) {
                                  final banner = numberedBanners[index];
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: _buildBannerImage(
                                        banner.imagePath,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            // Banner pagination indicators
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: numberedBanners.asMap().entries.map((
                                entry,
                              ) {
                                return Container(
                                  width: 8,
                                  height: 8,
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        bannerViewModel.currentIndex ==
                                            entry.key
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Bottom Section - OTP Content
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 16),
                              // Welcome Message
                              const Text(
                                'Welcome',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'to Hydrosense.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Login Instruction
                              const Text(
                                'Simply Login with your CNumber and UserPin',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              //CNumber Input
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _cnumberController,
                                  enabled: !_isLoading,
                                  style: TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'CNumber is required';
                                    }
                                    if (value.trim().length < 10) {
                                      return 'CNumber must be at least 10 digits';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'CNumber',
                                    hintStyle: TextStyle(color: Colors.white),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    errorStyle: TextStyle(
                                      color: Colors.red[300],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // UserPin Input
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _userpinController,
                                  enabled: !_isLoading,
                                  obscureText: true,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'UserPin is required';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter UserPin',
                                    hintStyle: TextStyle(color: Colors.white),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    errorStyle: TextStyle(
                                      color: Colors.red[300],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.black),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Logging in...',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Account Options
                              Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Don't have an account?",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AccountSetupScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                      child: const Text(
                                        'Create account!',
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
                              ),
                              const SizedBox(height: 20),
                              // Navigation Button
                              Align(
                                alignment: Alignment.bottomRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
