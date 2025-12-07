/// Application-wide constants
/// 
/// This file contains all hardcoded values used throughout the app
/// to ensure consistency and easy maintenance.
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // ==================== Timeouts ====================
  static const Duration firebaseInitTimeout = Duration(seconds: 10);
  static const Duration firestoreQueryTimeout = Duration(seconds: 5);
  static const Duration streamTimeout = Duration(seconds: 5);
  static const Duration contactFormTimeout = Duration(seconds: 5);
  static const Duration analyticsBatchDelay = Duration(seconds: 5);

  // ==================== UI Dimensions ====================
  // Video heights
  static const double mobileVideoHeight = 200.0;
  static const double tabletVideoHeight = 260.0;
  static const double desktopVideoHeight = 300.0;
  static const double minVideoHeight = 150.0;
  static const double maxVideoHeight = 400.0;

  // Card dimensions
  static const double cardBorderRadius = 20.0;
  static const double cardElevation = 8.0;
  static const double cardHoverElevation = 20.0;
  static const double cardScaleOnHover = 1.02;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Padding
  static const double paddingXS = 8.0;
  static const double paddingSM = 12.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  // ==================== Pagination ====================
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
  static const int activitiesLimit = 10;
  static const int projectsLimit = 20;

  // ==================== Cache ====================
  static const Duration defaultCacheTTL = Duration(hours: 1);
  static const Duration shortCacheTTL = Duration(minutes: 5);
  static const Duration longCacheTTL = Duration(days: 1);

  // ==================== Rate Limiting ====================
  static const Duration contactFormCooldown = Duration(minutes: 5);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // ==================== Animation Durations ====================
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 600);
  static const Duration pageTransition = Duration(milliseconds: 800);

  // ==================== Validation ====================
  static const int minNameLength = 2;
  static const int minMessageLength = 10;
  static const int maxNameLength = 100;
  static const int maxEmailLength = 255;
  static const int maxMessageLength = 2000;
  static const int maxSubjectLength = 200;

  // ==================== Responsive Breakpoints ====================
  static const double mobileBreakpoint = 480.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;
  static const double largeDesktopBreakpoint = 1440.0;

  // ==================== Firebase Settings ====================
  static const int firestoreCacheSizeMB = 100; // 100MB cache
  static const bool enableOfflinePersistence = true;
}

