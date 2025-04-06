import 'package:flutter/material.dart';
import 'package:portfolio_website/config/app_config.dart';

class AppTheme {
  static ThemeData getTheme({bool isDarkMode = true}) {
    // Get theme configurations from AppConfig
    const config = AppConfig.themeConfig;
    
    // Override dark mode setting if needed
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;
    
    // Background and surface colors depend on the mode
    final backgroundColor = isDarkMode 
        ? Color(config.backgroundColor) 
        : Colors.grey[50]!;
    
    final surfaceColor = isDarkMode 
        ? Color(config.backgroundColor) 
        : Colors.white;
    
    // Text colors depend on the mode
    final textPrimaryColor = isDarkMode 
        ? Color(config.textPrimaryColor) 
        : Colors.grey[900]!;
    
    final textSecondaryColor = isDarkMode 
        ? Color(config.textSecondaryColor) 
        : Colors.grey[600]!;

    // Create color scheme from config colors
    final colorScheme = ColorScheme(
      primary: Color(config.primaryColor),
      secondary: Color(config.accentColor),
      surface: surfaceColor,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryColor,
      onError: Colors.white,
      brightness: brightness,
    );

    // Create text theme
    final textTheme = TextTheme(
      displayLarge: TextStyle(
        color: textPrimaryColor,
        fontSize: 57,
        fontWeight: FontWeight.bold,
        fontFamily: 'JetBrainsMono',
      ),
      displayMedium: TextStyle(
        color: textPrimaryColor,
        fontSize: 45,
        fontWeight: FontWeight.bold,
        fontFamily: 'JetBrainsMono',
      ),
      displaySmall: TextStyle(
        color: textPrimaryColor,
        fontSize: 36,
        fontWeight: FontWeight.bold,
        fontFamily: 'JetBrainsMono',
      ),
      headlineLarge: TextStyle(
        color: textPrimaryColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'JetBrainsMono',
      ),
      headlineMedium: TextStyle(
        color: textPrimaryColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: 'JetBrainsMono',
      ),
      headlineSmall: TextStyle(
        color: textPrimaryColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'JetBrainsMono',
      ),
      titleLarge: TextStyle(
        color: textPrimaryColor,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        fontFamily: 'JetBrainsMono',
      ),
      titleMedium: TextStyle(
        color: textPrimaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'JetBrainsMono',
      ),
      titleSmall: TextStyle(
        color: textPrimaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'JetBrainsMono',
      ),
      bodyLarge: TextStyle(
        color: textPrimaryColor,
        fontSize: 16,
        fontFamily: 'Roboto',
      ),
      bodyMedium: TextStyle(
        color: textPrimaryColor,
        fontSize: 14,
        fontFamily: 'Roboto',
      ),
      bodySmall: TextStyle(
        color: textSecondaryColor,
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
        backgroundColor: surfaceColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardTheme(
        color: isDarkMode 
            ? Color(config.backgroundColor).withOpacity(0.7) 
            : Colors.white,
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
        color: textSecondaryColor.withOpacity(0.2),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor.withOpacity(0.3),
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
        labelStyle: TextStyle(color: textSecondaryColor),
        hintStyle: TextStyle(color: textSecondaryColor.withOpacity(0.5)),
      ),
    );
  }

  // For backward compatibility
  static ThemeData get theme => getTheme(isDarkMode: AppConfig.themeConfig.useDarkMode);

  // Background gradients
  static LinearGradient getPrimaryGradient({bool isDarkMode = true}) {
    return LinearGradient(
      colors: [
        Color(AppConfig.themeConfig.primaryColor),
        Color(AppConfig.themeConfig.accentColor),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getBackgroundGradient({bool isDarkMode = true}) {
    final backgroundColor = isDarkMode 
        ? Color(AppConfig.themeConfig.backgroundColor)
        : Colors.grey[50]!;
    
    return LinearGradient(
      colors: [
        backgroundColor,
        backgroundColor.withOpacity(0.8),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  // For backward compatibility
  static LinearGradient get primaryGradient => getPrimaryGradient();
  static LinearGradient get darkGradient => getBackgroundGradient();

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