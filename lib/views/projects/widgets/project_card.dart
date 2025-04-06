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
  
  // Error tracking
  bool _hasRenderError = false;
  
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
        child: RepaintBoundary(
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
                    onErrorDetected: (hasError) {
                      if (hasError != _hasRenderError) {
                        setState(() {
                          _hasRenderError = hasError;
                        });
                      }
                    },
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
                          child: _buildTechnologyChips(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build technology chips with horizontal scrolling
  Widget _buildTechnologyChips() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.project.technologies.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildTechChip(widget.project.technologies[index]),
        );
      },
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
class _ScreenshotCarousel extends StatefulWidget {
  final Project project;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final bool isHovered;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<bool> onErrorDetected;

  const _ScreenshotCarousel({
    required this.project,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
    required this.isHovered,
    required this.onPrevious,
    required this.onNext,
    required this.onErrorDetected,
  });

  @override
  State<_ScreenshotCarousel> createState() => _ScreenshotCarouselState();
}

class _ScreenshotCarouselState extends State<_ScreenshotCarousel> {
  bool _hasError = false;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main screenshot/carousel
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: PageView.builder(
            controller: widget.pageController,
            itemCount: _hasScreenshots() 
              ? widget.project.screenshots.length 
              : 1,
            onPageChanged: widget.onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              if (_hasScreenshots()) {
                // Show actual screenshot from the project
                final screenshot = widget.project.screenshots[index];
                return ImageUtils.base64ToImage(
                  screenshot.imageBase64,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
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
        Positioned(
          bottom: 15,
          left: 20,
          right: 20,
          child: Text(
            widget.project.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
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
                opacity: widget.isHovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: widget.onPrevious,
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
                opacity: widget.isHovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black.withOpacity(0.3),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: widget.onNext,
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
    // Notify parent about error if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onErrorDetected(true);
    });
    
    // Use thumbnail as fallback if available
    if (widget.project.thumbnailUrl.isNotEmpty) {
      return Image.network(
        widget.project.thumbnailUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // If network image fails, fall back to placeholder
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.project.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    
    // Default placeholder
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              widget.project.title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Check if the project has valid screenshots
  bool _hasScreenshots() {
    return widget.project.screenshots.isNotEmpty &&
        widget.project.screenshots.first.imageBase64.isNotEmpty;
  }
  
  // Check if the project has multiple screenshots
  bool _hasMultipleScreenshots() {
    return widget.project.screenshots.length > 1;
  }
}