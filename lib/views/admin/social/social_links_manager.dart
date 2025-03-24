// lib/views/admin/social/social_links_manager.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio_website/config/app_config.dart';
import 'package:portfolio_website/services/firestore_service.dart';
import 'package:portfolio_website/main.dart';
import 'package:portfolio_website/viewmodels/activity_viewmodel.dart';
import 'package:provider/provider.dart';

class SocialLinksManagerScreen extends StatefulWidget {
  const SocialLinksManagerScreen({Key? key}) : super(key: key);

  @override
  State<SocialLinksManagerScreen> createState() => _SocialLinksManagerScreenState();
}

class _SocialLinksManagerScreenState extends State<SocialLinksManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _fiverrController = TextEditingController();
  final _upworkController = TextEditingController();
  final _freelancerController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  
  @override
  void initState() {
    super.initState();
    _loadSocialLinks();
  }
  
  @override
  void dispose() {
    _fiverrController.dispose();
    _upworkController.dispose();
    _freelancerController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  // Load current social links
  Future<void> _loadSocialLinks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // First try to load from Firestore
      final firestoreService = FirestoreService.instance;
      final socialLinks = await firestoreService.getSocialLinks();
      
      if (socialLinks.isNotEmpty) {
        // Load from Firestore if available
        setState(() {
          _fiverrController.text = socialLinks['fiverr'] ?? AppConfig.socialLinks.fiverr;
          _upworkController.text = socialLinks['upwork'] ?? AppConfig.socialLinks.upwork;
          _freelancerController.text = socialLinks['freelancer'] ?? AppConfig.socialLinks.freelancer;
          _instagramController.text = socialLinks['instagram'] ?? AppConfig.socialLinks.instagram;
          _facebookController.text = socialLinks['facebook'] ?? AppConfig.socialLinks.facebook;
          _githubController.text = socialLinks['github'] ?? AppConfig.socialLinks.github;
          _linkedinController.text = socialLinks['linkedin'] ?? AppConfig.socialLinks.linkedin;
        });
      } else {
        // Fallback to AppConfig
        setState(() {
          _fiverrController.text = AppConfig.socialLinks.fiverr;
          _upworkController.text = AppConfig.socialLinks.upwork;
          _freelancerController.text = AppConfig.socialLinks.freelancer;
          _instagramController.text = AppConfig.socialLinks.instagram;
          _facebookController.text = AppConfig.socialLinks.facebook;
          _githubController.text = AppConfig.socialLinks.github;
          _linkedinController.text = AppConfig.socialLinks.linkedin;
        });
      }
    } catch (e) {
      // If there's an error, fall back to AppConfig
      setState(() {
        _errorMessage = 'Failed to load social links: ${e.toString()}';
        _fiverrController.text = AppConfig.socialLinks.fiverr;
        _upworkController.text = AppConfig.socialLinks.upwork;
        _freelancerController.text = AppConfig.socialLinks.freelancer;
        _instagramController.text = AppConfig.socialLinks.instagram;
        _facebookController.text = AppConfig.socialLinks.facebook;
        _githubController.text = AppConfig.socialLinks.github;
        _linkedinController.text = AppConfig.socialLinks.linkedin;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Validate URL
  String? _validateUrl(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'Please enter a URL' : null;
    }
    
    final urlRegExp = RegExp(
      r'^(https?:\/\/)?' + // protocol
      r'((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|' + // domain name
      r'((\d{1,3}\.){3}\d{1,3}))' + // OR ip (v4) address
      r'(\:\d+)?(\/[-a-z\d%_.~+]*)*' + // port and path
      r'(\?[;&a-z\d%_.~+=-]*)?' + // query string
      r'(\#[-a-z\d_]*)?$', // fragment locator
      caseSensitive: false,
    );
    
    if (!urlRegExp.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  // Test a social link
  void _testLink(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a URL first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final urlToTest = url.startsWith('http') ? url : 'https://$url';
    
    try {
      await launchURL(urlToTest);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open URL: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Save social links
  Future<void> _saveSocialLinks() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    try {
      final socialLinks = {
        'fiverr': _fiverrController.text,
        'upwork': _upworkController.text,
        'freelancer': _freelancerController.text,
        'instagram': _instagramController.text,
        'facebook': _facebookController.text,
        'github': _githubController.text,
        'linkedin': _linkedinController.text,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      final firestoreService = FirestoreService.instance;
      await firestoreService.updateSocialLinks(socialLinks);

      // Log the activity 
      final activityViewModel = Provider.of<ActivityViewModel>(context, listen: false);
      await activityViewModel.logActivity(
        type: 'edit',
        message: 'You updated your social media links',
        entityId: 'social_links',
        metadata: {
          'github': _githubController.text.isNotEmpty,
          'linkedin': _linkedinController.text.isNotEmpty,
          'fiverr': _fiverrController.text.isNotEmpty,
          'upwork': _upworkController.text.isNotEmpty
        },
      );
      
      setState(() {
        _successMessage = 'Social links updated successfully!';
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
        _errorMessage = 'Failed to save social links: ${e.toString()}';
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
              'Social Links Manager',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add or update your social media and professional profiles',
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
            
            // Social links form
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Freelancing platforms card
                          Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Freelancing Platforms',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Fiverr field
                                  _buildSocialLinkField(
                                    controller: _fiverrController,
                                    label: 'Fiverr',
                                    hint: 'https://fiverr.com/yourusername',
                                    icon: FontAwesomeIcons.icons,
                                    color: const Color(0xFF1DBF73),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Upwork field
                                  _buildSocialLinkField(
                                    controller: _upworkController,
                                    label: 'Upwork',
                                    hint: 'https://upwork.com/yourusername',
                                    icon: FontAwesomeIcons.upwork,
                                    color: const Color(0xFF6FDA44),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Freelancer field
                                  _buildSocialLinkField(
                                    controller: _freelancerController,
                                    label: 'Freelancer',
                                    hint: 'https://freelancer.com/yourusername',
                                    icon: FontAwesomeIcons.adversal,
                                    color: const Color(0xFF29B2FE),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Social Media card
                          Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Social Media',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Instagram field
                                  _buildSocialLinkField(
                                    controller: _instagramController,
                                    label: 'Instagram',
                                    hint: 'https://instagram.com/yourusername',
                                    icon: FontAwesomeIcons.instagram,
                                    color: const Color(0xFFE1306C),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Facebook field
                                  _buildSocialLinkField(
                                    controller: _facebookController,
                                    label: 'Facebook',
                                    hint: 'https://facebook.com/yourusername',
                                    icon: FontAwesomeIcons.facebook,
                                    color: const Color(0xFF1877F2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Professional Networks card
                          Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 24),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Professional Networks',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // GitHub field
                                  _buildSocialLinkField(
                                    controller: _githubController,
                                    label: 'GitHub',
                                    hint: 'https://github.com/yourusername',
                                    icon: FontAwesomeIcons.github,
                                    color: const Color(0xFF333333),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // LinkedIn field
                                  _buildSocialLinkField(
                                    controller: _linkedinController,
                                    label: 'LinkedIn',
                                    hint: 'https://linkedin.com/in/yourusername',
                                    icon: FontAwesomeIcons.linkedin,
                                    color: const Color(0xFF0077B5),
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
                                onPressed: _isSaving ? null : _saveSocialLinks,
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
  
  // Helper method to build social link field with icon and test button
  Widget _buildSocialLinkField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(top: 8, right: 12),
          decoration: BoxDecoration(
            color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(
              icon,
              color: color ?? Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
        ),
        
        // Text field
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
            ),
            validator: (value) => _validateUrl(value),
          ),
        ),
        
        // Test button
        IconButton(
          icon: const Icon(Icons.open_in_new),
          tooltip: 'Test Link',
          onPressed: () => _testLink(controller.text),
          padding: const EdgeInsets.only(top: 12),
        ),
      ],
    );
  }
}