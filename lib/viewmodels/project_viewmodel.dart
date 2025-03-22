// lib/viewmodels/project_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:portfolio_website/services/firebase_service.dart';
import '../models/project_model.dart';
import '../config/app_config.dart';

// Import Firebase service conditionally
import 'package:firebase_core/firebase_core.dart';

class ProjectViewModel extends ChangeNotifier {
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor
  ProjectViewModel() {
    loadProjects();
  }

  // Check if Firebase is available
  bool get _isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Load projects either from Firebase or local config
  Future<void> loadProjects() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate network delay in debug mode
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 800));
      }

      // Use Firebase if available
      if (_isFirebaseAvailable) {
        try {
          // Try to load from Firebase with a timeout
          _projects = await FirebaseService.instance.getProjects().timeout(const Duration(seconds: 5));
        } catch (e) {
          print('Error loading from Firebase: $e - Falling back to local config');
          // Firebase timed out or had an error - fall back to local config
          _projects = [];
        }
      }
      
      // If no projects loaded from Firebase, use fallback from config
      if (_projects.isEmpty) {
        final projectsList = AppConfig.projects;
        _projects = List.generate(
          projectsList.length,
          (index) => Project.fromConfig(index, projectsList[index]),
        );
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load projects: ${e.toString()}';
      notifyListeners();
    }
  }

  // Select a project
  void selectProject(Project project) {
    _selectedProject = project;
    notifyListeners();
  }

  // Clear selected project
  void clearSelectedProject() {
    _selectedProject = null;
    notifyListeners();
  }

  // Filter projects by technology
  List<Project> filterByTechnology(String technology) {
    return _projects.where((project) => 
      project.technologies.contains(technology)
    ).toList();
  }
}