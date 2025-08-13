class ImageConfig {
  // Configure your image URLs here

  static const String localUrl = 'http://54.67.86.186:8500/assets/banners';

  // Option 1: Use placeholder images for testing (since local banners were deleted)
  static const String placeholderUrl = 'https://picsum.photos/800/400';

  // Option 2: Use a CDN service (recommended for production)
  static const String cdnUrl = 'https://your-cdn.com/banners';

  // Option 3: Use cloud storage (AWS S3, Google Cloud Storage, etc.)
  static const String cloudStorageUrl =
      'https://your-bucket.s3.amazonaws.com/banners';

  // Current active URL - change this to switch between options
  static String get activeImageUrl => placeholderUrl;

  // Banner image URL builder
  static String getBannerUrl(String filename) {
    return '$activeImageUrl?random=${filename.hashCode}';
  }

  // Banner image URL builder
  static String localBannerUrl(String filename) {
    return '$localUrl/$filename';
  }

  // Full image URL builder
  static String getImageUrl(String assetPath) {
    if (assetPath.startsWith('http://') || assetPath.startsWith('https://')) {
      return assetPath;
    }

    // Extract filename from asset path and create a unique placeholder
    String filename = assetPath.split('/').last;
    return localBannerUrl(filename);
  }
}
