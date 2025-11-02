// lib/views/contact/widgets/contact_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../../../viewmodels/contact_viewmodel.dart';

// Consistent purple colors
class FormColors {
  static const Color primaryPurple = Color(0xFF4A00E0);
  static const Color accentPurple = Color(0xFF8E2DE2);
}

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  // Focus nodes for better keyboard handling
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _subjectFocus = FocusNode();
  final _messageFocus = FocusNode();
  
  // Track if form fields have been interacted with
  bool _nameFieldTouched = false;
  bool _emailFieldTouched = false;
  bool _messageFieldTouched = false;

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    
    // Dispose focus nodes
    _nameFocus.dispose();
    _emailFocus.dispose();
    _subjectFocus.dispose();
    _messageFocus.dispose();
    
    super.dispose();
  }

  // Field validation helper methods
  String? _validateName(String? value) {
    if (!_nameFieldTouched) return null;
    
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }
  
  String? _validateEmail(String? value) {
    if (!_emailFieldTouched) return null;
    
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    
    // Trim whitespace
    final trimmedEmail = value.trim();
    
    // Check basic format first (contains @ and .)
    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      return 'Please enter a valid email address';
    }
    
    // Use email_validator package for proper validation
    if (!EmailValidator.validate(trimmedEmail)) {
      return 'Please enter a valid email address (e.g., name@example.com)';
    }
    
    // Additional checks for common mistakes
    if (trimmedEmail.startsWith('@') || trimmedEmail.startsWith('.')) {
      return 'Email cannot start with @ or .';
    }
    
    if (trimmedEmail.endsWith('@') || trimmedEmail.endsWith('.')) {
      return 'Email cannot end with @ or .';
    }
    
    // Check for multiple @ symbols
    if (trimmedEmail.split('@').length > 2) {
      return 'Email can only contain one @ symbol';
    }
    
    return null;
  }
  
  String? _validateMessage(String? value) {
    if (!_messageFieldTouched) return null;
    
    if (value == null || value.isEmpty) {
      return 'Please enter your message';
    }
    
    if (value.length < 10) {
      return 'Message should be at least 10 characters';
    }
    
    return null;
  }

  // Handle field focus changes
  void _onFieldFocusChange(bool hasFocus, String field) {
    if (!hasFocus) {
      setState(() {
        if (field == 'name') _nameFieldTouched = true;
        if (field == 'email') _emailFieldTouched = true;
        if (field == 'message') _messageFieldTouched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactViewModel>(
      builder: (context, viewModel, child) {
        // Show success message if form submitted successfully
        if (viewModel.submissionSuccess) {
          return _buildSuccessMessage(viewModel);
        }

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: FormColors.accentPurple.withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  'Send a Message',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Error message if submission failed
              if (viewModel.submissionError != null)
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel.submissionError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                
              // Enhanced Name field
              Focus(
                onFocusChange: (hasFocus) => _onFieldFocusChange(hasFocus, 'name'),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: FormColors.primaryPurple.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'Enter your full name',
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FormColors.primaryPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: FormColors.primaryPurple,
                          size: 20,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor.withValues(alpha: 0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: FormColors.accentPurple.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: FormColors.accentPurple.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: FormColors.primaryPurple,
                          width: 2.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.5,
                        ),
                      ),
                      labelStyle: const TextStyle(
                        color: FormColors.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                      hintStyle: TextStyle(
                        color: Theme.of(context).hintColor.withValues(alpha: 0.6),
                      ),
                      errorStyle: const TextStyle(
                        height: 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                      errorMaxLines: 2,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocus);
                    },
                    validator: _validateName,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Enhanced Email field
              Focus(
                onFocusChange: (hasFocus) => _onFieldFocusChange(hasFocus, 'email'),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: FormColors.primaryPurple.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    onChanged: (value) {
                      // Real-time validation feedback
                      if (_emailFieldTouched && value.isNotEmpty) {
                        setState(() {
                          // Trigger validation on change
                        });
                        _formKey.currentState?.validate();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Email Address *',
                      hintText: 'Enter your email address',
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FormColors.primaryPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          color: FormColors.primaryPurple,
                          size: 20,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor.withValues(alpha: 0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: FormColors.accentPurple.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: FormColors.accentPurple.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: FormColors.primaryPurple,
                          width: 2.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.5,
                        ),
                      ),
                      labelStyle: const TextStyle(
                        color: FormColors.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                      hintStyle: TextStyle(
                        color: Theme.of(context).hintColor.withValues(alpha: 0.6),
                      ),
                      errorStyle: const TextStyle(
                        height: 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                      errorMaxLines: 2,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_subjectFocus);
                    },
                    validator: _validateEmail,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Enhanced Subject field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: FormColors.primaryPurple.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _subjectController,
                  focusNode: _subjectFocus,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    hintText: 'What is this about?',
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: FormColors.primaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.subject_outlined,
                        color: FormColors.primaryPurple,
                        size: 20,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor.withValues(alpha: 0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: FormColors.accentPurple.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: FormColors.accentPurple.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: FormColors.primaryPurple,
                        width: 2.5,
                      ),
                    ),
                    labelStyle: const TextStyle(
                      color: FormColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                    hintStyle: TextStyle(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_messageFocus);
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Enhanced Message field
              Focus(
                onFocusChange: (hasFocus) => _onFieldFocusChange(hasFocus, 'message'),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: FormColors.primaryPurple.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _messageController,
                    focusNode: _messageFocus,
                    decoration: InputDecoration(
                      labelText: 'Your Message *',
                      hintText: 'Tell me about your project or question...',
                      alignLabelWithHint: true,
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: FormColors.primaryPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.message_outlined,
                          color: FormColors.primaryPurple,
                          size: 20,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor.withValues(alpha: 0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: FormColors.accentPurple.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: FormColors.accentPurple.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: FormColors.primaryPurple,
                          width: 2.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.5,
                        ),
                      ),
                      labelStyle: const TextStyle(
                        color: FormColors.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                      hintStyle: TextStyle(
                        color: Theme.of(context).hintColor.withValues(alpha: 0.6),
                      ),
                      errorStyle: const TextStyle(
                        height: 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                      errorMaxLines: 2,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    ),
                    maxLines: 6,
                    textInputAction: TextInputAction.done,
                    validator: _validateMessage,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Enhanced Submit button
              Center(
                child: Container(
                  width: 240,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        FormColors.primaryPurple,
                        FormColors.accentPurple,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: FormColors.primaryPurple.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: viewModel.isSubmitting ? null : () => _submitForm(viewModel),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (viewModel.isSubmitting) ...[
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Sending...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ] else ...[
                              const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Send Message',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuccessMessage(ContactViewModel viewModel) {
  return Center(  // Added Center widget here
    child: Container(
      constraints: const BoxConstraints(maxWidth: 500),  // Optional: constrain max width
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Message Sent Successfully!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.green,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thank you for reaching out. I will get back to you as soon as possible.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              viewModel.resetFormState();
              _nameController.clear();
              _emailController.clear();
              _subjectController.clear();
              _messageController.clear();
              
              // Reset field touched states
              setState(() {
                _nameFieldTouched = false;
                _emailFieldTouched = false;
                _messageFieldTouched = false;
              });
            },
            child: const Text('Send Another Message'),
          ),
        ],
      ),
    ),
  );
}

  void _submitForm(ContactViewModel viewModel) {
    // Mark all fields as touched to trigger validation
    setState(() {
      _nameFieldTouched = true;
      _emailFieldTouched = true;
      _messageFieldTouched = true;
    });
    
    if (_formKey.currentState!.validate()) {
      // Hide keyboard
      FocusScope.of(context).unfocus();
      
      // Trim and normalize form values before submission
      final name = _nameController.text.trim();
      final email = _emailController.text.trim().toLowerCase();
      final subject = _subjectController.text.trim();
      final message = _messageController.text.trim();
      
      viewModel.submitContactForm(
        name: name,
        email: email,
        subject: subject,
        message: message,
      );
    }
  }
}