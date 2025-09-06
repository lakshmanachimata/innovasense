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
  static const String authToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjX251bWJlciI6IjEyMzQ1Njc4OTAiLCJ1c2VybmFtZSI6IkpvaG4gRG9lIiwiZXhwIjoxNzU5NzQ3MDc3LCJuYmYiOjE3NTcxNTUwNzcsImlhdCI6MTc1NzE1NTA3N30.bw9LCLHkdN7OGh5Wwb-leQldkdR3B0MleItrTgKrUDs';
}
