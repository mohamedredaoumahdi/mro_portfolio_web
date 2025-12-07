// lib/services/firestore_service.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:portfolio_website/models/project_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  static FirestoreService get instance => _instance;

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
  final CollectionReference _contactSubmissionsCollection =
      FirebaseFirestore.instance.collection('contact_submissions');

  FirestoreService._internal();

  // =================== Projects Management ===================

  // Get all projects
  // Updates to FirestoreService class - Add these methods or replace existing ones

// Get all projects - Updated to handle screenshots
  Future<List<Project>> getProjects() async {
    try {
      debugPrint('Fetching projects from Firestore...');
      final QuerySnapshot snapshot =
          await _projectsCollection.orderBy('order', descending: false).get();

      debugPrint('Retrieved ${snapshot.docs.length} projects from Firestore');
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Handle screenshots (convert from List<dynamic> to List<ProjectScreenshot>)
        List<ProjectScreenshot> screenshots = [];
        if (data['screenshots'] != null) {
          screenshots = (data['screenshots'] as List).map((screenshotData) {
            return ProjectScreenshot.fromMap(
                screenshotData as Map<String, dynamic>);
          }).toList();
        }

        return Project(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          technologies: List<String>.from(data['technologies'] ?? []),
          youtubeVideoId: data['youtubeVideoId'] ?? '',
          thumbnailUrl: data['thumbnailUrl'] ??
              'https://img.youtube.com/vi/${data['youtubeVideoId'] ?? ''}/hqdefault.jpg',
          date: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          screenshots: screenshots,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching projects: $e');
      rethrow;
    }
  }

// Add a new project - Updated to handle screenshots
  Future<DocumentReference> addProject(Map<String, dynamic> projectData) async {
    try {
      debugPrint('Adding new project: ${projectData['title']}');
      // Get the current number of projects for ordering
      final QuerySnapshot snapshot = await _projectsCollection.get();
      final int order = snapshot.size; // New project will be at the end

      // Add order field
      projectData['order'] = order;

      // Add creation timestamp
      projectData['createdAt'] = FieldValue.serverTimestamp();
      projectData['updatedAt'] = FieldValue.serverTimestamp();

      // Handle screenshots if present
      if (projectData.containsKey('screenshots')) {
        // Convert ProjectScreenshot objects to maps for Firestore
        List<Map<String, dynamic>> screenshotMaps = [];
        if (projectData['screenshots'] is List<ProjectScreenshot>) {
          screenshotMaps =
              (projectData['screenshots'] as List<ProjectScreenshot>)
                  .map((screenshot) => screenshot.toMap())
                  .toList();
          projectData['screenshots'] = screenshotMaps;
        }
      }

      // Add the document and return the reference
      final docRef = await _projectsCollection.add(projectData);
      debugPrint('Project added successfully');
      return docRef;
    } catch (e) {
      debugPrint('Error adding project: $e');
      rethrow;
    }
  }

// Update an existing project - Updated to handle screenshots
  Future<void> updateProject(
      String projectId, Map<String, dynamic> projectData) async {
    try {
      debugPrint('Updating project: $projectId');
      // Add update timestamp
      projectData['updatedAt'] = FieldValue.serverTimestamp();

      // Handle screenshots if present
      if (projectData.containsKey('screenshots')) {
        // Convert ProjectScreenshot objects to maps for Firestore
        List<Map<String, dynamic>> screenshotMaps = [];
        if (projectData['screenshots'] is List<ProjectScreenshot>) {
          screenshotMaps =
              (projectData['screenshots'] as List<ProjectScreenshot>)
                  .map((screenshot) => screenshot.toMap())
                  .toList();
          projectData['screenshots'] = screenshotMaps;
        }
      }

      await _projectsCollection.doc(projectId).update(projectData);
      debugPrint('Project updated successfully');
    } catch (e) {
      debugPrint('Error updating project: $e');
      rethrow;
    }
  }

  // Delete a project
  Future<void> deleteProject(String projectId) async {
    try {
      debugPrint('Deleting project: $projectId');
      await _projectsCollection.doc(projectId).delete();

      // Re-order remaining projects
      await _updateProjectsOrder();
      debugPrint('Project deleted successfully');
    } catch (e) {
      debugPrint('Error deleting project: $e');
      rethrow;
    }
  }

  // Reorder projects
  Future<void> reorderProjects(int oldIndex, int newIndex) async {
    try {
      debugPrint('Reordering projects from $oldIndex to $newIndex');
      // Get all projects ordered by current order
      final QuerySnapshot snapshot =
          await _projectsCollection.orderBy('order', descending: false).get();

      final List<DocumentSnapshot> docs = snapshot.docs;

      if (docs.isEmpty || oldIndex < 0 || newIndex < 0 || 
          oldIndex >= docs.length || newIndex >= docs.length) {
        throw Exception('Invalid indices for reordering');
      }

      // Adjust newIndex if dragging down (Flutter ReorderableListView behavior)
      int adjustedNewIndex = newIndex;
      if (oldIndex < newIndex) {
        adjustedNewIndex = newIndex - 1;
      }

      // Create a new list with reordered items
      final List<DocumentSnapshot> reorderedDocs = List.from(docs);
      final DocumentSnapshot movedDoc = reorderedDocs.removeAt(oldIndex);
      reorderedDocs.insert(adjustedNewIndex, movedDoc);

      // Update orders for all projects
      final batch = _firestore.batch();
      for (int i = 0; i < reorderedDocs.length; i++) {
        final doc = reorderedDocs[i];
        final data = doc.data() as Map<String, dynamic>;
        final currentOrder = data['order'];
        
        // Only update if the order actually changed
        if (currentOrder != i) {
          batch.update(
            doc.reference,
            {
              'order': i,
              'updatedAt': FieldValue.serverTimestamp(),
            },
          );
          debugPrint('Updating project ${doc.id} order from $currentOrder to $i');
        }
      }

      await batch.commit();
      debugPrint('Projects reordered successfully: ${reorderedDocs.length} projects updated');
    } catch (e, stackTrace) {
      debugPrint('Error reordering projects: $e');
      debugPrint('Stack trace: $stackTrace');
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
        batch.update(docs[i].reference,
            {'order': i, 'updatedAt': FieldValue.serverTimestamp()});
      }

      await batch.commit();
      debugPrint('Project order updated successfully');
    } catch (e) {
      debugPrint('Error updating project order: $e');
      rethrow;
    }
  }

  // =================== Services Management ===================

  // Get all services
  Future<List<Service>> getServices() async {
    try {
      debugPrint('Fetching services from Firestore...');
      final QuerySnapshot snapshot =
          await _servicesCollection.orderBy('order', descending: false).get();

      debugPrint('Retrieved ${snapshot.docs.length} services from Firestore');
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return Service(
          id: doc.id,
          title: (data['title'] ?? '').toString(),
          description: (data['description'] ?? '').toString(),
          iconPath: (data['iconName'] ?? '').toString(), // Using icon name from Material Icons
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching services: $e');
      rethrow;
    }
  }

  // Add a new service
  Future<DocumentReference> addService(Map<String, dynamic> serviceData) async {
    try {
      debugPrint('Adding new service: ${serviceData['title']}');
      
      // Ensure all string fields are actually strings
      final cleanData = <String, dynamic>{
        'title': serviceData['title']?.toString() ?? '',
        'description': serviceData['description']?.toString() ?? '',
        'iconName': serviceData['iconName']?.toString() ?? '',
      };
      
      // Get the current number of services for ordering
      final QuerySnapshot snapshot = await _servicesCollection.get();
      final int order = snapshot.size; // New service will be at the end

      // Add order field
      cleanData['order'] = order;

      // Add creation timestamp
      cleanData['createdAt'] = FieldValue.serverTimestamp();
      cleanData['updatedAt'] = FieldValue.serverTimestamp();

      debugPrint('Service data to add: $cleanData');
      final docRef = await _servicesCollection.add(cleanData);
      debugPrint('Service added successfully with ID: ${docRef.id}');
      return docRef;
    } catch (e, stackTrace) {
      debugPrint('Error adding service: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Service data was: $serviceData');
      rethrow;
    }
  }

  // Update an existing service
  Future<void> updateService(
      String serviceId, Map<String, dynamic> serviceData) async {
    try {
      debugPrint('Updating service: $serviceId');
      // Add update timestamp
      serviceData['updatedAt'] = FieldValue.serverTimestamp();

      await _servicesCollection.doc(serviceId).update(serviceData);
      debugPrint('Service updated successfully');
    } catch (e) {
      debugPrint('Error updating service: $e');
      rethrow;
    }
  }

  // Delete a service
  Future<void> deleteService(String serviceId) async {
    try {
      debugPrint('Deleting service with ID: $serviceId');
      
      // Verify the document exists before trying to delete
      final docRef = _servicesCollection.doc(serviceId);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        throw Exception('Service with ID $serviceId does not exist in Firestore');
      }
      
      debugPrint('Service document exists, proceeding with deletion...');
      
      // Delete the document
      await docRef.delete();
      debugPrint('Service document deleted from Firestore');

      // Re-order remaining services
      await _updateServicesOrder();
      debugPrint('Service deleted and order updated successfully');
    } catch (e) {
      debugPrint('Error deleting service: $e');
      debugPrint('Service ID was: $serviceId');
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
        batch.update(docs[i].reference,
            {'order': i, 'updatedAt': FieldValue.serverTimestamp()});
      }

      await batch.commit();
      debugPrint('Service order updated successfully');
    } catch (e) {
      debugPrint('Error updating service order: $e');
      rethrow;
    }
  }

  // =================== Profile Management ===================

  // Get personal information
  Future<Map<String, dynamic>> getPersonalInfo() async {
    try {
      debugPrint('Fetching personal info from Firestore...');
      final DocumentSnapshot doc =
          await _configCollection.doc('personal_info').get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint(
            'Successfully loaded personal info from Firestore: ${data['title']}');
        return data;
      }

      debugPrint('No personal_info document found in Firestore');
      return {};
    } catch (e) {
      debugPrint('Error fetching personal info from Firestore: $e');
      rethrow;
    }
  }

  // Update personal information
  Future<void> updatePersonalInfo(Map<String, dynamic> personalData) async {
    try {
      debugPrint('Updating personal info in Firestore...');
      // Add update timestamp
      personalData['updatedAt'] = FieldValue.serverTimestamp();

      await _configCollection
          .doc('personal_info')
          .set(personalData, SetOptions(merge: true));
      debugPrint('Personal info updated successfully');
    } catch (e) {
      debugPrint('Error updating personal info: $e');
      rethrow;
    }
  }

  // Get social links
  Future<Map<String, dynamic>> getSocialLinks() async {
    try {
      debugPrint('Fetching social links from Firestore...');
      final DocumentSnapshot doc =
          await _configCollection.doc('social_links').get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }

      debugPrint('No social_links document found in Firestore');
      return {};
    } catch (e) {
      debugPrint('Error fetching social links: $e');
      rethrow;
    }
  }

  // Update social links
  Future<void> updateSocialLinks(Map<String, dynamic> socialData) async {
  try {
    debugPrint('Updating social links in Firestore...');
    
    // Create a new map with the provided data
    Map<String, dynamic> dataToUpdate = Map.from(socialData);
    
    // Add Firestore server timestamp
    dataToUpdate['updatedAt'] = FieldValue.serverTimestamp();

    await _configCollection
        .doc('social_links')
        .set(dataToUpdate, SetOptions(merge: true));
        
    debugPrint('Social links updated successfully');
  } catch (e) {
    debugPrint('Error updating social links: $e');
    rethrow;  // Re-throw so UI can handle it
  }
}

  // =================== Contact Form Submissions ===================

  // Submit contact form
  Future<bool> submitContactForm(Map<String, dynamic> formData) async {
    try {
      debugPrint('Submitting contact form to Firestore...');
      await _contactSubmissionsCollection.add({
        ...formData,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('Contact form submitted successfully');
      return true;
    } catch (e) {
      debugPrint('Error submitting contact form: $e');
      return false;
    }
  }

  // Get contact submissions (for admin view)
  Future<List<Map<String, dynamic>>> getContactSubmissions() async {
    try {
      debugPrint('Fetching contact submissions from Firestore...');
      final QuerySnapshot snapshot = await _contactSubmissionsCollection
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching contact submissions: $e');
      return []; // Return empty list instead of throwing to avoid dashboard errors
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
      debugPrint('Error logging page visit: $e');
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
      debugPrint('Error logging project view: $e');
    }
  }

  // Get analytics data
  Future<Map<String, dynamic>> getAnalyticsData() async {
    try {
      debugPrint('Fetching analytics data from Firestore...');
      final pageVisitsDoc = await _analyticsCollection.doc('page_visits').get();
      final projectViewsDoc =
          await _analyticsCollection.doc('project_views').get();
      final contactSubmissionsDoc =
          await _contactSubmissionsCollection.count().get();

      final Map<String, dynamic> analyticsData = {};

      if (pageVisitsDoc.exists) {
        analyticsData['pageVisits'] = pageVisitsDoc.data();
      }

      if (projectViewsDoc.exists) {
        analyticsData['projectViews'] = projectViewsDoc.data();
      }

      analyticsData['contactSubmissionsCount'] = contactSubmissionsDoc.count;

      return analyticsData;
    } catch (e) {
      debugPrint('Error fetching analytics data: $e');
      rethrow;
    }
  }
}
