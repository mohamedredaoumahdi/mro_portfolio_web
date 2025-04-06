import 'package:flutter/material.dart';
import 'package:portfolio_website/config/app_config.dart';
import 'package:portfolio_website/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../widgets/responsive_wrapper.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/service_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../theme/app_theme.dart';
import '../services/services_section.dart';
import '../projects/projects_section.dart';
import '../contact/contact_section.dart';
import 'widgets/code_animation.dart';
import 'widgets/nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(4, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    
    // Force profile data refresh after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
        profileViewModel.loadPersonalInfo();
        print("FORCE REFRESH: Explicitly loading profile data in initState");
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(int index) {
    final context = _sectionKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutQuart,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current theme mode
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final isDarkMode = themeViewModel.isDarkMode;
    
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Manual refresh button for testing
          Provider.of<ProfileViewModel>(context, listen: false).loadPersonalInfo();
          setState(() {}); // Force UI update
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Refreshing profile data...'))
          );
        },
        child: const Icon(Icons.refresh),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
            expandedHeight: 60,
            centerTitle: false,
            flexibleSpace: NavBar(
              onNavItemTapped: _scrollToSection,
            ),
          ),
          
          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              key: _sectionKeys[0],
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.getBackgroundGradient(isDarkMode: isDarkMode),
              ),
              child: ResponsiveContainer(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 900),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                        const SizedBox(height: 40),
                        
                        // Only show side-by-side layout on larger screens
                        if (context.isMobile) ...[
                          _buildHeroContent(context),
                        ] else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildHeroContent(context),
                              ),
                              const Expanded(
                                flex: 2,
                                child: CodeAnimation(),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Services Section
          SliverToBoxAdapter(
            child: Container(
              key: _sectionKeys[1],
              child: const ServicesSection(),
            ),
          ),
          
          // Projects Section
          SliverToBoxAdapter(
            child: Container(
              key: _sectionKeys[2],
              child: const ProjectsSection(),
            ),
          ),
          
          // Contact Section
          SliverToBoxAdapter(
            child: Container(
              key: _sectionKeys[3],
              child: const ContactSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroContent(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, profileViewModel, _) {
        // Debug print to verify data
        print("HERO CONTENT BUILD: Using title '${profileViewModel.title}'");
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '< Hello World />',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "I'm ${profileViewModel.name}",
              style: context.responsive<TextStyle>(
                mobile: Theme.of(context).textTheme.displaySmall!,
                tablet: Theme.of(context).textTheme.displayMedium!,
                desktop: Theme.of(context).textTheme.displayLarge!,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedTextKit(
              key: ValueKey(profileViewModel.title),
              animatedTexts: [
                TypewriterAnimatedText(
                  // Using profileViewModel.title directly
                  profileViewModel.title, 
                  textStyle: context.responsive<TextStyle>(
                    mobile: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Theme.of(context).colorScheme.secondary),
                    tablet: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Theme.of(context).colorScheme.secondary),
                    desktop: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
            ),
            const SizedBox(height: 30),
            Container(
              constraints: BoxConstraints(
                maxWidth: context.responsive<double>(
                  mobile: MediaQuery.of(context).size.width * 0.9,
                  tablet: 550,
                  desktop: 650,
                ),
              ),
              child: Text(
                profileViewModel.aboutMe,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _scrollToSection(3), // Scroll to contact section
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Text(
                  "Get in Touch",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (context.isMobile) const SizedBox(height: 30),
          ],
        );
      },
    );
  }
}