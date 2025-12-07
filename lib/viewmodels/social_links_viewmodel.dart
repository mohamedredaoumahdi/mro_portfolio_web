
// lib/viewmodels/social_links_viewmodel.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';

class SocialLinksViewModel extends ChangeNotifier {
  Map<String, String> _socialLinks = {};
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<DocumentSnapshot>? _subscription;
  bool _hasAttemptedLoad = false;

  // Getters
  Map<String, String> get socialLinks => _socialLinks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasAttemptedLoad => _hasAttemptedLoad;
  
  // Convenience getters for common social links with non-nullable defaults
  String get github => _socialLinks['github'] ?? AppConfig.socialLinks.github;
  String get linkedin => _socialLinks['linkedin'] ?? AppConfig.socialLinks.linkedin;
  String get fiverr => _socialLinks['fiverr'] ?? AppConfig.socialLinks.fiverr;
  String get upwork => _socialLinks['upwork'] ?? AppConfig.socialLinks.upwork;
  String get freelancer => _socialLinks['freelancer'] ?? AppConfig.socialLinks.freelancer;
  String get instagram => _socialLinks['instagram'] ?? AppConfig.socialLinks.instagram;
  String get facebook => _socialLinks['facebook'] ?? AppConfig.socialLinks.facebook;

  // Constructor
  SocialLinksViewModel() {
    // Don't automatically load in constructor - let widget control initialization
    _loadFromAppConfig(); // But initialize with defaults
  }

  // Initialize method to be called after widget build
  Future<void> initialize() async {
    if (!_hasAttemptedLoad && !_isLoading) {
      await loadSocialLinks();
    }
  }

  // Cached Firebase availability check
  static bool? _cachedFirebaseStatus;
  
  bool get _isFirebaseAvailable {
    if (_cachedFirebaseStatus != null) {
      return _cachedFirebaseStatus!;
    }
    
    try {
      _cachedFirebaseStatus = Firebase.apps.isNotEmpty;
      return _cachedFirebaseStatus!;
    } catch (e) {
      debugPrint('Firebase availability check error: $e');
      _cachedFirebaseStatus = false;
      return false;
    }
  }

  // Load social links either from Firebase or local config
  Future<void> loadSocialLinks() async {
    if (_isLoading) return; // Prevent concurrent loads

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _hasAttemptedLoad = true;
      
      // Use Firebase if available
      if (_isFirebaseAvailable) {
        try {
          // Set up real-time listener for social links data
          _setupRealTimeListener();
          return; // Early return as listener will handle updates
        } catch (e) {
          debugPrint('Error setting up Firestore listener: $e - Falling back to local config');
          // Firebase error - fall back to local config
          _loadFromAppConfig();
        }
      } else {
        // Firebase not available - use local config
        _loadFromAppConfig();
        debugPrint('Firebase not available, using AppConfig fallback for social links');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load social links: ${e.toString()}';
      notifyListeners();
      debugPrint('Error in SocialLinksViewModel: $_errorMessage');
    }
  }
  
  // Set up real-time listener for social_links document
  void _setupRealTimeListener() {
    debugPrint('Setting up real-time listener for social links...');
    
    // Cancel existing subscription if any
    _subscription?.cancel();
    
    try {
      // Set up listener with error handling and timeout
      _subscription = FirebaseFirestore.instance
          .collection('config')
          .doc('social_links')
          .snapshots()
          .listen((docSnapshot) {
            if (docSnapshot.exists) {
              final data = docSnapshot.data() as Map<String, dynamic>;
              debugPrint('Real-time update for social links received');
              
              Map<String, String> links = {};
              data.forEach((key, value) {
                // Skip non-link fields like timestamps
                if (key != 'updatedAt' && key != 'createdAt') {
                  links[key] = value.toString();
                }
              });
              
              _socialLinks = links;
              _isLoading = false;
              _errorMessage = null;
              notifyListeners();
            } else {
              debugPrint('social_links document does not exist, falling back to AppConfig');
              _loadFromAppConfig();
              _isLoading = false;
              notifyListeners();
            }
          }, onError: (e) {
            debugPrint('Error in real-time listener: $e');
            _errorMessage = 'Error loading social links: $e';
            _loadFromAppConfig();
            _isLoading = false;
            notifyListeners();
          });
      
      // Set timeout for initial data fetch
      Timer(const Duration(seconds: 5), () {
        if (_isLoading) {
          debugPrint('Firebase social links data fetch timed out, falling back to AppConfig');
          _loadFromAppConfig();
          _isLoading = false;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Exception setting up social links listener: $e');
      _errorMessage = 'Error setting up social links listener: $e';
      _loadFromAppConfig();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load data from AppConfig as fallback
  void _loadFromAppConfig() {
    debugPrint('Loading social links from AppConfig fallback');
    _socialLinks = {
      'github': AppConfig.socialLinks.github,
      'linkedin': AppConfig.socialLinks.linkedin,
      'fiverr': AppConfig.socialLinks.fiverr,
      'upwork': AppConfig.socialLinks.upwork,
      'freelancer': AppConfig.socialLinks.freelancer,
      'instagram': AppConfig.socialLinks.instagram,
      'facebook': AppConfig.socialLinks.facebook,
    };
  }
  
  // Refresh data - force reload
  Future<void> refreshData() async {
    _subscription?.cancel();
    _subscription = null;
    _isLoading = false;
    _hasAttemptedLoad = false;
    await loadSocialLinks();
  }
  
  @override
  void dispose() {
    // Cancel subscription when viewmodel is disposed
    _subscription?.cancel();
    super.dispose();
  }
}