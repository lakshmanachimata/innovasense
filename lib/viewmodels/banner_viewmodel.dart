import 'package:flutter/material.dart';

import '../models/banner_model.dart';
import '../services/banner_service.dart';

class BannerViewModel extends ChangeNotifier {
  final BannerService _bannerService = BannerService();
  final String _instanceId = DateTime.now().millisecondsSinceEpoch.toString();

  List<BannerModel> _banners = [];
  bool _isLoading = false;
  String? _error;
  int _currentIndex = 0;

  String get instanceId => _instanceId;

  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentIndex => _currentIndex;

  Future<void> fetchBannerImages() async {
    try {
      print('BannerViewModel [$_instanceId]: Starting to fetch banner images');
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Test the filtering logic first
      testFiltering();

      final response = await _bannerService.getBannerImages();

      // Log all images received from API
      print(
        'BannerViewModel [$_instanceId]: Received ${response.response.length} total images from API:',
      );
      response.response.forEach((banner) {
        print('  - ${banner.imagePath}');
      });

      // Filter to only use images with "banner" in their names
      final allBanners = response.response;
      final filteredBanners = allBanners.where((banner) {
        // Extract filename from path and check if it contains "banner"
        final filename = banner.imagePath.split('/').last;
        final hasBanner = filename.contains('banner');
        print(
          '  Filtering ${banner.imagePath} -> filename: $filename -> ${hasBanner ? "✓ KEEP" : "✗ REMOVE"}',
        );
        return hasBanner;
      }).toList();

      _banners = filteredBanners;

      // Log filtered results
      print(
        'BannerViewModel [$_instanceId]: Filtered to ${_banners.length} banner images:',
      );
      _banners.forEach((banner) {
        print('  ✓ ${banner.imagePath}');
      });

      _isLoading = false;
      notifyListeners();
      print(
        'BannerViewModel [$_instanceId]: Successfully loaded ${_banners.length} banner images from API (filtered)',
      );
    } catch (e) {
      print(
        'BannerViewModel [$_instanceId]: API failed, using fallback banners: $e',
      );
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void setCurrentIndex(int index) {
    print('BannerViewModel [$_instanceId]: Setting current index to $index');
    _currentIndex = index;
    notifyListeners();
  }

  /// Get the count of banner images
  int get bannerCount => _banners.length;

  /// Check if banners are loaded and ready
  bool get hasBanners => _banners.isNotEmpty;

  /// Get debug summary of current state
  String get debugSummary {
    return 'BannerViewModel [$_instanceId]: ${_banners.length} banners, current: $_currentIndex, loading: $_isLoading, error: $_error';
  }

  /// Force refresh banners
  Future<void> forceRefresh() async {
    print('BannerViewModel [$_instanceId]: Force refreshing banners');
    _banners.clear();
    _currentIndex = 0;
    notifyListeners();
    await fetchBannerImages();
  }

  /// Test the filtering logic
  void testFiltering() {
    print('=== Testing Filtering Logic ===');
    final testPaths = [
      'assets/banners/1.jpg',
      'assets/banners/2.jpg',
      'assets/banners/banner1.png',
      'assets/banners/banner2.png',
      'assets/banners/3.jpg',
    ];

    final filtered = testPaths
        .where((path) => path.contains('banner'))
        .toList();
    print('Test paths: $testPaths');
    print('Filtered result: $filtered');
    print('Filtered count: ${filtered.length}');
    print('=== End Test ===');
  }
}
