/// Application-wide constants
class AppConstants {
  // Database configuration
  static const String databaseName = 'boitodex.db';
  static const int databaseVersion = 1;

  // Image processing settings
  static const int maxImageWidth = 1200;
  static const int maxImageHeight = 1200;
  static const int imageQuality = 85;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB

  // UI configuration
  static const int itemsPerPage = 20;

  // Export settings
  static const String exportFileName = 'boitodex_export';
}