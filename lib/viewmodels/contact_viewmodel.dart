// lib/viewmodels/contact_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:portfolio_website/services/activity_service.dart';
import 'package:portfolio_website/services/firebase_service.dart';

class ContactViewModel extends ChangeNotifier {
  bool _isSubmitting = false;
  String? _submissionError;
  bool _submissionSuccess = false;

  // Getters
  bool get isSubmitting => _isSubmitting;
  String? get submissionError => _submissionError;
  bool get submissionSuccess => _submissionSuccess;

  // Check if Firebase is available
  bool get _isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Reset form state
  void resetFormState() {
    _isSubmitting = false;
    _submissionError = null;
    _submissionSuccess = false;
    notifyListeners();
  }

  // Submit contact form
  Future<bool> submitContactForm({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      _isSubmitting = true;
      _submissionError = null;
      _submissionSuccess = false;
      notifyListeners();

      // Basic validation
      if (name.isEmpty || email.isEmpty || message.isEmpty) {
        _submissionError = 'Please fill in all required fields';
        _isSubmitting = false;
        notifyListeners();
        return false;
      }

      // Email validation
      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegExp.hasMatch(email)) {
        _submissionError = 'Please enter a valid email address';
        _isSubmitting = false;
        notifyListeners();
        return false;
      }

      // Use Firebase if available
      if (_isFirebaseAvailable) {
        try {
          // Try to submit form to Firebase with a timeout
          final result = await FirebaseService.instance.submitContactForm({
            'name': name,
            'email': email,
            'subject': subject,
            'message': message,
          }).timeout(const Duration(seconds: 5));
          
          _isSubmitting = false;
          if (result) {
            _submissionSuccess = true;
            // Log activity for the contact submission
            final activityService = ActivityService.instance;
            final docId = 'contact_${DateTime.now().millisecondsSinceEpoch}';
            await activityService.logContactSubmission(docId, name);
            notifyListeners();
            return true;
          } else {
            // Firebase submission returned false
            _submissionError = 'Failed to submit the form. Please try again later.';
            notifyListeners();
            return false;
          }
        } catch (e) {
          print('Error submitting to Firebase: $e - Using fallback');
          // If Firebase fails, simulate successful submission in development mode
          if (kDebugMode) {
            _isSubmitting = false;
            _submissionSuccess = true;
            notifyListeners();
            return true;
          } else {
            _submissionError = 'Failed to submit form. Please try contacting through email directly.';
            _isSubmitting = false;
            notifyListeners();
            return false;
          }
        }
      } else {
        // Firebase not available, use fallback approach
        // In development mode, simulate successful submission
        if (kDebugMode) {
          // Simulate network delay
          await Future.delayed(const Duration(seconds: 1));
          _isSubmitting = false;
          _submissionSuccess = true;
          notifyListeners();
          return true;
        } else {
          _submissionError = 'Contact form submission is temporarily unavailable. Please use email instead.';
          _isSubmitting = false;
          notifyListeners();
          return false;
        }
      }
    } catch (e) {
      _isSubmitting = false;
      _submissionError = 'An error occurred: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}