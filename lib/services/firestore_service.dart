// lib/services/firestore_service.dart
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
      print('Fetching projects from Firestore...');
      final QuerySnapshot snapshot =
          await _projectsCollection.orderBy('order', descending: false).get();

      print('Retrieved ${snapshot.docs.length} projects from Firestore');
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
      print('Error fetching projects: $e');
      rethrow;
    }
  }

// Add a new project - Updated to handle screenshots
  Future<DocumentReference> addProject(Map<String, dynamic> projectData) async {
    try {
      print('Adding new project: ${projectData['title']}');
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
      print('Project added successfully');
      return docRef;
    } catch (e) {
      print('Error adding project: $e');
      rethrow;
    }
  }

// Update an existing project - Updated to handle screenshots
  Future<void> updateProject(
      String projectId, Map<String, dynamic> projectData) async {
    try {
      print('Updating project: $projectId');
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
      print('Project updated successfully');
    } catch (e) {
      print('Error updating project: $e');
      rethrow;
    }
  }

  // Delete a project
  Future<void> deleteProject(String projectId) async {
    try {
      print('Deleting project: $projectId');
      await _projectsCollection.doc(projectId).delete();

      // Re-order remaining projects
      await _updateProjectsOrder();
      print('Project deleted successfully');
    } catch (e) {
      print('Error deleting project: $e');
      rethrow;
    }
  }

  // Reorder projects
  Future<void> reorderProjects(int oldIndex, int newIndex) async {
    try {
      print('Reordering projects from $oldIndex to $newIndex');
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
          batch.update(movedProject.reference,
              {'order': i, 'updatedAt': FieldValue.serverTimestamp()});
        } else if (oldIndex < newIndex && i > oldIndex && i <= newIndex) {
          // Projects that need to move up
          batch.update(doc.reference,
              {'order': i - 1, 'updatedAt': FieldValue.serverTimestamp()});
        } else if (oldIndex > newIndex && i >= newIndex && i < oldIndex) {
          // Projects that need to move down
          batch.update(doc.reference,
              {'order': i + 1, 'updatedAt': FieldValue.serverTimestamp()});
        }
      }

      await batch.commit();
      print('Projects reordered successfully');
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
        batch.update(docs[i].reference,
            {'order': i, 'updatedAt': FieldValue.serverTimestamp()});
      }

      await batch.commit();
      print('Project order updated successfully');
    } catch (e) {
      print('Error updating project order: $e');
      rethrow;
    }
  }

  // =================== Services Management ===================

  // Get all services
  Future<List<Service>> getServices() async {
    try {
      print('Fetching services from Firestore...');
      final QuerySnapshot snapshot =
          await _servicesCollection.orderBy('order', descending: false).get();

      print('Retrieved ${snapshot.docs.length} services from Firestore');
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return Service(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          iconPath:
              data['iconName'] ?? '', // Using icon name from Material Icons
        );
      }).toList();
    } catch (e) {
      print('Error fetching services: $e');
      rethrow;
    }
  }

  // Add a new service
  Future<DocumentReference> addService(Map<String, dynamic> serviceData) async {
    try {
      print('Adding new service: ${serviceData['title']}');
      // Get the current number of services for ordering
      final QuerySnapshot snapshot = await _servicesCollection.get();
      final int order = snapshot.size; // New service will be at the end

      // Add order field
      serviceData['order'] = order;

      // Add creation timestamp
      serviceData['createdAt'] = FieldValue.serverTimestamp();
      serviceData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _servicesCollection.add(serviceData);
      print('Service added successfully');
      return docRef;
    } catch (e) {
      print('Error adding service: $e');
      rethrow;
    }
  }

  // Update an existing service
  Future<void> updateService(
      String serviceId, Map<String, dynamic> serviceData) async {
    try {
      print('Updating service: $serviceId');
      // Add update timestamp
      serviceData['updatedAt'] = FieldValue.serverTimestamp();

      await _servicesCollection.doc(serviceId).update(serviceData);
      print('Service updated successfully');
    } catch (e) {
      print('Error updating service: $e');
      rethrow;
    }
  }

  // Delete a service
  Future<void> deleteService(String serviceId) async {
    try {
      print('Deleting service: $serviceId');
      await _servicesCollection.doc(serviceId).delete();

      // Re-order remaining services
      await _updateServicesOrder();
      print('Service deleted successfully');
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
        batch.update(docs[i].reference,
            {'order': i, 'updatedAt': FieldValue.serverTimestamp()});
      }

      await batch.commit();
      print('Service order updated successfully');
    } catch (e) {
      print('Error updating service order: $e');
      rethrow;
    }
  }

  // =================== Profile Management ===================

  // Get personal information
  Future<Map<String, dynamic>> getPersonalInfo() async {
    try {
      print('Fetching personal info from Firestore...');
      final DocumentSnapshot doc =
          await _configCollection.doc('personal_info').get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print(
            'Successfully loaded personal info from Firestore: ${data['title']}');
        return data;
      }

      print('No personal_info document found in Firestore');
      return {};
    } catch (e) {
      print('Error fetching personal info from Firestore: $e');
      rethrow;
    }
  }

  // Update personal information
  Future<void> updatePersonalInfo(Map<String, dynamic> personalData) async {
    try {
      print('Updating personal info in Firestore...');
      // Add update timestamp
      personalData['updatedAt'] = FieldValue.serverTimestamp();

      await _configCollection
          .doc('personal_info')
          .set(personalData, SetOptions(merge: true));
      print('Personal info updated successfully');
    } catch (e) {
      print('Error updating personal info: $e');
      rethrow;
    }
  }

  // Get social links
  Future<Map<String, dynamic>> getSocialLinks() async {
    try {
      print('Fetching social links from Firestore...');
      final DocumentSnapshot doc =
          await _configCollection.doc('social_links').get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }

      print('No social_links document found in Firestore');
      return {};
    } catch (e) {
      print('Error fetching social links: $e');
      rethrow;
    }
  }

  // Update social links
  Future<void> updateSocialLinks(Map<String, dynamic> socialData) async {
    try {
      print('Updating social links in Firestore...');
      // Add update timestamp
      socialData['updatedAt'] = FieldValue.serverTimestamp();

      await _configCollection
          .doc('social_links')
          .set(socialData, SetOptions(merge: true));
      print('Social links updated successfully');
    } catch (e) {
      print('Error updating social links: $e');
      rethrow;
    }
  }

  // =================== Contact Form Submissions ===================

  // Submit contact form
  Future<bool> submitContactForm(Map<String, dynamic> formData) async {
    try {
      print('Submitting contact form to Firestore...');
      await _contactSubmissionsCollection.add({
        ...formData,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Contact form submitted successfully');
      return true;
    } catch (e) {
      print('Error submitting contact form: $e');
      return false;
    }
  }

  // Get contact submissions (for admin view)
  Future<List<Map<String, dynamic>>> getContactSubmissions() async {
    try {
      print('Fetching contact submissions from Firestore...');
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
      print('Error fetching contact submissions: $e');
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
      print('Fetching analytics data from Firestore...');
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
      print('Error fetching analytics data: $e');
      rethrow;
    }
  }
}
