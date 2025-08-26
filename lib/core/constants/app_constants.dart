class AppConstants {
  // Database
  static const String databaseName = 'boitodex.db';
  static const int databaseVersion = 2;

  // Image
  static const int maxImageWidth = 1200;
  static const int maxImageHeight = 1200;
  static const int imageQuality = 85;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB

  // UI
  static const int itemsPerPage = 20;
  static const double cardElevation = 2.0;
  static const double borderRadius = 12.0;

  // Export
  static const String exportFileName = 'boitodex_export';
}