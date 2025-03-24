// lib/services/firestore_setup_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portfolio_website/config/app_config.dart';

class FirestoreSetupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Initialize all required collections and documents
  Future<bool> initializeFirestore() async {
    try {
      print('Starting Firestore initialization...');
      
      // Create config collection and documents
      await _initializeConfigCollection();
      
      // Create empty collections
      await _initializeCollection('projects');
      await _initializeCollection('services');
      await _initializeCollection('contact_submissions');
      await _initializeCollection('analytics');
      
      print('Firestore initialization completed successfully');
      return true;
    } catch (e) {
      print('Error initializing Firestore: $e');
      return false;
    }
  }
  
  // Initialize config collection and its documents
  Future<void> _initializeConfigCollection() async {
    final configRef = _firestore.collection('config');
    
    // Check and create personal_info document
    final personalInfoDoc = await configRef.doc('personal_info').get();
    if (!personalInfoDoc.exists) {
      print('Creating personal_info document...');
      await configRef.doc('personal_info').set({
        'name': AppConfig.name,
        'title': AppConfig.title,
        'email': AppConfig.email,
        'phone': AppConfig.phone,
        'location': AppConfig.location,
        'aboutMe': AppConfig.aboutMe,
        'initials': AppConfig.initials,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    // Check and create social_links document
    final socialLinksDoc = await configRef.doc('social_links').get();
    if (!socialLinksDoc.exists) {
      print('Creating social_links document...');
      await configRef.doc('social_links').set({
        'github': AppConfig.socialLinks.github,
        'linkedin': AppConfig.socialLinks.linkedin,
        'fiverr': AppConfig.socialLinks.fiverr,
        'upwork': AppConfig.socialLinks.upwork,
        'freelancer': AppConfig.socialLinks.freelancer,
        'instagram': AppConfig.socialLinks.instagram,
        'facebook': AppConfig.socialLinks.facebook,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
  
  // Initialize an empty collection (Firestore creates collections when documents are added)
  Future<void> _initializeCollection(String collectionName) async {
    // Check if the collection has any documents
    final snapshot = await _firestore.collection(collectionName).limit(1).get();
    
    if (snapshot.docs.isEmpty && collectionName == 'projects') {
      // Add sample projects from AppConfig
      print('Initializing projects collection with sample data...');
      
      int index = 0;
      for (var projectInfo in AppConfig.projects) {
        await _firestore.collection('projects').add({
          'title': projectInfo.title,
          'description': projectInfo.description,
          'technologies': projectInfo.technologies,
          'youtubeVideoId': projectInfo.youtubeVideoId,
          'thumbnailUrl': projectInfo.thumbnailUrl,
          'order': index,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        index++;
      }
    }
    
    if (snapshot.docs.isEmpty && collectionName == 'services') {
      // Add sample services from AppConfig
      print('Initializing services collection with sample data...');
      
      int index = 0;
      for (var serviceInfo in AppConfig.services) {
        await _firestore.collection('services').add({
          'title': serviceInfo.title,
          'description': serviceInfo.description,
          'iconName': _getIconNameFromService(serviceInfo.title),
          'order': index,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        index++;
      }
    }
    
    if (snapshot.docs.isEmpty && collectionName == 'analytics') {
      // Initialize analytics documents
      print('Initializing analytics documents...');
      
      await _firestore.collection('analytics').doc('page_visits').set({
        'pages': {},
        'totalVisits': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      await _firestore.collection('analytics').doc('project_views').set({
        'projects': {},
        'totalViews': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
  
  // Helper method to assign icon names for services
  String _getIconNameFromService(String title) {
    if (title.contains('Mobile')) return 'phone_android';
    if (title.contains('UI') || title.contains('UX')) return 'design_services';
    if (title.contains('API')) return 'api';
    if (title.contains('Maintenance')) return 'build';
    return 'code'; // Default icon
  }
}