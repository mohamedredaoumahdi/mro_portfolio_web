// lib/views/contact/contact_section.dart
// Update the imports section to include SocialLinksViewModel
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio_website/config/app_config.dart';
import 'package:portfolio_website/viewmodels/profile_viewmodel.dart';
import 'package:portfolio_website/viewmodels/social_links_viewmodel.dart'; // Add this import
import 'package:provider/provider.dart';

import '../../widgets/responsive_wrapper.dart';
import '../../viewmodels/contact_viewmodel.dart';
import 'widgets/social_button.dart';
import 'widgets/contact_form.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContactViewModel()),
        ChangeNotifierProvider(create: (_) => SocialLinksViewModel()..initialize()), // Add this provider
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 80),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        ),
        child: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get in Touch',
                style: context.responsive<TextStyle>(
                  mobile: Theme.of(context).textTheme.headlineSmall!,
                  tablet: Theme.of(context).textTheme.headlineMedium!,
                  desktop: Theme.of(context).textTheme.headlineLarge!,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Interested in working together? Reach out through the form or any of these platforms',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 60),
              
              // Contact Form Section
              const ContactForm(),
              
              const SizedBox(height: 80),
              
              // Footer style sections
              _buildFooterSections(context),
              
              const SizedBox(height: 40),
              
              // Copyright
              Center(
                child: Text(
                  '© ${DateTime.now().year} ${AppConfig.name}. All rights reserved.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFooterSections(BuildContext context) {
    return Column(
      children: [
        // Divider
        Container(
          height: 1,
          color: Theme.of(context).dividerColor,
          margin: const EdgeInsets.only(bottom: 40),
        ),
        
        // Footer sections in responsive layout
        ResponsiveWrapper(
          mobile: _buildFooterSectionsMobile(context),
          desktop: _buildFooterSectionsDesktop(context),
        ),
      ],
    );
  }
  
  Widget _buildFooterSectionsMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContactInfo(context),
        const SizedBox(height: 40),
        _buildSocialLinks(context),
        const SizedBox(height: 40),
        _buildHireMeLinks(context),
      ],
    );
  }
  
  Widget _buildFooterSectionsDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact Info
        Expanded(
          flex: 1,
          child: _buildContactInfo(context),
        ),
        const SizedBox(width: 40),
        // Follow Me
        Expanded(
          flex: 1,
          child: _buildSocialLinks(context),
        ),
        const SizedBox(width: 40),
        // Hire Me On
        Expanded(
          flex: 1,
          child: _buildHireMeLinks(context),
        ),
      ],
    );
  }
  
  Widget _buildContactInfo(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        _buildContactItem(
          context,
          Icons.email,
          'Email',
          profileViewModel.email,
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          context,
          Icons.phone,
          'Phone',
          profileViewModel.phone,
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          context,
          Icons.location_on,
          'Location',
          profileViewModel.location,
        ),
      ],
    );
  }
  
  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ],
    );
  }
  
  // Update the _buildSocialLinks method in lib/views/contact/contact_section.dart

Widget _buildSocialLinks(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Follow Me',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          SocialButton(
            icon: FontAwesomeIcons.facebook,
            url: AppConfig.socialLinks.facebook, // Fallback URL
            label: 'Facebook',
            linkId: 'facebook', // Added linkId parameter
          ),
          SocialButton(
            icon: FontAwesomeIcons.instagram,
            url: AppConfig.socialLinks.instagram, // Fallback URL
            label: 'Instagram',
            linkId: 'instagram', // Added linkId parameter
          ),
          SocialButton(
            icon: FontAwesomeIcons.github,
            url: AppConfig.socialLinks.github, // Fallback URL
            label: 'GitHub',
            linkId: 'github', // Added linkId parameter
          ),
          SocialButton(
            icon: FontAwesomeIcons.linkedin,
            url: AppConfig.socialLinks.linkedin, // Fallback URL
            label: 'LinkedIn',
            linkId: 'linkedin', // Added linkId parameter
          ),
        ],
      ),
    ],
  );
}

Widget _buildHireMeLinks(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Hire Me On',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          SocialButton(
            icon: FontAwesomeIcons.icons,
            url: AppConfig.socialLinks.fiverr, // Fallback URL
            label: 'Fiverr',
            color: const Color(0xFF1DBF73),
            linkId: 'fiverr', // Added linkId parameter
          ),
          SocialButton(
            icon: FontAwesomeIcons.upwork,
            url: AppConfig.socialLinks.upwork, // Fallback URL
            label: 'Upwork',
            color: const Color(0xFF6FDA44),
            linkId: 'upwork', // Added linkId parameter
          ),
          SocialButton(
            icon: FontAwesomeIcons.adversal,
            url: AppConfig.socialLinks.freelancer, // Fallback URL
            label: 'Freelancer',
            color: const Color(0xFF29B2FE),
            linkId: 'freelancer', // Added linkId parameter
          ),
        ],
      ),
    ],
  );
}
}