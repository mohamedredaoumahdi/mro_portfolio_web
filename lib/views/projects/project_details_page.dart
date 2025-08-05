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
                CircularProgressIndicator(
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
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Navigation Bar with glass morphism
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    expandedHeight: 60,
                    centerTitle: false,
                    automaticallyImplyLeading: false,
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
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
                  ),
                  
                  // Hero Section
                  SliverToBoxAdapter(child: _buildEnhancedHeroSection(context)),
                  
                  // Main Content
                  SliverToBoxAdapter(child: _buildMainContent(context)),
                ],
              ),
            ),
          ),
    );
  }
  
  // Enhanced hero section with sophisticated design
  Widget _buildEnhancedHeroSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.3, 0.7, 1.0],
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.98),
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.92),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: HeroPatterPainter(
                color: AppColors.primaryPurple.withValues(alpha: 0.03),
              ),
            ),
          ),
          
          // Main content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 80,
              vertical: isMobile ? 60 : 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced project title with advanced styling
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: isMobile ? 40 : 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryPurple,
                            AppColors.primaryPurple.withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            AppColors.primaryPurple,
                            AppColors.accentPurple,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          widget.project.title,
                          style: TextStyle(
                            fontSize: isMobile ? 21 : 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Enhanced project meta info with advanced styling
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildAdvancedMetaChip(context, _getPlatformInfo(), Icons.devices, Colors.blue),
                    _buildAdvancedMetaChip(context, '${widget.project.technologies.length} Technologies', Icons.code, Colors.green),
                    _buildAdvancedMetaChip(context, '${_getValidScreenshots().length} Screenshots', Icons.photo_library, Colors.orange),
                    if (widget.project.youtubeVideoId.isNotEmpty)
                      _buildPremiumWatchButton(context),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Project quick stats
                _buildProjectStats(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Advanced meta chip with color coding and hover effects
  Widget _buildAdvancedMetaChip(BuildContext context, String text, IconData icon, Color accentColor) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withValues(alpha: 0.1),
              accentColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: accentColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Premium watch button with advanced styling
  Widget _buildPremiumWatchButton(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _launchVideoUrl(context),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPurple,
                    AppColors.accentPurple,
                    AppColors.primaryPurple.withValues(alpha: 0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Watch Demo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Project statistics section
  Widget _buildProjectStats(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(context, 'Platform', _getPlatformInfo(), Icons.phone_android),
          if (!isMobile) _buildDivider(context),
          _buildStatItem(context, 'Tech Stack', '${widget.project.technologies.length} Technologies', Icons.code),
          if (!isMobile) _buildDivider(context),
          _buildStatItem(context, 'Gallery', '${_getValidScreenshots().length} Images', Icons.photo_library),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: AppColors.primaryPurple.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
    );
  }



  // Enhanced main content with modern layouts  
  Widget _buildMainContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 768 ? 24 : 80,
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
        _buildEnhancedImageGallerySection(context),
        const SizedBox(height: 100),
        _buildEnhancedOverviewSection(context),
        const SizedBox(height: 100),
        _buildEnhancedTechnologiesSection(context),
      ],
    );
  }

  // Enhanced tablet layout
  Widget _buildEnhancedTabletLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEnhancedImageGallerySection(context),
        const SizedBox(height: 80),
        _buildEnhancedOverviewSection(context),
        const SizedBox(height: 80),
        _buildEnhancedTechnologiesSection(context),
      ],
    );
  }

  // Enhanced mobile layout
  Widget _buildEnhancedMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEnhancedImageGallerySection(context),
        const SizedBox(height: 60),
        _buildEnhancedOverviewSection(context),
        const SizedBox(height: 60),
        _buildEnhancedTechnologiesSection(context),
      ],
    );
  }

  // Premium overview section with sophisticated design
  Widget _buildEnhancedOverviewSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium section title with floating element
          Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryPurple,
                          AppColors.primaryPurple.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Project Overview',
                    style: TextStyle(
                      fontSize: isMobile ? 32 : 42,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryPurple.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.article,
                        size: 16,
                        color: AppColors.primaryPurple,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          // Sophisticated description card
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).cardColor.withValues(alpha: 0.8),
                  Theme.of(context).cardColor.withValues(alpha: 0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.05),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.description,
                        size: 20,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'About This Project',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.headlineMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  widget.project.description,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    height: 1.8,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }




  String _getPlatformInfo() {
    final techs = widget.project.technologies.map((t) => t.toLowerCase());
    if (techs.any((t) => t.contains('flutter'))) {
      return 'Cross-platform (Flutter)';
    } else if (techs.any((t) => t.contains('ios'))) {
      return 'iOS Native';
    } else if (techs.any((t) => t.contains('android'))) {
      return 'Android Native';
    }
    return 'Mobile Application';
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
        // Premium section title with progress indicator
        Stack(
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryPurple,
                        AppColors.primaryPurple.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  'Project Gallery',
                  style: TextStyle(
                    fontSize: isMobile ? 32 : 42,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.headlineMedium?.color,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withValues(alpha: 0.1),
                      Colors.orange.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${validScreenshots.length} Images',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        
        // Enhanced main image display
        Center(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: isMobile ? 500 : 700,
              maxWidth: double.infinity,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: validScreenshots.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentScreenshotIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        width: double.infinity,
                        child: ImageUtils.base64ToImage(
                          validScreenshots[index].imageBase64,
                          fit: BoxFit.contain,
                          errorWidget: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
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
                        onTap: () {
                          final prevIndex = _currentScreenshotIndex == 0
                              ? validScreenshots.length - 1
                              : _currentScreenshotIndex - 1;
                          
                          _pageController.animateToPage(
                            prevIndex,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
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
                  
                  // Right arrow
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          final nextIndex = (_currentScreenshotIndex + 1) % validScreenshots.length;
                          
                          _pageController.animateToPage(
                            nextIndex,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
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
        
        // Enhanced thumbnails
        if (validScreenshots.length > 1) ...[
          const SizedBox(height: 32),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: double.infinity),
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: validScreenshots.length,
                itemBuilder: (context, index) {
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
                      margin: const EdgeInsets.only(right: 16),
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
                },
              ),
            ),
          ),
        ],
      ],
    );
  }



  // Premium technologies section with sophisticated layout
  Widget _buildEnhancedTechnologiesSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Premium section title with tech count
        Stack(
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.green,
                        Colors.green.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  'Technologies Used',
                  style: TextStyle(
                    fontSize: isMobile ? 32 : 42,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.headlineMedium?.color,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.1),
                      Colors.green.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.code,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.project.technologies.length} Technologies',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        
        // Premium technology grid with better organization
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = isMobile ? 2 : (constraints.maxWidth > 1200 ? 4 : 3);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 2.8 : 3.2,
              ),
              itemCount: widget.project.technologies.length,
              itemBuilder: (context, index) {
                return _buildEnhancedTechChip(context, widget.project.technologies[index]);
              },
            );
          },
        ),
      ],
    );
  }

  // Premium technology chip with advanced hover animations
  Widget _buildEnhancedTechChip(BuildContext context, String tech) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() {}),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).cardColor.withValues(alpha: 0.9),
              Theme.of(context).cardColor.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.accentPurple.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.accentPurple.withValues(alpha: 0.1),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPurple,
                    AppColors.accentPurple,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPurple.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tech,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }







  // Get only valid screenshots (with non-empty base64 data)
  List<ProjectScreenshot> _getValidScreenshots() {
    return widget.project.screenshots
        .where((s) => s.imageBase64.isNotEmpty)
        .toList();
  }
}

// Custom painter for hero section background pattern
class HeroPatterPainter extends CustomPainter {
  final Color color;

  HeroPatterPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw subtle dot pattern
    const double spacing = 40.0;
    const double dotSize = 2.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}