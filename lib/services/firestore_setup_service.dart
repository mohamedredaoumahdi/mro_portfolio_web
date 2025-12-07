// lib/services/firestore_setup_service.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portfolio_website/config/app_config.dart';

class FirestoreSetupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Initialize all required collections and documents
  Future<bool> initializeFirestore() async {
    try {
      debugPrint('Starting Firestore initialization...');
      
      // Create config collection and documents
      await _initializeConfigCollection();
      
      // Create empty collections
      await _initializeCollection('projects');
      await _initializeCollection('services');
      await _initializeCollection('contact_submissions');
      await _initializeCollection('analytics');
      
      debugPrint('Firestore initialization completed successfully');
      return true;
    } catch (e) {
      debugPrint('Error initializing Firestore: $e');
      return false;
    }
  }
  
  // Initialize config collection and its documents
  Future<void> _initializeConfigCollection() async {
    final configRef = _firestore.collection('config');
    
    // Check and create personal_info document
    final personalInfoDoc = await configRef.doc('personal_info').get();
    if (!personalInfoDoc.exists) {
      debugPrint('Creating personal_info document...');
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
      debugPrint('Creating social_links document...');
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
    
    if (collectionName == 'projects') {
      // Projects collection - DO NOT auto-create projects from AppConfig
      // Projects should ONLY be added through the admin dashboard
      debugPrint('Projects collection initialized - projects must be added through admin dashboard only');
      // Just ensure the collection exists (it will be created when first project is added via admin)
    }
    
    if (collectionName == 'services') {
      // Services collection - DO NOT auto-create services from AppConfig
      // Services should ONLY be added through the admin dashboard
      debugPrint('Services collection initialized - services must be added through admin dashboard only');
      // Just ensure the collection exists (it will be created when first service is added via admin)
    }
    
    if (snapshot.docs.isEmpty && collectionName == 'analytics') {
      // Initialize analytics documents
      debugPrint('Initializing analytics documents...');
      
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
  
}