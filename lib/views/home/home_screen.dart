import 'package:flutter/material.dart';
import 'package:portfolio_website/config/app_config.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../widgets/responsive_wrapper.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/service_viewmodel.dart';
import '../services/services_section.dart';
import '../projects/projects_section.dart';
import '../contact/contact_section.dart';
import 'widgets/code_animation.dart';
import 'widgets/nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(4, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
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
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.background,
                    Theme.of(context).colorScheme.background.withOpacity(0.8),
                  ],
                ),
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
                              Expanded(
                                flex: 2,
                                child: const CodeAnimation(),
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
          "I'm ${AppConfig.name},",
          style: context.responsive<TextStyle>(
            mobile: Theme.of(context).textTheme.displaySmall!,
            tablet: Theme.of(context).textTheme.displayMedium!,
            desktop: Theme.of(context).textTheme.displayLarge!,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              AppConfig.title,
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
            AppConfig.aboutMe,
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
  }
}