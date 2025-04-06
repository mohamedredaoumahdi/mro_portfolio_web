// lib/viewmodels/service_viewmodel.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import '../config/app_config.dart';

class ServiceViewModel extends ChangeNotifier {
  List<Service> _services = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _subscription;

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
      print('Firebase availability check error: $e');
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
    
    // Set up listener
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
  
  @override
  void dispose() {
    // Cancel subscription when viewmodel is disposed
    _subscription?.cancel();
    super.dispose();
  }
}