// lib/views/projects/widgets/project_card.dart
import 'package:flutter/material.dart';
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

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovered = false;
  int _currentScreenshotIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          elevation: _isHovered ? 8 : 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screenshot section with overlay elements
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    // Main screenshot/carousel
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _hasScreenshots() 
                          ? widget.project.screenshots.length 
                          : 1,
                        onPageChanged: (index) {
                          setState(() {
                            _currentScreenshotIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          if (_hasScreenshots()) {
                            // Show actual screenshot from the project
                            final screenshot = widget.project.screenshots[index];
                            return ImageUtils.base64ToImage(
                              screenshot.imageBase64,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain, // Changed to contain to preserve aspect ratio
                              errorWidget: _buildFallbackImage(),
                            );
                          } else {
                            // Fallback to a colored container if no screenshots
                            return _buildFallbackImage();
                          }
                        },
                      ),
                    ),
                    
                    // Gradient overlay at bottom to ensure text readability
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 60, // Height of gradient overlay
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
                    
                    // // Project name overlay at bottom
                    // if (widget.project.screenshots.isNotEmpty)
                    //   Positioned(
                    //     bottom: 15,
                    //     left: 20,
                    //     right: 20,
                    //     child: Text(
                    //       widget.project.title,
                    //       style: const TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 20,
                    //         fontWeight: FontWeight.bold,
                    //         shadows: [
                    //           Shadow(
                    //             offset: Offset(0, 1),
                    //             blurRadius: 3.0,
                    //             color: Color.fromARGB(128, 0, 0, 0),
                    //           ),
                    //         ],
                    //       ),
                    //       maxLines: 1,
                    //       overflow: TextOverflow.ellipsis,
                    //     ),
                    //   ),
                    
                    // No play button
                    
                    // Left arrow navigation button
                    if (widget.project.screenshots.length > 1)
                      Positioned(
                        left: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.black.withOpacity(0.3),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                              onPressed: _previousScreenshot,
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                      
                    // Right arrow navigation button
                    if (widget.project.screenshots.length > 1)
                      Positioned(
                        right: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.black.withOpacity(0.3),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                              onPressed: _nextScreenshot,
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                    
                    // No pagination dots
                  ],
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
                      // Title (not shown in screenshot section)
                      Text(
                        widget.project.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      
                      // Description
                      Expanded(
                        child: Text(
                          widget.project.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 6,
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

  // Fallback image when screenshots aren't available
  Widget _buildFallbackImage() {
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

  // Navigate to next screenshot
  void _nextScreenshot() {
    if (widget.project.screenshots.length <= 1) return;
    
    final nextIndex = (_currentScreenshotIndex + 1) % widget.project.screenshots.length;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Navigate to previous screenshot
  void _previousScreenshot() {
    if (widget.project.screenshots.length <= 1) return;
    
    final previousIndex = _currentScreenshotIndex == 0
        ? widget.project.screenshots.length - 1
        : _currentScreenshotIndex - 1;
    _pageController.animateToPage(
      previousIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Check if the project has valid screenshots
  bool _hasScreenshots() {
    return widget.project.screenshots.isNotEmpty &&
        widget.project.screenshots.first.imageBase64.isNotEmpty;
  }
}