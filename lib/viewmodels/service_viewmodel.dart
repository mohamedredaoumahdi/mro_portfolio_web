// lib/viewmodels/service_viewmodel.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import '../config/app_config.dart';

class ServiceViewModel extends ChangeNotifier {
  List<Service> _services = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _subscription;
  bool _initialized = false;

  // Getters
  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get initialized => _initialized;

  // Constructor - doesn't auto-load data
  ServiceViewModel();

  // Initialize method to be called after widget build
  Future<void> initialize() async {
    if (!_initialized && !_isLoading) {
      await loadServices();
      _initialized = true;
    }
  }

  // Check if Firebase is available
  bool get _isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      print('Firebase availability check error: $e');
      return false;
    }
  }

  // Load services either from Firebase or local config
  Future<void> loadServices() async {
    if (_isLoading) return; // Prevent concurrent loads

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      // Simulate network delay in debug mode
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Use Firebase if available
      if (_isFirebaseAvailable) {
        try {
          // Set up real-time listener for services
          _setupRealTimeListener();
          return; // Early return as listener will handle updates
        } catch (e) {
          print('Error setting up Firestore listener: $e - Falling back to local config');
          // Firebase error - fall back to local config
          _loadFromAppConfig();
        }
      } else {
        // Firebase not available - use local config
        _loadFromAppConfig();
        print('Firebase not available, using AppConfig fallback');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load services: ${e.toString()}';
      notifyListeners();
      print('Error in ServiceViewModel: $_errorMessage');
    }
  }

  // Set up real-time listener for services collection
  void _setupRealTimeListener() {
    print('Setting up real-time listener for services...');
    
    // Cancel existing subscription if any
    _subscription?.cancel();
    
    try {
      // Set up listener with error handling
      _subscription = FirebaseFirestore.instance
          .collection('services')
          .orderBy('order')
          .snapshots()
          .listen((snapshot) {
            print('Real-time update for services: ${snapshot.docs.length} items');
            
            final List<Service> updatedServices = snapshot.docs.map((doc) {
              final data = doc.data();
              return Service(
                id: doc.id,
                title: data['title'] ?? '',
                description: data['description'] ?? '',
                iconPath: data['iconName'] ?? '',
              );
            }).toList();
            
            _services = updatedServices;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          }, onError: (e) {
            print('Error in real-time listener: $e');
            _errorMessage = 'Error loading services: $e';
            _loadFromAppConfig();
            _isLoading = false;
            notifyListeners();
          });
      
      // Set timeout for initial data fetch
      Timer(const Duration(seconds: 5), () {
        if (_isLoading) {
          print('Firebase services data fetch timed out, falling back to AppConfig');
          _loadFromAppConfig();
          _isLoading = false;
          notifyListeners();
        }
      });
    } catch (e) {
      print('Exception setting up services listener: $e');
      _errorMessage = 'Error setting up services listener: $e';
      _loadFromAppConfig();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load data from AppConfig as fallback
  void _loadFromAppConfig() {
    print('Loading services from AppConfig fallback');
    const servicesList = AppConfig.services;
    _services = List.generate(
      servicesList.length,
      (index) => Service.fromConfig(index, servicesList[index]),
    );
  }
  
  // Get service by ID
  Service? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Refresh services - force reload
  Future<void> refreshServices() async {
    _subscription?.cancel();
    _subscription = null;
    _isLoading = false;
    _initialized = false;
    await loadServices();
  }
  
  @override
  void dispose() {
    // Cancel subscription when viewmodel is disposed
    _subscription?.cancel();
    super.dispose();
  }
}