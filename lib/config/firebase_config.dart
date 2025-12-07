import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration using environment variables
/// 
/// ⚠️ SECURITY WARNING: Default values are for development only!
/// In production, ALWAYS use environment variables to avoid exposing credentials.
/// 
/// To use this, pass environment variables when running:
/// flutter run --dart-define=FIREBASE_API_KEY=your_key --dart-define=FIREBASE_AUTH_DOMAIN=your_domain ...
/// 
/// Or create a .env file and use flutter_dotenv package
/// 
/// See FIREBASE_DEPLOYMENT.md for more details.
class FirebaseConfig {
  // Get values from environment variables with fallback to hardcoded (for development only)
  // ⚠️ WARNING: Remove defaults before production deployment!
  static const String apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyDIEiJa91VRseWa3udLSfN0bhAKhezssQc', // TODO: Remove default in production
  );
  
  static const String authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'myportfolio-594b1.firebaseapp.com', // TODO: Remove default in production
  );
  
  static const String projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'myportfolio-594b1', // TODO: Remove default in production
  );
  
  static const String storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'myportfolio-594b1.firebasestorage.app', // TODO: Remove default in production
  );
  
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '115489897719', // TODO: Remove default in production
  );
  
  static const String appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:115489897719:web:4337415f01a45598c027f2', // TODO: Remove default in production
  );
  
  /// Get FirebaseOptions from environment variables
  static FirebaseOptions get options => FirebaseOptions(
    apiKey: apiKey,
    authDomain: authDomain,
    projectId: projectId,
    storageBucket: storageBucket,
    messagingSenderId: messagingSenderId,
    appId: appId,
  );
  
  /// Validate that all required values are present
  static bool get isValid {
    return apiKey.isNotEmpty &&
           authDomain.isNotEmpty &&
           projectId.isNotEmpty &&
           storageBucket.isNotEmpty &&
           messagingSenderId.isNotEmpty &&
           appId.isNotEmpty;
  }
}

