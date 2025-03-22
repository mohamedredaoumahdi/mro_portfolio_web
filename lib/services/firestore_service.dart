// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portfolio_website/models/project_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  final CollectionReference _projectsCollection = 
      FirebaseFirestore.instance.collection('projects');
  final CollectionReference _servicesCollection = 
      FirebaseFirestore.instance.collection('services');
  final CollectionReference _configCollection = 
      FirebaseFirestore.instance.collection('config');
  final CollectionReference _analyticsCollection = 
      FirebaseFirestore.instance.collection('analytics');
  
  // =================== Projects Management ===================
  
  // Get all projects
  Future<List<Project>> getProjects() async {
    try {
      final QuerySnapshot snapshot = 
          await _projectsCollection.orderBy('order', descending: false).get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        return Project(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          technologies: List<String>.from(data['technologies'] ?? []),
          youtubeVideoId: data['youtubeVideoId'] ?? '',
          thumbnailUrl: data['thumbnailUrl'] ?? 
              'https://img.youtube.com/vi/${data['youtubeVideoId'] ?? ''}/hqdefault.jpg',
          date: data['date'] != null ? 
              DateTime.parse(data['date']) : 
              DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error fetching projects: $e');
      rethrow;
    }
  }
  
  // Add a new project
  Future<void> addProject(Map<String, dynamic> projectData) async {
    try {
      // Get the current number of projects for ordering
      final QuerySnapshot snapshot = await _projectsCollection.get();
      final int order = snapshot.size; // New project will be at the end
      
      // Add order field
      projectData['order'] = order;
      
      // Add creation timestamp
      projectData['createdAt'] = FieldValue.serverTimestamp();
      projectData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _projectsCollection.add(projectData);
    } catch (e) {
      print('Error adding project: $e');
      rethrow;
    }
  }
  
  // Update an existing project
  Future<void> updateProject(String projectId, Map<String, dynamic> projectData) async {
    try {
      // Add update timestamp
      projectData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _projectsCollection.doc(projectId).update(projectData);
    } catch (e) {
      print('Error updating project: $e');
      rethrow;
    }
  }
  
  // Delete a project
  Future<void> deleteProject(String projectId) async {
    try {
      await _projectsCollection.doc(projectId).delete();
      
      // Re-order remaining projects
      await _updateProjectsOrder();
    } catch (e) {
      print('Error deleting project: $e');
      rethrow;
    }
  }
  
  // Reorder projects
  Future<void> reorderProjects(int oldIndex, int newIndex) async {
    try {
      // Get all projects ordered by current order
      final QuerySnapshot snapshot = 
          await _projectsCollection.orderBy('order', descending: false).get();
      
      final List<DocumentSnapshot> docs = snapshot.docs;
      
      // Adjust indices if needed
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      // Get the project being moved
      final DocumentSnapshot movedProject = docs[oldIndex];
      
      // Update orders
      final batch = _firestore.batch();
      
      // Update order for each affected project
      for (int i = 0; i < docs.length; i++) {
        final doc = docs[i];
        
        if (i == newIndex) {
          // Set the moved project's new order
          batch.update(
            movedProject.reference, 
            {'order': i, 'updatedAt': FieldValue.serverTimestamp()}
          );
        } else if (oldIndex < newIndex && i > oldIndex && i <= newIndex) {
          // Projects that need to move up
          batch.update(
            doc.reference, 
            {'order': i - 1, 'updatedAt': FieldValue.serverTimestamp()}
          );
        } else if (oldIndex > newIndex && i >= newIndex && i < oldIndex) {
          // Projects that need to move down
          batch.update(
            doc.reference, 
            {'order': i + 1, 'updatedAt': FieldValue.serverTimestamp()}
          );
        }
      }
      
      await batch.commit();
    } catch (e) {
      print('Error reordering projects: $e');
      rethrow;
    }
  }
  
  // Update order after deletion
  Future<void> _updateProjectsOrder() async {
    try {
      // Get all projects
      final QuerySnapshot snapshot = 
          await _projectsCollection.orderBy('order', descending: false).get();
      
      final List<DocumentSnapshot> docs = snapshot.docs;
      
      // Update orders
      final batch = _firestore.batch();
      
      for (int i = 0; i < docs.length; i++) {
        batch.update(
          docs[i].reference, 
          {'order': i, 'updatedAt': FieldValue.serverTimestamp()}
        );
      }
      
      await batch.commit();
    } catch (e) {
      print('Error updating project order: $e');
      rethrow;
    }
  }
  
  // =================== Services Management ===================
  
  // Get all services
  Future<List<Service>> getServices() async {
    try {
      final QuerySnapshot snapshot = 
          await _servicesCollection.orderBy('order', descending: false).get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        return Service(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          iconPath: data['iconName'] ?? '', // Using icon name from Material Icons
        );
      }).toList();
    } catch (e) {
      print('Error fetching services: $e');
      rethrow;
    }
  }
  
  // Add a new service
  Future<void> addService(Map<String, dynamic> serviceData) async {
    try {
      // Get the current number of services for ordering
      final QuerySnapshot snapshot = await _servicesCollection.get();
      final int order = snapshot.size; // New service will be at the end
      
      // Add order field
      serviceData['order'] = order;
      
      // Add creation timestamp
      serviceData['createdAt'] = FieldValue.serverTimestamp();
      serviceData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _servicesCollection.add(serviceData);
    } catch (e) {
      print('Error adding service: $e');
      rethrow;
    }
  }
  
  // Update an existing service
  Future<void> updateService(String serviceId, Map<String, dynamic> serviceData) async {
    try {
      // Add update timestamp
      serviceData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _servicesCollection.doc(serviceId).update(serviceData);
    } catch (e) {
      print('Error updating service: $e');
      rethrow;
    }
  }
  
  // Delete a service
  Future<void> deleteService(String serviceId) async {
    try {
      await _servicesCollection.doc(serviceId).delete();
      
      // Re-order remaining services
      await _updateServicesOrder();
    } catch (e) {
      print('Error deleting service: $e');
      rethrow;
    }
  }
  
  // Update order after deletion
  Future<void> _updateServicesOrder() async {
    try {
      // Get all services
      final QuerySnapshot snapshot = 
          await _servicesCollection.orderBy('order', descending: false).get();
      
      final List<DocumentSnapshot> docs = snapshot.docs;
      
      // Update orders
      final batch = _firestore.batch();
      
      for (int i = 0; i < docs.length; i++) {
        batch.update(
          docs[i].reference, 
          {'order': i, 'updatedAt': FieldValue.serverTimestamp()}
        );
      }
      
      await batch.commit();
    } catch (e) {
      print('Error updating service order: $e');
      rethrow;
    }
  }
  
  // =================== Profile Management ===================
  
  // Get personal information
  Future<Map<String, dynamic>> getPersonalInfo() async {
    try {
      final DocumentSnapshot doc = 
          await _configCollection.doc('personal_info').get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      
      return {};
    } catch (e) {
      print('Error fetching personal info: $e');
      rethrow;
    }
  }
  
  // Update personal information
  Future<void> updatePersonalInfo(Map<String, dynamic> personalData) async {
    try {
      // Add update timestamp
      personalData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _configCollection.doc('personal_info').set(
        personalData, 
        SetOptions(merge: true)
      );
    } catch (e) {
      print('Error updating personal info: $e');
      rethrow;
    }
  }
  
  // Get social links
  Future<Map<String, dynamic>> getSocialLinks() async {
    try {
      final DocumentSnapshot doc = 
          await _configCollection.doc('social_links').get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      
      return {};
    } catch (e) {
      print('Error fetching social links: $e');
      rethrow;
    }
  }
  
  // Update social links
  Future<void> updateSocialLinks(Map<String, dynamic> socialData) async {
    try {
      // Add update timestamp
      socialData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _configCollection.doc('social_links').set(
        socialData, 
        SetOptions(merge: true)
      );
    } catch (e) {
      print('Error updating social links: $e');
      rethrow;
    }
  }
  
  // =================== Analytics Tracking ===================
  
  // Log a page visit
  Future<void> logPageVisit(String page) async {
    try {
      // Get the current document
      final DocumentSnapshot doc = 
          await _analyticsCollection.doc('page_visits').get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final Map<String, dynamic> pages = data['pages'] ?? {};
        
        // Increment the count for this page
        pages[page] = (pages[page] ?? 0) + 1;
        
        // Update the document
        await _analyticsCollection.doc('page_visits').update({
          'pages': pages,
          'totalVisits': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new document
        await _analyticsCollection.doc('page_visits').set({
          'pages': {page: 1},
          'totalVisits': 1,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Just log errors for analytics - don't disrupt the user experience
      print('Error logging page visit: $e');
    }
  }
  
  // Log a project view
  Future<void> logProjectView(String projectId) async {
    try {
      // Get the current document
      final DocumentSnapshot doc = 
          await _analyticsCollection.doc('project_views').get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final Map<String, dynamic> projects = data['projects'] ?? {};
        
        // Increment the count for this project
        projects[projectId] = (projects[projectId] ?? 0) + 1;
        
        // Update the document
        await _analyticsCollection.doc('project_views').update({
          'projects': projects,
          'totalViews': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new document
        await _analyticsCollection.doc('project_views').set({
          'projects': {projectId: 1},
          'totalViews': 1,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Just log errors for analytics - don't disrupt the user experience
      print('Error logging project view: $e');
    }
  }
  
  // Get analytics data
  Future<Map<String, dynamic>> getAnalyticsData() async {
    try {
      final pageVisitsDoc = await _analyticsCollection.doc('page_visits').get();
      final projectViewsDoc = await _analyticsCollection.doc('project_views').get();
      final contactSubmissionsDoc = await _analyticsCollection.doc('contact_submissions').get();
      
      final Map<String, dynamic> analyticsData = {};
      
      if (pageVisitsDoc.exists) {
        analyticsData['pageVisits'] = pageVisitsDoc.data();
      }
      
      if (projectViewsDoc.exists) {
        analyticsData['projectViews'] = projectViewsDoc.data();
      }
      
      if (contactSubmissionsDoc.exists) {
        analyticsData['contactSubmissions'] = contactSubmissionsDoc.data();
      }
      
      return analyticsData;
    } catch (e) {
      print('Error fetching analytics data: $e');
      rethrow;
    }
  }
}