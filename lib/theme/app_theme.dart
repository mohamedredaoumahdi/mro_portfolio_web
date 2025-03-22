import 'package:flutter/material.dart';
import 'package:portfolio_website/config/app_config.dart';

class AppTheme {
  static ThemeData get theme {
    // Get theme configurations from AppConfig
    final config = AppConfig.themeConfig;
    
    // Use dark theme or light theme based on configuration
    final brightness = config.useDarkMode ? Brightness.dark : Brightness.light;
    
    // Create color scheme from config colors
    final colorScheme = ColorScheme(
      primary: Color(config.primaryColor),
      secondary: Color(config.accentColor),
      surface: Color(config.backgroundColor),
      background: Color(config.backgroundColor),
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(config.textPrimaryColor),
      onBackground: Color(config.textPrimaryColor),
      onError: Colors.white,
      brightness: brightness,
    );

    // Create text theme
    final textTheme = TextTheme(
      displayLarge: TextStyle(
        color: Color(config.textPrimaryColor),
        fontSize: 57,
        fontWeight: FontWeight.bold,
        fontFamily: 'JetBrainsMono',
      ),
      displayMedium: TextStyle(
        color: Color(config.textPrimaryColor),
        fontSize: 45,
        fontWeight: FontWeight.bold,
        fontFamily: 'JetBrainsMono',
      ),
      displaySmall: TextStyle(
        color: Color(config.textPrimaryColor),
        fontSize: 36,
        fontWeight: FontWeight.bold,
        fontFamily: 'JetBrainsMono',
      ),
      headlineLarge: TextStyle(
        color: Color(config.textPrimaryColor),
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'JetBrainsMono',
      ),
      headlineMedium: TextStyle(
        color: Color(config.textPrimaryColor),
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: 'JetBrainsMono',
      ),
      headlineSmall: TextStyle(
        color: Color(config.textPrimaryColor),
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'JetBrainsMono',
      ),
      titleLarge: TextStyle(
        color: Color(config.textPrimaryColor),
        fontSize: 22,
        fontWeight: FontWeight.w600,
        fontFamily: 'JetBrainsMono',
      ),
      titleMedium: TextStyle(
        color: Color(config.textPrimaryColor),
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'JetBrainsMono',
      ),
      titleSmall: TextStyle(
        color: Color(config.textPrimaryColor),
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'JetBrainsMono',
      ),
      bodyLarge: TextStyle(
        color: Color(config.textPrimaryColor),
        fontSize: 16,
        fontFamily: 'Roboto',
      ),
      bodyMedium: TextStyle(
        color: Color(config.textPrimaryColor),
        fontSize: 14,
        fontFamily: 'Roboto',
      ),
      bodySmall: TextStyle(
        color: Color(config.textSecondaryColor),
        fontSize: 12,
        fontFamily: 'Roboto',
      ),
    );

    // Create and return theme data
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Color(config.backgroundColor),
        foregroundColor: Color(config.textPrimaryColor),
        elevation: 0,
      ),
      scaffoldBackgroundColor: Color(config.backgroundColor),
      cardTheme: CardTheme(
        color: Color(config.backgroundColor).withOpacity(0.7),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Color(config.primaryColor),
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(config.primaryColor),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: Color(config.primaryColor),
        size: 24,
      ),
      dividerTheme: DividerThemeData(
        color: Color(config.textSecondaryColor).withOpacity(0.2),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(config.backgroundColor).withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(config.primaryColor)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(config.primaryColor).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(config.primaryColor)),
        ),
        labelStyle: TextStyle(color: Color(config.textSecondaryColor)),
        hintStyle: TextStyle(color: Color(config.textSecondaryColor).withOpacity(0.5)),
      ),
    );
  }

  // Developer-focused custom gradient backgrounds
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [
      Color(AppConfig.themeConfig.primaryColor),
      Color(AppConfig.themeConfig.accentColor),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get darkGradient => LinearGradient(
    colors: [
      Color(AppConfig.themeConfig.backgroundColor),
      Color(AppConfig.themeConfig.backgroundColor).withOpacity(0.8),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Code syntax highlighting colors (for code snippets if needed)
  static const Map<String, Color> syntaxHighlightColors = {
    'keyword': Color(0xFF569CD6),   // blue
    'string': Color(0xFFCE9178),    // orange-brown
    'comment': Color(0xFF6A9955),   // green
    'class': Color(0xFF4EC9B0),     // teal
    'number': Color(0xFFB5CEA8),    // light green
    'variable': Color(0xFF9CDCFE),  // light blue
    'method': Color(0xFFDCDCAA),    // light yellow
  };
}