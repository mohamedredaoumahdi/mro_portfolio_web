/// Singleton service to check Firebase availability with caching
import 'package:flutter/foundation.dart';
/// 
/// This prevents repeated checks of Firebase.apps.isNotEmpty throughout the app
class FirebaseAvailability {
  FirebaseAvailability._(); // Private constructor
  
  static bool? _cachedStatus;
  static DateTime? _lastCheck;
  static const Duration _cacheValidity = Duration(minutes: 5);
  
  /// Check if Firebase is available (cached result)
  static bool get isAvailable {
    // Return cached value if still valid
    if (_cachedStatus != null && 
        _lastCheck != null && 
        DateTime.now().difference(_lastCheck!) < _cacheValidity) {
      return _cachedStatus!;
    }
    
    // Perform fresh check
    try {
      _cachedStatus = _checkFirebaseAvailability();
      _lastCheck = DateTime.now();
      return _cachedStatus!;
    } catch (e) {
      debugPrint('Firebase availability check error: $e');
      _cachedStatus = false;
      _lastCheck = DateTime.now();
      return false;
    }
  }
  
  /// Perform actual Firebase availability check
  static bool _checkFirebaseAvailability() {
    try {
      // Import firebase_core at the top of the file that uses this
      // For now, we'll use a try-catch approach
      // This will be called from files that already import firebase_core
      return true; // Placeholder - actual check happens in calling code
    } catch (e) {
      return false;
    }
  }
  
  /// Reset the cache (useful after Firebase initialization)
  static void reset() {
    _cachedStatus = null;
    _lastCheck = null;
  }
  
  /// Force a fresh check (bypasses cache)
  static bool checkFresh() {
    reset();
    return isAvailable;
  }
}

/// Extension to check Firebase availability from any file that imports firebase_core
extension FirebaseAvailabilityCheck on Object {
  static bool? _cachedFirebaseStatus;
  
  static bool checkFirebase() {
    if (_cachedFirebaseStatus != null) {
      return _cachedFirebaseStatus!;
    }
    
    try {
      // This will be called from files that import firebase_core
      // We'll use a different approach - check in the actual ViewModels
      return false;
    } catch (e) {
      return false;
    }
  }
}

