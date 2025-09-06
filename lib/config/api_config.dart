class ApiConfig {
  // Update these URLs based on your setup

  // For Android Emulator (connects to your machine's localhost)
  static const String androidEmulatorUrl = 'http://10.0.2.2:8500';

  // For physical device (use your machine's actual IP address)
  static const String physicalDeviceUrl =
      'http://54.67.86.186:8500'; // Updated to your actual IP

  // For iOS Simulator
  static const String iosSimulatorUrl = 'http://localhost:8500';

  // For web
  static const String webUrl = 'http://localhost:8500';

  // Get the appropriate URL based on platform
  static String get baseUrl {
    // Using localhost for local testing
    return 'http://54.67.86.186:8500';
  }

  // Banner API endpoint
  static String get bannerEndpoint => '$baseUrl/Services/getBannerImages';

  // Auth token for protected endpoints
}
