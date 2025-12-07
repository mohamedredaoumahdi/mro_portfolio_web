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
  bool _listenerSetup = false; // Track if listener is already set up

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

  // Load services either from Firebase or local config
  Future<void> loadServices() async {
    if (_isLoading) {
      debugPrint('loadServices already in progress, skipping...');
      return; // Prevent concurrent loads
    }

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
          // Set up real-time listener for services (only if not already set up)
          if (!_listenerSetup) {
            _setupRealTimeListener();
          } else {
            debugPrint('Listener already active, skipping setup');
            _isLoading = false;
            notifyListeners();
          }
          return; // Early return as listener will handle updates
        } catch (e) {
          debugPrint('Error setting up Firestore listener: $e');
          // Don't fall back to AppConfig - show empty list
          _listenerSetup = false;
          _services = []; // Clear services
          _isLoading = false;
          _errorMessage = 'Error connecting to Firestore. Will retry automatically.';
          notifyListeners();
        }
      } else {
        // Firebase not available - show empty list instead of AppConfig
        _listenerSetup = false;
        _services = []; // Clear services - don't use AppConfig
        debugPrint('Firebase not available - showing empty services list');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load services: ${e.toString()}';
      notifyListeners();
      debugPrint('Error in ServiceViewModel: $_errorMessage');
    }
  }

  // Set up real-time listener for services collection
  void _setupRealTimeListener() {
    // Prevent setting up multiple listeners
    if (_listenerSetup && _subscription != null) {
      debugPrint('Listener already set up, skipping...');
      return;
    }
    
    debugPrint('Setting up real-time listener for services...');
    
    // Cancel existing subscription if any
    _subscription?.cancel();
    _subscription = null;
    _listenerSetup = false;
    
    try {
      // Set up listener with error handling
      _subscription = FirebaseFirestore.instance
          .collection('services')
          .orderBy('order')
          .snapshots()
          .listen((snapshot) {
            debugPrint('Real-time update for services: ${snapshot.docs.length} items from Firestore');
            
            // Use a Map to prevent duplicates based on ID, and track seen IDs
            final Map<String, Service> servicesMap = {};
            final Set<String> seenIds = {};
            
            for (var doc in snapshot.docs) {
              final docId = doc.id;
              
              // Skip if we've already seen this ID (duplicate in snapshot)
              if (seenIds.contains(docId)) {
                debugPrint('Warning: Duplicate document ID in snapshot: $docId');
                continue;
              }
              
              seenIds.add(docId);
              
              try {
                final data = doc.data();
                
                // Safely extract and convert all fields to strings
                // Handle null values and type conversions properly
                final title = data['title'];
                final description = data['description'];
                final iconName = data['iconName'];
                
                final service = Service(
                  id: docId,
                  title: title != null ? title.toString() : '',
                  description: description != null ? description.toString() : '',
                  iconPath: iconName != null ? iconName.toString() : '',
                );
                // Use ID as key to prevent duplicates
                servicesMap[docId] = service;
              } catch (e, stackTrace) {
                debugPrint('Error processing service document $docId: $e');
                debugPrint('Stack trace: $stackTrace');
                debugPrint('Document data: ${doc.data()}');
                // Skip this document if it can't be processed
                continue;
              }
            }
            
            // Convert map values to list, maintaining order from snapshot
            final List<Service> updatedServices = snapshot.docs
                .map((doc) => servicesMap[doc.id])
                .where((service) => service != null)
                .cast<Service>()
                .toList();
            
            debugPrint('Processed ${updatedServices.length} unique services from ${snapshot.docs.length} Firestore documents');
            
            // Only update if the list actually changed
            final currentIds = _services.map((s) => s.id).toSet();
            final newIds = updatedServices.map((s) => s.id).toSet();
            
            if (currentIds.length != newIds.length || !currentIds.containsAll(newIds)) {
              _services = updatedServices;
              _isLoading = false;
              _errorMessage = null;
              _listenerSetup = true;
              notifyListeners();
            } else {
              debugPrint('Services list unchanged, skipping notifyListeners');
            }
          }, onError: (e) {
            debugPrint('Error in real-time listener: $e');
            
            // Set user-friendly error message
            if (e.toString().contains('permission-denied')) {
              _errorMessage = 'Permission denied. Please check your authentication.';
            } else if (e.toString().contains('unavailable') || e.toString().contains('unavailable')) {
              _errorMessage = 'Service temporarily unavailable. Showing cached data.';
            } else {
              _errorMessage = 'Connection error. Showing offline data.';
            }
            
            // Don't fall back to AppConfig - Firestore offline persistence will handle cached data
            // If Firestore is empty, show empty list (don't use AppConfig fallback)
            if (_services.isEmpty) {
              debugPrint('No services in Firestore - showing empty list (not using AppConfig fallback)');
            } else {
              debugPrint('Keeping existing ${_services.length} services from Firestore cache/offline mode');
            }
            
            _isLoading = false;
            notifyListeners();
          });
      
      // Set timeout for initial data fetch - don't fall back to AppConfig
      Timer(const Duration(seconds: 5), () {
        if (_isLoading) {
          debugPrint('Firebase services data fetch timed out - showing empty list');
          _services = []; // Clear services - don't use AppConfig
          _isLoading = false;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Exception setting up services listener: $e');
      _errorMessage = 'Error setting up services listener: $e';
      _services = []; // Clear services - don't use AppConfig
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load data from AppConfig as fallback (DEPRECATED - not used)
  // Services should only come from Firestore
  @Deprecated('Services should only come from Firestore, not AppConfig')
  void _loadFromAppConfig() {
    debugPrint('Loading services from AppConfig fallback (DEPRECATED - should not be called)');
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
    _subscription = null;
    _listenerSetup = false;
    super.dispose();
  }
}