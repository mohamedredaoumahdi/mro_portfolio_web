// lib/views/projects/project_details_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project_model.dart';
import '../../utils/image_utils.dart';
import '../home/widgets/nav_bar.dart';
import 'package:portfolio_website/viewmodels/activity_viewmodel.dart';
import 'package:portfolio_website/main.dart';

// Consistent purple colors that don't change with theme
class AppColors {
  static const Color primaryPurple = Color(0xFF4A00E0);
  static const Color accentPurple = Color(0xFF8E2DE2);
}

class ProjectDetailsPage extends StatefulWidget {
  final Project project;

  const ProjectDetailsPage({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> 
    with TickerProviderStateMixin {
  int _currentScreenshotIndex = 0;
  final PageController _pageController = PageController();
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    
    // Log the project view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final activityViewModel =
            Provider.of<ActivityViewModel>(context, listen: false);
        activityViewModel.logProjectView(
            widget.project.id, widget.project.title);
      }
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Loading project details...',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        : FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Navigation Bar - matching home page structure
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: NavBar(
                      onNavItemTapped: (index) {
                        // Handle navigation based on index - clear navigation stack
                        if (index == 0) {
                          // Home - clear all navigation history
                          Navigator.pushNamedAndRemoveUntil(
                            context, 
                            '/', 
                            (route) => false,
                          );
                        } else {
                          // Other sections - go to home, scroll to section, clear history
                          Navigator.pushNamedAndRemoveUntil(
                            context, 
                            '/',
                            (route) => false,
                            arguments: {'scrollToSection': index}
                          );
                        }
                      },
                    ),
                  ),
                  
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Hero Section
                          _buildEnhancedHeroSection(context),
                          
                          // Main Content
                          _buildMainContent(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
  
  // Simplified hero section with enhancements
  Widget _buildEnhancedHeroSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    // Match navbar padding: 120px desktop, 20px mobile
    final horizontalPadding = isMobile ? 20.0 : 120.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 60 : 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project.title,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                    height: 1.2,
                  ),
                ),
                if (widget.project.youtubeVideoId.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSimpleWatchButton(context),
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Project title - left side
                Expanded(
                  child: Text(
                    widget.project.title,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineLarge?.color,
                      height: 1.2,
                    ),
                  ),
                ),
                
                // Watch Demo button - right side (only if video exists)
                if (widget.project.youtubeVideoId.isNotEmpty)
                  _buildSimpleWatchButton(context),
              ],
            ),
    );
  }
  
  // Simple watch button
  Widget _buildSimpleWatchButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchVideoUrl(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Watch Demo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }




  // Enhanced main content with modern layouts  
  Widget _buildMainContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    // Match navbar padding: 120px desktop, 20px mobile
    final horizontalPadding = isMobile ? 20.0 : 120.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 80,
      ),
      child: Column(
        children: [
          if (screenWidth >= 1200)
            _buildEnhancedDesktopLayout(context)
          else if (screenWidth >= 768)
            _buildEnhancedTabletLayout(context)
          else
            _buildEnhancedMobileLayout(context),
        ],
      ),
    );
  }

  // Enhanced desktop layout with modern styling
  Widget _buildEnhancedDesktopLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEnhancedOverviewSection(context),
        const SizedBox(height: 100),
        _buildEnhancedImageGallerySection(context),
      ],
    );
  }

  // Enhanced tablet layout
  Widget _buildEnhancedTabletLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEnhancedOverviewSection(context),
        const SizedBox(height: 80),
        _buildEnhancedImageGallerySection(context),
      ],
    );
  }

  // Enhanced mobile layout
  Widget _buildEnhancedMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEnhancedOverviewSection(context),
        const SizedBox(height: 60),
        _buildEnhancedImageGallerySection(context),
      ],
    );
  }

  // Simplified overview section - matching Services/Projects sections style
  Widget _buildEnhancedOverviewSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header - matching Services/Projects sections
          Text(
            'Project Overview',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineLarge?.color,
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
          const SizedBox(height: 40),
          
          // Simple description text
          Text(
            widget.project.description,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              height: 1.7,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }




  // Launch the YouTube video URL
  Future<void> _launchVideoUrl(BuildContext context) async {
    if (widget.project.youtubeVideoId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No video available for this project'))
        );
      }
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final url = 'https://www.youtube.com/watch?v=${widget.project.youtubeVideoId}';
      await launchURL(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening video: ${e.toString()}'))
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Premium image gallery section with advanced features
  Widget _buildEnhancedImageGallerySection(BuildContext context) {
    final validScreenshots = _getValidScreenshots();
    if (validScreenshots.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header - matching Services/Projects sections
        Text(
          'Project Gallery',
          style: TextStyle(
            fontSize: isMobile ? 28 : 36,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineLarge?.color,
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
        const SizedBox(height: 32),
        
        // Main image display
        Center(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: isMobile ? 350 : 500,
              maxWidth: double.infinity,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: validScreenshots.length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      if (mounted) {
                        setState(() {
                          _currentScreenshotIndex = index;
                        });
                      }
                    },
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: double.infinity,
                        child: ImageUtils.base64ToImage(
                          validScreenshots[index].imageBase64,
                          fit: BoxFit.contain,
                          errorWidget: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.broken_image,
                              size: 80,
                              color: AppColors.primaryPurple.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Enhanced navigation arrows
                if (validScreenshots.length > 1) ...[
                  // Left arrow
                  Positioned(
                    left: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _currentScreenshotIndex > 0
                            ? () {
                                final prevIndex = _currentScreenshotIndex - 1;
                                _pageController.animateToPage(
                                  prevIndex,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            : null,
                        child: Opacity(
                          opacity: _currentScreenshotIndex > 0 ? 1.0 : 0.5,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Right arrow
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _currentScreenshotIndex < validScreenshots.length - 1
                            ? () {
                                final nextIndex = _currentScreenshotIndex + 1;
                                _pageController.animateToPage(
                                  nextIndex,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            : null,
                        child: Opacity(
                          opacity: _currentScreenshotIndex < validScreenshots.length - 1 ? 1.0 : 0.5,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                
                // Enhanced image counter
                if (validScreenshots.length > 1)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${_currentScreenshotIndex + 1} / ${validScreenshots.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Thumbnails
        if (validScreenshots.length > 1) ...[
          const SizedBox(height: 24),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: double.infinity),
              height: 100,
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(validScreenshots.length, (index) {
                      final isSelected = index == _currentScreenshotIndex;
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 80,
                          height: 100,
                          margin: EdgeInsets.only(
                            right: index < validScreenshots.length - 1 ? 16 : 0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                ? AppColors.primaryPurple 
                                : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ] : [],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: ImageUtils.base64ToImage(
                              validScreenshots[index].imageBase64,
                              fit: BoxFit.cover,
                              errorWidget: const Icon(Icons.broken_image, size: 30),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }










  // Get only valid screenshots (with non-empty base64 data)
  List<ProjectScreenshot> _getValidScreenshots() {
    return widget.project.screenshots
        .where((s) => s.imageBase64.isNotEmpty)
        .toList();
  }
}
