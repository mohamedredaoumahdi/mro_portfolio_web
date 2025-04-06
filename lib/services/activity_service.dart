// lib/services/activity_service.dart
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portfolio_website/models/activity_model.dart';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  static ActivityService get instance => _instance;
  
  final FirebaseFirestore _firestore;
  final CollectionReference _activitiesCollection;
  
  // Private constructor for singleton
  ActivityService._internal() :
    _firestore = FirebaseFirestore.instance,
    _activitiesCollection = FirebaseFirestore.instance.collection('activities');
  
  // Check if Firebase is available
  bool get _isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      print('Firebase availability check error: $e');
      return false;
    }
  }
  
  // Log a new activity with error handling and timeout
  Future<void> logActivity({
    required String type,
    required String message,
    String? entityId,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isFirebaseAvailable) {
      print('Activity not logged - Firebase unavailable');
      return;
    }
    
    try {
      // Add a timeout to prevent this operation from hanging
      await _activitiesCollection.add({
        'type': type,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'entityId': entityId,
        'metadata': metadata,
      }).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Activity logging timed out');
        },
      );
      print('Activity logged: $message');
    } catch (e) {
      print('Error logging activity: $e');
      // Don't rethrow - activity logging should be non-blocking
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
  
  // Get recent activities (one-time fetch) with error handling
  Future<List<Activity>> getRecentActivities({int limit = 10}) async {
    if (!_isFirebaseAvailable) {
      print('Cannot fetch activities - Firebase unavailable');
      return [];
    }
    
    try {
      final QuerySnapshot snapshot = await _activitiesCollection
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException('Fetching activities timed out');
            },
          );
      
      return snapshot.docs
          .map((doc) => Activity.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching recent activities: $e');
      return [];
    }
  }
  
  // Get activities stream for real-time updates with reconnection logic
  Stream<List<Activity>> getActivitiesStream({int limit = 10}) {
    if (!_isFirebaseAvailable) {
      print('Cannot stream activities - Firebase unavailable');
      // Return empty stream
      return Stream.value([]);
    }
    
    // Create a stream transformer that handles errors and reconnects
    StreamTransformer<QuerySnapshot<Object?>, List<Activity>> transformer = 
      StreamTransformer.fromHandlers(
        handleData: (QuerySnapshot data, EventSink<List<Activity>> sink) {
          final activities = data.docs.map((doc) => Activity.fromFirestore(doc)).toList();
          sink.add(activities);
        },
        handleError: (error, stackTrace, sink) {
          print('Activity stream error: $error\n$stackTrace');
          // Add empty list to prevent stream from breaking
          sink.add([]);
          
          // Try to reconnect after a delay
          Timer(const Duration(seconds: 10), () {
            print('Attempting to reconnect activity stream...');
            // The stream will automatically try to reconnect
          });
        },
        handleDone: (sink) {
          print('Activity stream closed');
          sink.close();
        }
      );
    
    // Apply the transformer to the stream
    return _activitiesCollection
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .timeout(
          const Duration(seconds: 30),
          onTimeout: (sink) {
            print('Activity stream timed out - will reconnect');
            sink.addError('Stream timeout');
          },
        )
        .transform(transformer);
  }
  
  // Clear old activities (for maintenance) with batched operations
  Future<void> clearOldActivities(int daysToKeep) async {
    if (!_isFirebaseAvailable) {
      print('Cannot clear activities - Firebase unavailable');
      return;
    }
    
    try {
      final DateTime cutoffDate = 
          DateTime.now().subtract(Duration(days: daysToKeep));
          
      final QuerySnapshot oldActivities = await _activitiesCollection
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();
      
      print('Found ${oldActivities.docs.length} old activities to clear');
      
      if (oldActivities.docs.isEmpty) {
        return;
      }
      
      // Use batched writes for better performance with many deletes
      // Firebase limits batch operations to 500, so we may need multiple batches
      const int batchLimit = 500;
      final int batchCount = (oldActivities.docs.length / batchLimit).ceil();
      
      for (int i = 0; i < batchCount; i++) {
        final int startIndex = i * batchLimit;
        final int endIndex = (i + 1) * batchLimit < oldActivities.docs.length 
            ? (i + 1) * batchLimit 
            : oldActivities.docs.length;
        
        final batch = _firestore.batch();
        
        for (int j = startIndex; j < endIndex; j++) {
          batch.delete(oldActivities.docs[j].reference);
        }
        
        await batch.commit();
        print('Cleared batch ${i+1}/$batchCount of old activities');
      }
      
      print('Successfully cleared ${oldActivities.docs.length} old activities');
    } catch (e) {
      print('Error clearing old activities: $e');
    }
  }
}