import 'dart:async';

import 'package:FitApp/views/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/banner_model.dart';
import '../services/image_url_service.dart';
import '../services/user_service.dart';
import '../viewmodels/banner_viewmodel.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  Timer? _autoPlayTimer;
  bool _autoPlayStarted = false;

  @override
  void initState() {
    super.initState();
    // Fetch banner images only if user is not logged in
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isLoggedIn = await UserService.isLoggedIn();
      
      if (!isLoggedIn) {
        print('User not logged in, fetching banner images');
        final bannerViewModel = context.read<BannerViewModel>();
        bannerViewModel.fetchBannerImages();
        
        // Listen to banner changes
        bannerViewModel.addListener(() {
          if (bannerViewModel.hasBanners && !_autoPlayStarted) {
            print('BannerViewModel changed, resetting auto-play');
            _resetAutoPlay();
            _startAutoPlay(bannerViewModel);
          }
        });
      } else {
        print('User is logged in, skipping banner fetch');
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay(BannerViewModel bannerViewModel) {
    // Only start auto-play once
    if (_autoPlayStarted) return;
    
    _autoPlayTimer?.cancel();
    if (bannerViewModel.banners.length > 1) {
      _autoPlayStarted = true;
      _autoPlayTimer = Timer.periodic(Duration(seconds: 3), (timer) {
        // Check if PageController is still attached and mounted
        if (!mounted || !_pageController.hasClients) {
          print('PageController not attached, stopping auto-play');
          _resetAutoPlay();
          return;
        }
        
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
    _autoPlayTimer = null;
    print('Auto-play reset');
  }
  
  void _handleBannerRefresh(BannerViewModel bannerViewModel) {
    print('Handling banner refresh, resetting auto-play');
    _resetAutoPlay();
    if (bannerViewModel.hasBanners) {
      _startAutoPlay(bannerViewModel);
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
          // Banner Slider Background
          Selector<BannerViewModel, List<BannerModel>>(
            selector: (context, bannerViewModel) => bannerViewModel.banners,
            builder: (context, List<BannerModel> banners, child) {
              final bannerViewModel = context.read<BannerViewModel>();
              
              // Only rebuild when banners list changes
              final bannerCount = banners.length;
              final bannerPaths = banners.map((b) => b.imagePath).toList();
              
              print('Selector rebuild - Banner count: $bannerCount, Paths: $bannerPaths');
              
              // Show default background if no banners (user logged in or no banners available)
              if (bannerViewModel.isLoading) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/intro_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
              
              if (bannerViewModel.error != null) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/intro_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
              
              if (bannerViewModel.banners.isEmpty) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/intro_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }

              // Start auto-play when banners are loaded
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (bannerViewModel.hasBanners && !_autoPlayStarted) {
                  _startAutoPlay(bannerViewModel);
                }
              });
              

              
              return PageView.builder(
                key: ValueKey('banner_pageview_${banners.length}_${bannerViewModel.instanceId}'),
                controller: _pageController,
                onPageChanged: (index) {
                  bannerViewModel.setCurrentIndex(index);
                },
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  print('Building PageView item $index: ${banner.imagePath}');
                  print('Total banners in PageView: ${banners.length}');
                  print('All banner paths: ${banners.map((b) => b.imagePath).toList()}');
                  
                  return Container(
                    key: ValueKey('banner_item_${banner.id}_${banner.imagePath}'),
                    width: double.infinity,
                    height: double.infinity,
                    child: _buildBannerImage(banner.imagePath),
                  );
                },
              );
            },
          ),
          // Loading overlay when banners are loading (only for non-logged in users)
          Consumer<BannerViewModel>(
            builder: (context, bannerViewModel, child) {
              if (bannerViewModel.isLoading) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Loading banners...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
          // Dark overlay with wave design
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Banner pagination indicators at the top (only show when banners are available)
                Consumer<BannerViewModel>(
                  builder: (context, bannerViewModel, child) {
                    if (bannerViewModel.banners.isEmpty) return SizedBox.shrink();
                    
                    return Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          SizedBox(height: 8),
                          // Pagination dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: bannerViewModel.banners.asMap().entries.map(
                              (entry) {
                                return Container(
                                  width: 8,
                                  height: 8,
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: bannerViewModel.currentIndex == entry.key
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Spacer(),
                // Main text content (keeping existing test content)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Headline
                      const Text(
                        "Don't Just Sweat.\nHydrate.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Body text
                      const Text(
                        "Dehydration is the silent killer of\nperformance. Fight fatigue, boost\nyour strength, and protect your\nhealth by keeping your body\nfueled with the water it needs to\nsucceed.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Skip button (keeping existing test content)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WelcomeScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.black,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
