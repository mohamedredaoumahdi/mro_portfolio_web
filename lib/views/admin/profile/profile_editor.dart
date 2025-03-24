// lib/views/admin/profile/profile_editor.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:portfolio_website/config/app_config.dart';
import 'package:portfolio_website/services/firestore_service.dart';
import 'package:portfolio_website/viewmodels/activity_viewmodel.dart';
import 'package:provider/provider.dart';

class ProfileEditorScreen extends StatefulWidget {
  const ProfileEditorScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _initialsController = TextEditingController();
  final _titleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _aboutMeController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _initialsController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  // Load current profile data
  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // First try to load from Firestore
      final firestoreService = FirestoreService.instance;
      final personalInfo = await firestoreService.getPersonalInfo();
      
      if (personalInfo.isNotEmpty) {
        // Load from Firestore if available
        setState(() {
          _nameController.text = personalInfo['name'] ?? AppConfig.name;
          _initialsController.text = personalInfo['initials'] ?? AppConfig.initials;
          _titleController.text = personalInfo['title'] ?? AppConfig.title;
          _emailController.text = personalInfo['email'] ?? AppConfig.email;
          _phoneController.text = personalInfo['phone'] ?? AppConfig.phone;
          _locationController.text = personalInfo['location'] ?? AppConfig.location;
          _aboutMeController.text = personalInfo['aboutMe'] ?? AppConfig.aboutMe;
        });
      } else {
        // Fallback to AppConfig
        setState(() {
          _nameController.text = AppConfig.name;
          _initialsController.text = AppConfig.initials;
          _titleController.text = AppConfig.title;
          _emailController.text = AppConfig.email;
          _phoneController.text = AppConfig.phone;
          _locationController.text = AppConfig.location;
          _aboutMeController.text = AppConfig.aboutMe;
        });
      }
    } catch (e) {
      // If there's an error, fall back to AppConfig
      setState(() {
        _errorMessage = 'Failed to load profile data: ${e.toString()}';
        _nameController.text = AppConfig.name;
        _initialsController.text = AppConfig.initials;
        _titleController.text = AppConfig.title;
        _emailController.text = AppConfig.email;
        _phoneController.text = AppConfig.phone;
        _locationController.text = AppConfig.location;
        _aboutMeController.text = AppConfig.aboutMe;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save profile data
  Future<void> _saveProfileData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    try {
      final personalInfo = {
        'name': _nameController.text,
        'initials': _initialsController.text,
        'title': _titleController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'location': _locationController.text,
        'aboutMe': _aboutMeController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      final firestoreService = FirestoreService.instance;
      await firestoreService.updatePersonalInfo(personalInfo);
      
      // Log the activity
      final activityViewModel = Provider.of<ActivityViewModel>(context, listen: false);
      await activityViewModel.logActivity(
        type: 'edit',
        message: 'You updated your personal profile information',
        entityId: 'personal_info',
        metadata: {'title': _titleController.text, 'name': _nameController.text},
      );

      setState(() {
        _successMessage = 'Profile updated successfully!';
        _isSaving = false;
      });
      
      // Clear success message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _successMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save profile data: ${e.toString()}';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Editor',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Update your personal information displayed on your portfolio',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            
            // Success message
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            
            // Profile form
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Basic information card
                          Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Basic Information',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Name and Initials row
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          controller: _nameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Full Name',
                                            hintText: 'Enter your full name',
                                            prefixIcon: Icon(Icons.person),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter your name';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 1,
                                        child: TextFormField(
                                          controller: _initialsController,
                                          decoration: const InputDecoration(
                                            labelText: 'Initials',
                                            hintText: 'e.g. MRO',
                                            prefixIcon: Icon(Icons.short_text),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter initials';
                                            }
                                            return null;
                                          },
                                          maxLength: 3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Professional title
                                  TextFormField(
                                    controller: _titleController,
                                    decoration: const InputDecoration(
                                      labelText: 'Professional Title',
                                      hintText: 'e.g. Mobile App Developer',
                                      prefixIcon: Icon(Icons.work),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your title';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Contact information card
                          Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Contact Information',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Email field
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'Enter your email address',
                                      prefixIcon: Icon(Icons.email),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                      if (!emailRegExp.hasMatch(value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Phone field
                                  TextFormField(
                                    controller: _phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone',
                                      hintText: 'Enter your phone number',
                                      prefixIcon: Icon(Icons.phone),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Location field
                                  TextFormField(
                                    controller: _locationController,
                                    decoration: const InputDecoration(
                                      labelText: 'Location',
                                      hintText: 'e.g. City, Country',
                                      prefixIcon: Icon(Icons.location_on),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your location';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // About Me card
                          Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'About Me',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Write a short professional description about yourself',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // About Me text field
                                  TextFormField(
                                    controller: _aboutMeController,
                                    decoration: const InputDecoration(
                                      hintText: 'Describe your skills, experience, and expertise...',
                                      border: OutlineInputBorder(),
                                      alignLabelWithHint: true,
                                    ),
                                    maxLines: 6,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your about me text';
                                      }
                                      if (value.length < 50) {
                                        return 'About me should be at least 50 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Recommended: 150-300 characters',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Save button
                          Center(
                            child: SizedBox(
                              width: 200,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveProfileData,
                                child: _isSaving
                                  ? const CircularProgressIndicator()
                                  : const Text('Save Changes'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}