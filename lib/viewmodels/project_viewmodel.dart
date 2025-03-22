import 'package:flutter/foundation.dart';
import 'package:portfolio_website/config/app_config.dart';
import '../models/project_model.dart';

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

  // Load projects from app config
  Future<void> loadProjects() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate network delay (remove in production)
      if (kDebugMode) {
        await Future.delayed(const Duration(milliseconds: 800));
      }

      // Load project data from config
      final projectsList = AppConfig.projects;
      _projects = List.generate(
        projectsList.length,
        (index) => Project.fromConfig(index, projectsList[index]),
      );

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

  // Filter projects by technology (if needed in the future)
  List<Project> filterByTechnology(String technology) {
    return _projects.where((project) => 
      project.technologies.contains(technology)
    ).toList();
  }
}