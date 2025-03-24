// lib/services/activity_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portfolio_website/models/activity_model.dart';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  static ActivityService get instance => _instance;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _activitiesCollection = 
      FirebaseFirestore.instance.collection('activities');
  
  // Private constructor for singleton
  ActivityService._internal();
  
  // Log a new activity
  Future<void> logActivity({
    required String type,
    required String message,
    String? entityId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _activitiesCollection.add({
        'type': type,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'entityId': entityId,
        'metadata': metadata,
      });
      print('Activity logged: $message');
    } catch (e) {
      print('Error logging activity: $e');
    }
  }
  
  // Log a project view
  Future<void> logProjectView(String projectId, String projectTitle) async {
    await logActivity(
      type: 'view',
      message: 'Someone viewed your "$projectTitle" project',
      entityId: projectId,
      metadata: {'projectId': projectId, 'title': projectTitle},
    );
  }
  
  // Log a project edit
  Future<void> logProjectEdit(String projectId, String projectTitle) async {
    await logActivity(
      type: 'edit',
      message: 'You updated the "$projectTitle" project',
      entityId: projectId,
      metadata: {'projectId': projectId, 'title': projectTitle},
    );
  }
  
  // Log a new contact submission
  Future<void> logContactSubmission(String contactId, String name) async {
    await logActivity(
      type: 'contact',
      message: 'New contact message received from "$name"',
      entityId: contactId,
      metadata: {'contactId': contactId, 'name': name},
    );
  }
  
  // Get recent activities (one-time fetch)
  Future<List<Activity>> getRecentActivities({int limit = 10}) async {
    try {
      final QuerySnapshot snapshot = await _activitiesCollection
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => Activity.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching recent activities: $e');
      return [];
    }
  }
  
  // Get activities stream for real-time updates
  Stream<List<Activity>> getActivitiesStream({int limit = 10}) {
    return _activitiesCollection
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList());
  }
  
  // Clear old activities (for maintenance)
  Future<void> clearOldActivities(int daysToKeep) async {
    try {
      final DateTime cutoffDate = 
          DateTime.now().subtract(Duration(days: daysToKeep));
          
      final QuerySnapshot oldActivities = await _activitiesCollection
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();
      
      final batch = _firestore.batch();
      
      for (final doc in oldActivities.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('Cleared ${oldActivities.docs.length} old activities');
    } catch (e) {
      print('Error clearing old activities: $e');
    }
  }
}