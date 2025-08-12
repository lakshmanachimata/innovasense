class ImageConfig {
  // Configure your image URLs here

  // Option 1: Use your local server (if you have images stored there)
  static const String localServerUrl = 'http://192.168.1.5:8500/assets/banners';

  // Option 2: Use a CDN service (recommended for production)
  static const String cdnUrl = 'https://your-cdn.com/banners';

  // Option 3: Use cloud storage (AWS S3, Google Cloud Storage, etc.)
  static const String cloudStorageUrl =
      'https://your-bucket.s3.amazonaws.com/banners';

  // Option 4: Use placeholder images for testing
  static const String placeholderUrl = 'https://picsum.photos/400/200';

  // Current active URL - change this to switch between options
  static String get activeImageUrl => localServerUrl;

  // Banner image URL builder
  static String getBannerUrl(String filename) {
    return '$activeImageUrl/$filename';
  }

  // Full image URL builder
  static String getImageUrl(String assetPath) {
    if (assetPath.startsWith('http://') || assetPath.startsWith('https://')) {
      return assetPath;
    }

    // Extract filename from asset path
    String filename = assetPath.split('/').last;
    return getBannerUrl(filename);
  }
}
