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
  bool _isLoading = false; // Start as false, only set to true when explicitly loading
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _subscription;
  bool _initialized = false;
  Timer? _timeoutTimer;

  // Getters
  List<Project> get projects => _projects;
  Project? get selectedProject => _selectedProject;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get initialized => _initialized;

  // Constructor - doesn't auto-load data
  ProjectViewModel();

  // Initialize method to be called after widget build
  Future<void> initialize() async {
    if (!_initialized && !_isLoading) {
      // Always load AppConfig data first as immediate fallback
      _loadFromAppConfig();
      // Notify listeners immediately so UI can show projects
      notifyListeners();
      
      // Mark as initialized since we have AppConfig data
      _initialized = true;
      
      // Then try to load from Firebase (this might update the data later)
      await loadProjects();
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

  // Load projects either from Firebase or local config
  Future<void> loadProjects() async {
    try {
      if (_isLoading) return; // Prevent concurrent loads
      
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simulate network delay in debug mode
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Use Firebase if available (but we already have AppConfig data as fallback)
      if (_isFirebaseAvailable) {
        try {
          // Set up real-time listener for projects
          _setupRealTimeListener();
          
          // Add timeout to prevent getting stuck in loading state
          _timeoutTimer?.cancel();
          _timeoutTimer = Timer(const Duration(seconds: 5), () {
            if (_isLoading) {
              print('Firebase listener timeout - falling back to AppConfig data');
              _loadFromAppConfig(); // This will set _isLoading = false
              notifyListeners();
            }
          });
          
          return; // Early return as listener will handle updates
        } catch (e) {
          print(
              'Error setting up Firestore listener: $e - Using AppConfig fallback');
          // Firebase error - we already have AppConfig data, just set loading to false
          _isLoading = false;
          notifyListeners();
          return;
        }
      } else {
        // Firebase not available - we already have AppConfig data
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

  void _setupRealTimeListener() {
    print('Setting up real-time listener for projects...');

    // Cancel existing subscription if any
    _subscription?.cancel();

    // Set up listener with error handling
    try {
      _subscription = FirebaseFirestore.instance
          .collection('projects')
          .orderBy('order')
          .snapshots()
          .listen((snapshot) {
        print('Real-time update for projects: ${snapshot.docs.length} items');

        final List<Project> updatedProjects = snapshot.docs.map((doc) {
          final data = doc.data();

          // Handle screenshots array in the project data
          List<ProjectScreenshot> screenshots = [];
          if (data['screenshots'] != null && data['screenshots'] is List) {
            screenshots = (data['screenshots'] as List).map((screenshotData) {
              if (screenshotData is Map<String, dynamic>) {
                return ProjectScreenshot.fromMap(screenshotData);
              }
              return ProjectScreenshot(id: '', imageBase64: '');
            }).toList();
          }

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
            screenshots: screenshots, // Add the screenshots field
          );
        }).toList();

        _projects = updatedProjects;
        _timeoutTimer?.cancel(); // Cancel timeout since we got data
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      }, onError: (e) {
        print('Error in real-time listener: $e - falling back to AppConfig');
        _timeoutTimer?.cancel(); // Cancel timeout since we're handling the error
        _loadFromAppConfig(); // This will set _isLoading = false
        notifyListeners(); // Ensure UI updates
      }, onDone: () {
        print('Projects listener closed');
      });
    } catch (e) {
      print('Exception setting up projects listener: $e');
      _errorMessage = 'Error setting up projects listener: $e';
      _loadFromAppConfig(); // This will set _isLoading = false  
      notifyListeners();
    }
  }

  // Load data from AppConfig as fallback
  void _loadFromAppConfig() {
    print('Loading projects from AppConfig fallback');
    const projectsList = AppConfig.projects;
    _projects = List.generate(
      projectsList.length,
      (index) {
        // Load project from AppConfig
        final project = Project.fromConfig(index, projectsList[index]);

        // Debug print
        print(
            'Loaded project from AppConfig: ${project.title}, screenshots: ${project.screenshots.length}');

        return project;
      },
    );

    // Set loading to false since we have AppConfig data
    _isLoading = false;
    _errorMessage = null;
    print('AppConfig projects loaded: ${_projects.length} projects');

    // If coming from AppConfig, you could also try to load screenshots from Firestore separately
    // even if the rest of the project info is from AppConfig
    if (_isFirebaseAvailable) {
      _loadScreenshotsFromFirestore();
    }
  }

// New method to try loading just screenshots from Firestore
  Future<void> _loadScreenshotsFromFirestore() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('projects').get();
      final Map<String, List<ProjectScreenshot>> screenshotsByTitle = {};

      // Create a map of project title to screenshots
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final String title = data['title'] ?? '';

        // Parse screenshots if available
        if (data['screenshots'] != null && data['screenshots'] is List) {
          final List<ProjectScreenshot> screenshots =
              (data['screenshots'] as List)
                  .map((screenshotData) {
                    if (screenshotData is Map<String, dynamic>) {
                      return ProjectScreenshot.fromMap(screenshotData);
                    }
                    return ProjectScreenshot(id: '', imageBase64: '');
                  })
                  .where((screenshot) => screenshot.id.isNotEmpty)
                  .toList();

          if (screenshots.isNotEmpty) {
            screenshotsByTitle[title] = screenshots;
          }
        }
      }

      // Update projects with screenshots from Firestore
      if (screenshotsByTitle.isNotEmpty) {
        print(
            'Found screenshots in Firestore for ${screenshotsByTitle.length} projects');

        for (int i = 0; i < _projects.length; i++) {
          final project = _projects[i];
          if (screenshotsByTitle.containsKey(project.title)) {
            _projects[i] = Project(
              id: project.id,
              title: project.title,
              description: project.description,
              technologies: project.technologies,
              youtubeVideoId: project.youtubeVideoId,
              thumbnailUrl: project.thumbnailUrl,
              date: project.date,
              screenshots: screenshotsByTitle[project.title]!,
            );
            print(
                'Updated screenshots for ${project.title}: ${screenshotsByTitle[project.title]!.length} screenshots');
          }
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error loading screenshots from Firestore: $e');
      // Continue with projects without screenshots
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
    return _projects
        .where((project) => project.technologies.contains(technology))
        .toList();
  }

  // Refresh projects - force reload
  Future<void> refreshProjects() async {
    _subscription?.cancel();
    _subscription = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _isLoading = false;
    await loadProjects();
  }

  @override
  void dispose() {
    // Cancel subscription and timeout when viewmodel is disposed
    _subscription?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }
}