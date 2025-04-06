// lib/views/projects/widgets/project_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../models/project_model.dart';
import '../../../utils/image_utils.dart';

class ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  int _currentScreenshotIndex = 0;
  final PageController _pageController = PageController();
  
  // Animation controller for smooth hover effect without causing rebuilds
  late final AnimationController _animationController;
  late final Animation<double> _elevationAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for hover effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _elevationAnimation = Tween<double>(begin: 2, end: 8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _elevationAnimation,
          builder: (context, child) => Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            elevation: _elevationAnimation.value,
            child: child,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screenshot section - prevent rebuild on hover by extracting to a separate widget
              Expanded(
                flex: 3,
                child: _ScreenshotCarousel(
                  project: widget.project,
                  pageController: _pageController,
                  currentIndex: _currentScreenshotIndex,
                  onPageChanged: (index) {
                    setState(() {
                      _currentScreenshotIndex = index;
                    });
                  },
                  isHovered: _isHovered,
                  onPrevious: _previousScreenshot,
                  onNext: _nextScreenshot,
                ),
              ),
              
              // Project details section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // // Title
                      // Text(
                      //   widget.project.title,
                      //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                      // const SizedBox(height: 6),
                      
                      // Description
                      Expanded(
                        child: Text(
                          widget.project.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Technologies chips
                      SizedBox(
                        height: 32,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.project.technologies.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildTechChip(widget.project.technologies[index]),
                            );
                          },
                        ),
                      ),
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

  // Build technology chip with appropriate color
  Widget _buildTechChip(String tech) {
    Color chipColor;
    
    // Choose different colors based on technology
    final lcTech = tech.toLowerCase();
    if (lcTech.contains('flutter')) {
      chipColor = const Color(0xFF0175C2); // Flutter blue
    } else if (lcTech.contains('firebase')) {
      chipColor = const Color(0xFFFFCA28); // Firebase yellow
    } else if (lcTech.contains('ios') || lcTech.contains('swift')) {
      chipColor = const Color(0xFF999999); // iOS gray
    } else if (lcTech.contains('android')) {
      chipColor = const Color(0xFF3DDC84); // Android green
    } else {
      chipColor = Theme.of(context).colorScheme.primary; // Default to theme primary color
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        tech,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Navigate to next screenshot
  void _nextScreenshot() {
    if (!_hasMultipleScreenshots()) return;
    
    final nextIndex = (_currentScreenshotIndex + 1) % widget.project.screenshots.length;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Navigate to previous screenshot
  void _previousScreenshot() {
    if (!_hasMultipleScreenshots()) return;
    
    final previousIndex = _currentScreenshotIndex == 0
        ? widget.project.screenshots.length - 1
        : _currentScreenshotIndex - 1;
    _pageController.animateToPage(
      previousIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Check if the project has multiple screenshots
  bool _hasMultipleScreenshots() {
    return widget.project.screenshots.length > 1;
  }
}

// Separate widget for screenshot carousel to prevent unnecessary rebuilds
class _ScreenshotCarousel extends StatelessWidget {
  final Project project;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final bool isHovered;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _ScreenshotCarousel({
    required this.project,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
    required this.isHovered,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main screenshot/carousel
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: PageView.builder(
            controller: pageController,
            itemCount: _hasScreenshots() 
              ? project.screenshots.length 
              : 1,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              if (_hasScreenshots()) {
                // Show actual screenshot from the project
                final screenshot = project.screenshots[index];
                return ImageUtils.base64ToImage(
                  screenshot.imageBase64,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  errorWidget: _buildFallbackImage(context),
                );
              } else {
                // Fallback to a colored container if no screenshots
                return _buildFallbackImage(context);
              }
            },
          ),
        ),
        
        // Gradient overlay at bottom to ensure text readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),
        
        // Project name overlay at bottom
        if (project.screenshots.isNotEmpty)
          Positioned(
            bottom: 15,
            left: 20,
            right: 20,
            child: Text(
              project.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3.0,
                    color: Color.fromARGB(128, 0, 0, 0),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        
        // Left arrow navigation button - only show if we have multiple screenshots
        if (_hasMultipleScreenshots())
          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: isHovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: onPrevious,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
          
        // Right arrow navigation button - only show if we have multiple screenshots
        if (_hasMultipleScreenshots())
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: isHovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: onNext,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Fallback image when screenshots aren't available
  Widget _buildFallbackImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.image,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // Check if the project has valid screenshots
  bool _hasScreenshots() {
    return project.screenshots.isNotEmpty &&
        project.screenshots.first.imageBase64.isNotEmpty;
  }
  
  // Check if the project has multiple screenshots
  bool _hasMultipleScreenshots() {
    return project.screenshots.length > 1;
  }
}