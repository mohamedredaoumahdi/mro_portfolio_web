// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/project_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static FirebaseService get instance => _instance;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  FirebaseService._internal();
  
  // Initialize Firebase with your credentials
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDIEiJa91VRseWa3udLSfN0bhAKhezssQc",
        authDomain: "myportfolio-594b1.firebaseapp.com",
        projectId: "myportfolio-594b1",
        storageBucket: "myportfolio-594b1.firebasestorage.app",
        messagingSenderId: "115489897719",
        appId: "1:115489897719:web:4337415f01a45598c027f2",
      ),
    );
  }
  
  // Fetch projects from Firebase
  Future<List<Project>> getProjects() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('projects').orderBy('order').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Project(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          technologies: List<String>.from(data['technologies'] ?? []),
          youtubeVideoId: data['youtubeVideoId'] ?? '',
          // Use direct URL to image instead of Firebase Storage
          thumbnailUrl: data['thumbnailUrl'] ?? '',
          date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null,
        );
      }).toList();
    } catch (e) {
      print('Error fetching projects: $e');
      return [];
    }
  }
  
  // Fetch services from Firebase
  Future<List<Service>> getServices() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('services').orderBy('order').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Service(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          iconPath: data['iconName'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching services: $e');
      return [];
    }
  }
  
  // Fetch personal information from Firebase
  Future<Map<String, dynamic>> getPersonalInfo() async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('config').doc('personal_info').get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print('Error fetching personal info: $e');
      return {};
    }
  }
  
  // Fetch social links from Firebase
  Future<Map<String, String>> getSocialLinks() async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('config').doc('social_links').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        Map<String, String> socialLinks = {};
        data.forEach((key, value) {
          socialLinks[key] = value.toString();
        });
        return socialLinks;
      }
      return {};
    } catch (e) {
      print('Error fetching social links: $e');
      return {};
    }
  }
  
  // Submit contact form
  Future<bool> submitContactForm(Map<String, dynamic> formData) async {
    try {
      await _firestore.collection('contact_submissions').add({
        ...formData,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error submitting contact form: $e');
      return false;
    }
  }
}