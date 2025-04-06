// lib/views/contact/widgets/contact_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/contact_viewmodel.dart';

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
    
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
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
              Text(
                'Send a Message',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              
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
                
              // Name field
              Focus(
                onFocusChange: (hasFocus) => _onFieldFocusChange(hasFocus, 'name'),
                child: TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(
                    labelText: 'Name *',
                    hintText: 'Enter your name',
                    prefixIcon: const Icon(Icons.person),
                    errorStyle: const TextStyle(height: 0.7),
                    errorMaxLines: 2,
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_emailFocus);
                  },
                  validator: _validateName,
                ),
              ),
              const SizedBox(height: 16),
              
              // Email field
              Focus(
                onFocusChange: (hasFocus) => _onFieldFocusChange(hasFocus, 'email'),
                child: TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  decoration: InputDecoration(
                    labelText: 'Email *',
                    hintText: 'Enter your email address',
                    prefixIcon: const Icon(Icons.email),
                    errorStyle: const TextStyle(height: 0.7),
                    errorMaxLines: 2,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_subjectFocus);
                  },
                  validator: _validateEmail,
                ),
              ),
              const SizedBox(height: 16),
              
              // Subject field
              TextFormField(
                controller: _subjectController,
                focusNode: _subjectFocus,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'What is this about?',
                  prefixIcon: Icon(Icons.subject),
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_messageFocus);
                },
              ),
              const SizedBox(height: 16),
              
              // Message field
              Focus(
                onFocusChange: (hasFocus) => _onFieldFocusChange(hasFocus, 'message'),
                child: TextFormField(
                  controller: _messageController,
                  focusNode: _messageFocus,
                  decoration: InputDecoration(
                    labelText: 'Message *',
                    hintText: 'Enter your message',
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.message),
                    errorStyle: const TextStyle(height: 0.7),
                    errorMaxLines: 2,
                  ),
                  maxLines: 5,
                  textInputAction: TextInputAction.done,
                  validator: _validateMessage,
                ),
              ),
              const SizedBox(height: 24),
              
              // Submit button
              Center(
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: viewModel.isSubmitting
                        ? null
                        : () => _submitForm(viewModel),
                    child: viewModel.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Send Message',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
    return Container(
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
      
      viewModel.submitContactForm(
        name: _nameController.text,
        email: _emailController.text,
        subject: _subjectController.text,
        message: _messageController.text,
      );
    }
  }
}