// lib/viewmodels/activity_viewmodel.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:portfolio_website/models/activity_model.dart';
import 'package:portfolio_website/services/activity_service.dart';

class ActivityViewModel extends ChangeNotifier {
  final ActivityService _activityService = ActivityService.instance;
  
  List<Activity> _activities = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<List<Activity>>? _activitySubscription;
  
  // Getters
  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Constructor
  ActivityViewModel() {
    loadActivities();
  }
  
  // Load activities with real-time updates
  void loadActivities({int limit = 10}) {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Cancel any existing subscription
      _activitySubscription?.cancel();
      
      // Subscribe to real-time updates
      _activitySubscription = _activityService.getActivitiesStream(limit: limit)
          .listen((updatedActivities) {
            _activities = updatedActivities;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          }, onError: (e) {
            _errorMessage = 'Error loading activities: $e';
            _isLoading = false;
            notifyListeners();
            debugPrint('Activity stream error: $e');
          });
    } catch (e) {
      _errorMessage = 'Error setting up activity stream: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error in ActivityViewModel: $e');
    }
  }
  
  // Log a new activity
  Future<void> logActivity({
    required String type,
    required String message,
    String? entityId,
    Map<String, dynamic>? metadata,
  }) async {
    await _activityService.logActivity(
      type: type,
      message: message,
      entityId: entityId,
      metadata: metadata,
    );
  }
  
  // Log a project view
  Future<void> logProjectView(String projectId, String projectTitle) async {
    await _activityService.logProjectView(projectId, projectTitle);
  }
  
  // Log a project edit
  Future<void> logProjectEdit(String projectId, String projectTitle) async {
    await _activityService.logProjectEdit(projectId, projectTitle);
  }
  
  // Log a contact submission
  Future<void> logContactSubmission(String contactId, String name) async {
    await _activityService.logContactSubmission(contactId, name);
  }

  Future<List<Map<String, dynamic>>> getRecentActivities({int limit = 10}) async {
    try {
      final List<Activity> activities = await _activityService.getRecentActivities(limit: limit);
      
      // Convert Activity objects to Maps with proper timestamp
      return activities.map((activity) => {
        'id': activity.id,
        'type': activity.type,
        'message': activity.message,
        'timestamp': activity.timestamp, // This is a DateTime object from Activity model
        'entityId': activity.entityId,
        'metadata': activity.metadata,
      }).toList();
    } catch (e) {
      debugPrint('Error fetching recent activities: $e');
      return [];
    }
  }
  
  // Clean up on dispose
  @override
  void dispose() {
    _activitySubscription?.cancel();
    super.dispose();
  }
}