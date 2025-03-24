// lib/models/activity_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String type;  // 'view', 'edit', 'contact', etc.
  final String message;
  final DateTime timestamp;
  final String? entityId;  // ID of related project, message, etc.
  final Map<String, dynamic>? metadata;

  Activity({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    this.entityId,
    this.metadata,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      type: data['type'] ?? 'unknown',
      message: data['message'] ?? 'Unknown activity',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      entityId: data['entityId'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'entityId': entityId,
      'metadata': metadata,
    };
  }

  // Helper to format time as '2 minutes ago', '1 hour ago', etc.
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}