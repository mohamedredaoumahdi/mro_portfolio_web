// lib/viewmodels/contact_viewmodel.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:portfolio_website/services/activity_service.dart';
import 'package:portfolio_website/services/firestore_service.dart';

class ContactViewModel extends ChangeNotifier {
  bool _isSubmitting = false;
  String? _submissionError;
  bool _submissionSuccess = false;
  int _retryCount = 0;
  final int _maxRetries = 2;

  // Getters
  bool get isSubmitting => _isSubmitting;
  String? get submissionError => _submissionError;
  bool get submissionSuccess => _submissionSuccess;

  // Check if Firebase is available with caching
  bool? _cachedFirebaseStatus;
  bool get _isFirebaseAvailable {
    if (_cachedFirebaseStatus != null) {
      return _cachedFirebaseStatus!;
    }
    
    try {
      _cachedFirebaseStatus = Firebase.apps.isNotEmpty;
      return _cachedFirebaseStatus!;
    } catch (e) {
      _cachedFirebaseStatus = false;
      debugPrint('Firebase availability check error: $e');
      return false;
    }
  }

  // Reset form state
  void resetFormState() {
    _isSubmitting = false;
    _submissionError = null;
    _submissionSuccess = false;
    _retryCount = 0;
    notifyListeners();
  }

  // Submit contact form with retry logic
  Future<bool> submitContactForm({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    if (_isSubmitting) return false; // Prevent concurrent submissions
    
    try {
      _isSubmitting = true;
      _submissionError = null;
      _submissionSuccess = false;
      notifyListeners();

      // Validate input
      final validationError = _validateInput(name, email, message);
      if (validationError != null) {
        _setError(validationError);
        return false;
      }

      // Create form data object
      final formData = {
        'name': name,
        'email': email,
        'subject': subject.isEmpty ? 'Contact Form Submission' : subject,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Try to submit via Firebase with timeout
      if (_isFirebaseAvailable) {
        return await _submitViaFirebase(formData, name);
      } else {
        return await _simulateSubmission(formData, name);
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    }
  }
  
  // Validate all inputs
  String? _validateInput(String name, String email, String message) {
    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      return 'Please fill in all required fields';
    }
    
    // Minimum length checks
    if (name.length < 2) {
      return 'Name is too short';
    }
    
    if (message.length < 10) {
      return 'Message is too short (minimum 10 characters)';
    }
    
    // Email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  // Submit form via Firebase
  Future<bool> _submitViaFirebase(Map<String, dynamic> formData, String name) async {
    try {
      // Try to submit form to Firestore with a timeout
      final result = await FirestoreService.instance.submitContactForm(formData)
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Firestore submission timed out');
      });
      
      if (result) {
        _setSuccess();
        
        // Log activity for the contact submission
        final activityService = ActivityService.instance;
        final docId = 'contact_${DateTime.now().millisecondsSinceEpoch}';
        await activityService.logContactSubmission(docId, name);
        
        return true;
      } else {
        // Firebase submission returned false
        return _handleFailure('Failed to submit the form. Please try again later.');
      }
    } catch (e) {
      debugPrint('Error submitting to Firebase: $e');
      
      // Try to retry submission
      if (_retryCount < _maxRetries) {
        _retryCount++;
        debugPrint('Retrying submission (attempt $_retryCount of $_maxRetries)');
        await Future.delayed(const Duration(seconds: 2)); // Wait before retry
        return _submitViaFirebase(formData, name);
      }
      
      // If Firebase fails after retries, use fallback in development mode
      if (kDebugMode) {
        return _simulateSubmission(formData, name);
      } else {
        return _handleFailure('Connection error. Please try contacting through email directly.');
      }
    }
  }
  
  // Simulate successful submission (for development or fallback)
  Future<bool> _simulateSubmission(Map<String, dynamic> formData, String name) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      _setSuccess();
      
      // Even if Firebase is unavailable, try to log locally
      if (kDebugMode) {
        debugPrint('FORM SUBMISSION (Simulated): $formData');
      }
      
      return true;
    } catch (e) {
      return _handleFailure('An error occurred: ${e.toString()}');
    }
  }
  
  // Set successful state
  void _setSuccess() {
    _isSubmitting = false;
    _submissionSuccess = true;
    _submissionError = null;
    notifyListeners();
  }
  
  // Set error state
  void _setError(String errorMessage) {
    _isSubmitting = false;
    _submissionError = errorMessage;
    notifyListeners();
  }
  
  // Handle submission failure
  Future<bool> _handleFailure(String errorMessage) async {
    _setError(errorMessage);
    return false;
  }
}