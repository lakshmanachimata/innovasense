import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/image_url_service.dart';
import '../viewmodels/banner_viewmodel.dart';
import '../widgets/webview_popup.dart';
import '../widgets/pdf_viewer_popup.dart';
import 'account_setup_screen.dart';
import 'otp_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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

  void _resetAutoPlay() {
    _autoPlayStarted = false;
    _autoPlayTimer?.cancel();
    print('Auto-play reset');
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
                image: AssetImage('assets/images/login_bg_filter.png'),
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
                          height: 180,
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
                          SizedBox(height: 12),
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
                // Bottom Section - Promotional Content
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Headline
                          const Text(
                            "Don't Just Sweat.\nHydrate.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Body text
                          const Text(
                            "Dehydration is the silent killer of\nperformance. Fight fatigue, boost\nyour strength, and protect your\nhealth by keeping your body\nfueled with the water it needs to\nsucceed.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Login Button
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OTPScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Create Account Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AccountSetupScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.person_add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                                                    // Bottom Navigation Buttons - Row 1: FAQs and Privacy
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // FAQs Button
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const WebViewPopup(
                                      url: 'https://api.innovosens.com/faq.html',
                                      title: 'Frequently Asked Questions',
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble_outline,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'FAQs',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Privacy Button
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const WebViewPopup(
                                      url: 'https://api.innovosens.com/privacy.html',
                                      title: 'Privacy Policy',
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.privacy_tip_outlined,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Privacy',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Bottom Navigation Buttons - Row 2: Terms and Citation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Terms Button
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const WebViewPopup(
                                      url: 'https://api.innovosens.com/terms.html',
                                      title: 'Terms & Conditions',
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.description_outlined,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Terms',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Citation Button
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const PDFViewerPopup(
                                      pdfPath: 'assets/pdf/Hydrosense.pdf',
                                      title: 'Hydrosense Research & Citations',
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.science_outlined,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Citation',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
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
          ),
        ],
      ),
    );
  }
}
