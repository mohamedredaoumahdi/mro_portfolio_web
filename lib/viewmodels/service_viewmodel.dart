// lib/viewmodels/service_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:portfolio_website/services/firebase_service.dart';
import '../models/project_model.dart';
import '../config/app_config.dart';

// Import Firebase service conditionally
import 'package:firebase_core/firebase_core.dart';

class ServiceViewModel extends ChangeNotifier {
  List<Service> _services = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor
  ServiceViewModel() {
    loadServices();
  }

  // Check if Firebase is available
  bool get _isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Load services either from Firebase or local config
  Future<void> loadServices() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate network delay in debug mode
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Use Firebase if available
      if (_isFirebaseAvailable) {
        try {
          // Try to load from Firebase with a timeout
          _services = await await FirebaseService.instance.getServices().timeout(const Duration(seconds: 5));
        } catch (e) {
          print('Error loading from Firebase: $e - Falling back to local config');
          // Firebase timed out or had an error - fall back to local config
          _services = [];
        }
      }
      
      // If no services loaded from Firebase, use fallback from config
      if (_services.isEmpty) {
        final servicesList = AppConfig.services;
        _services = List.generate(
          servicesList.length,
          (index) => Service.fromConfig(index, servicesList[index]),
        );
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load services: ${e.toString()}';
      notifyListeners();
    }
  }
}