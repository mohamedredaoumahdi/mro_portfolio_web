// lib/viewmodels/project_viewmodel.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import '../config/app_config.dart';

class ProjectViewModel extends ChangeNotifier {
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _subscription;

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
      print('Firebase availability check error: $e');
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
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Use Firebase if available
      if (_isFirebaseAvailable) {
        try {
          // Set up real-time listener for projects
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
      _errorMessage = 'Failed to load projects: ${e.toString()}';
      notifyListeners();
      print('Error in ProjectViewModel: $_errorMessage');
    }
  }

  // Set up real-time listener for projects collection
  void _setupRealTimeListener() {
    print('Setting up real-time listener for projects...');
    
    // Cancel existing subscription if any
    _subscription?.cancel();
    
    // Set up listener
    _subscription = FirebaseFirestore.instance
        .collection('projects')
        .orderBy('order')
        .snapshots()
        .listen((snapshot) {
          print('Real-time update for projects: ${snapshot.docs.length} items');
          
          final List<Project> updatedProjects = snapshot.docs.map((doc) {
            final data = doc.data();
            return Project(
              id: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              technologies: List<String>.from(data['technologies'] ?? []),
              youtubeVideoId: data['youtubeVideoId'] ?? '',
              thumbnailUrl: data['thumbnailUrl'] ?? '',
              date: data['createdAt'] != null 
                  ? (data['createdAt'] as Timestamp).toDate() 
                  : DateTime.now(),
            );
          }).toList();
          
          _projects = updatedProjects;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        }, onError: (e) {
          print('Error in real-time listener: $e');
          _errorMessage = 'Error loading projects: $e';
          _loadFromAppConfig();
          _isLoading = false;
          notifyListeners();
        });
  }
  
  // Load data from AppConfig as fallback
  void _loadFromAppConfig() {
    print('Loading projects from AppConfig fallback');
    final projectsList = AppConfig.projects;
    _projects = List.generate(
      projectsList.length,
      (index) => Project.fromConfig(index, projectsList[index]),
    );
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
  
  @override
  void dispose() {
    // Cancel subscription when viewmodel is disposed
    _subscription?.cancel();
    super.dispose();
  }
}