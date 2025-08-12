import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/image_url_service.dart';
import '../viewmodels/banner_viewmodel.dart';
import 'home_screen.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final PageController _pageController = PageController();
  Timer? _autoPlayTimer;
  bool _autoPlayStarted = false;

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
    _autoPlayTimer?.cancel();
    super.dispose();
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
            child: Column(
              children: [
                // Top Section - Banner Slider
                Expanded(
                  flex: 1,
                  child: Consumer<BannerViewModel>(
                    builder: (context, bannerViewModel, child) {
                      if (bannerViewModel.isLoading) {
                        return Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
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
                            height: 200,
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
                                    child: _buildBannerImage(banner.imagePath),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 20),
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
                                      bannerViewModel.currentIndex == entry.key
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
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Welcome Message
                        const Text(
                          'Welcome',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'to Hydrosense.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Login Instruction
                        const Text(
                          'Simply Login with your CNumber',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        //CNumber Input
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white, width: 1),
                            ),
                          ),
                          child: const TextField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'CNumber',
                              hintStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // OTP Input
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white, width: 1),
                            ),
                          ),
                          child: const TextField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Enter Password',
                              hintStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Account Options
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Dont have an account?",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  // Handle create account
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
                        const Spacer(),
                        // Navigation Button
                        Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
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
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
