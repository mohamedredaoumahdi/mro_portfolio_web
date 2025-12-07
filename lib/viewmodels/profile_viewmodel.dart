// lib/viewmodels/profile_viewmodel.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/app_config.dart';

class ProfileViewModel extends ChangeNotifier {
  Map<String, dynamic> _personalInfo = {};
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<DocumentSnapshot>? _subscription;
  bool _hasAttemptedLoad = false;

  // Getters
  Map<String, dynamic> get personalInfo => _personalInfo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasAttemptedLoad => _hasAttemptedLoad;
  
  // Convenience getters for common profile fields with non-nullable defaults
  String get name => _personalInfo['name'] ?? AppConfig.name;
  String get title => _personalInfo['title'] ?? AppConfig.title;
  String get email => _personalInfo['email'] ?? AppConfig.email;
  String get phone => _personalInfo['phone'] ?? AppConfig.phone;
  String get location => _personalInfo['location'] ?? AppConfig.location;
  String get aboutMe => _personalInfo['aboutMe'] ?? AppConfig.aboutMe;
  String get initials => _personalInfo['initials'] ?? AppConfig.initials;

  // Constructor
  ProfileViewModel() {
    // Don't automatically load in constructor - let widget control initialization
    _loadFromAppConfig(); // But initialize with defaults
  }

  // Initialize method to be called after widget build
  Future<void> initialize() async {
    if (!_hasAttemptedLoad && !_isLoading) {
      await loadPersonalInfo();
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

  // Load personal info either from Firebase or local config
  Future<void> loadPersonalInfo() async {
    if (_isLoading) return; // Prevent concurrent loads

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _hasAttemptedLoad = true;
      
      // Use Firebase if available
      if (_isFirebaseAvailable) {
        try {
          // Set up real-time listener for profile data
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
        debugPrint('Firebase not available, using AppConfig fallback');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load profile data: ${e.toString()}';
      notifyListeners();
      debugPrint('Error in ProfileViewModel: $_errorMessage');
    }
  }
  
  // Set up real-time listener for personal_info document
  void _setupRealTimeListener() {
    debugPrint('Setting up real-time listener for personal info...');
    
    // Cancel existing subscription if any
    _subscription?.cancel();
    
    try {
      // Set up listener with error handling and timeout
      _subscription = FirebaseFirestore.instance
          .collection('config')
          .doc('personal_info')
          .snapshots()
          .listen((docSnapshot) {
            if (docSnapshot.exists) {
              final data = docSnapshot.data() as Map<String, dynamic>;
              debugPrint('Real-time update for personal info: ${data['title']}');
              
              _personalInfo = data;
              _isLoading = false;
              _errorMessage = null;
              notifyListeners();
            } else {
              debugPrint('personal_info document does not exist, falling back to AppConfig');
              _loadFromAppConfig();
              _isLoading = false;
              notifyListeners();
            }
          }, onError: (e) {
            debugPrint('Error in real-time listener: $e');
            _errorMessage = 'Error loading profile data: $e';
            _loadFromAppConfig();
            _isLoading = false;
            notifyListeners();
          });
      
      // Set timeout for initial data fetch
      Timer(const Duration(seconds: 5), () {
        if (_isLoading) {
          debugPrint('Firebase profile data fetch timed out, falling back to AppConfig');
          _loadFromAppConfig();
          _isLoading = false;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Exception setting up personal info listener: $e');
      _errorMessage = 'Error setting up profile data listener: $e';
      _loadFromAppConfig();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load data from AppConfig as fallback
  void _loadFromAppConfig() {
    debugPrint('Loading profile data from AppConfig fallback');
    _personalInfo = {
      'name': AppConfig.name,
      'title': AppConfig.title,
      'email': AppConfig.email,
      'phone': AppConfig.phone,
      'location': AppConfig.location,
      'aboutMe': AppConfig.aboutMe,
      'initials': AppConfig.initials,
    };
  }
  
  // Refresh data - force reload
  Future<void> refreshData() async {
    _subscription?.cancel();
    _subscription = null;
    _isLoading = false;
    _hasAttemptedLoad = false;
    await loadPersonalInfo();
  }
  
  @override
  void dispose() {
    // Cancel subscription when viewmodel is disposed
    _subscription?.cancel();
    super.dispose();
  }
}