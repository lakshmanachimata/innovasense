import '../config/image_config.dart';

class ImageUrlService {
  /// Converts a local asset path to a remote URL
  static String getRemoteUrl(String assetPath) {
    return ImageConfig.getImageUrl(assetPath);
  }
  
  /// Converts asset paths like 'assets/banners/banner1.png' to remote URLs
  static String getBannerUrl(String assetPath) {
    return ImageConfig.getImageUrl(assetPath);
  }
  
  /// Check if the path is a remote URL
  static bool isRemoteUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }
  
  /// Get a placeholder image URL for testing
  static String getPlaceholderUrl(int index) {
    return '${ImageConfig.placeholderUrl}?random=$index';
  }
}
