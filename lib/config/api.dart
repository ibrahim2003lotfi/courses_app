class ApiConfig {
  // Use your computer's IP address for all connections
  static const String baseUrl = "http://192.168.1.4:8000/api";

  // Helper to get the base URL without /api for OAuth/other endpoints if needed
  static String get baseUrlNoApi {
    return baseUrl.replaceAll('/api', '');
  }
}
