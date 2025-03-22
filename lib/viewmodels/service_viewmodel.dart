import 'package:flutter/foundation.dart';
import 'package:portfolio_website/config/app_config.dart';
import '../models/project_model.dart';

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

  // Load services from app config
  Future<void> loadServices() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate network delay (remove in production)
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Load service data from config
      final servicesList = AppConfig.services;
      _services = List.generate(
        servicesList.length,
        (index) => Service.fromConfig(index, servicesList[index]),
      );

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