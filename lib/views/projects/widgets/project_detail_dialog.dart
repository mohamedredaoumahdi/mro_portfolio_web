// lib/views/projects/widgets/project_detail_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/project_model.dart';
import '../../../utils/image_utils.dart';
import 'package:portfolio_website/viewmodels/activity_viewmodel.dart';
import 'package:portfolio_website/main.dart';

class ProjectDetailDialog extends StatefulWidget {
  final Project project;

  const ProjectDetailDialog({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailDialog> createState() => _ProjectDetailDialogState();
}

class _ProjectDetailDialogState extends State<ProjectDetailDialog> {
  int _currentScreenshotIndex = 0;
  final PageController _pageController = PageController();
  bool _isLoading = false;
  bool _videoLaunchError = false;

  @override
  void initState() {
    super.initState();
    
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      // Constrain dialog size for better appearance
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? screenSize.width * 0.95 : 900,
          maxHeight: isSmallScreen ? screenSize.height * 0.95 : 700,
        ),
        child: Container(
          width: double.infinity,
          color: Theme.of(context).cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildScreenshotsSection(context),
                          _buildDescriptionSection(context),
                          _buildTechnologiesSection(context),
                          const SizedBox(height: 24),
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

  // Header with title, button, and close icon
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.project.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              _buildWatchButton(context),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Watch button with loading and error states
  Widget _buildWatchButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : () => _launchVideoUrl(context),
      icon: _isLoading 
        ? const SizedBox(
            width: 20, 
            height: 20, 
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
          )
        : const Icon(Icons.play_circle_filled, color: Colors.white),
      label: Text(
        _videoLaunchError ? 'Try Again' : 'See the review', 
        style: const TextStyle(color: Colors.white)
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _videoLaunchError ? Colors.red : Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
  
  // Launch the YouTube video URL
  Future<void> _launchVideoUrl(BuildContext context) async {
    if (widget.project.youtubeVideoId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video available for this project'))
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _videoLaunchError = false;
    });
    
    try {
      final url = 'https://www.youtube.com/watch?v=${widget.project.youtubeVideoId}';
      await launchURL(url);
    } catch (e) {
      setState(() {
        _videoLaunchError = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening video: ${e.toString()}'))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Screenshots section with horizontal row of images and paging
  Widget _buildScreenshotsSection(BuildContext context) {
    final validScreenshots = _getValidScreenshots();
    if (validScreenshots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 16),
            child: Text(
              'Screenshots',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 400, // Fixed height for screenshots
            child: Stack(
              children: [
                // Screenshots PageView
                PageView.builder(
                  controller: _pageController,
                  itemCount: validScreenshots.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentScreenshotIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Center(
                      child: _buildScreenshotItem(validScreenshots[index]),
                    );
                  },
                ),
                
                // Pagination indicators
                if (validScreenshots.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        validScreenshots.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentScreenshotIndex == index
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                // Navigation arrows
                if (validScreenshots.length > 1) ...[
                  // Left arrow
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.black.withOpacity(0.3),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.white),
                          onPressed: () {
                            final prevIndex = _currentScreenshotIndex == 0
                                ? validScreenshots.length - 1
                                : _currentScreenshotIndex - 1;
                            
                            _pageController.animateToPage(
                              prevIndex,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  // Right arrow
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.black.withOpacity(0.3),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.white),
                          onPressed: () {
                            final nextIndex = (_currentScreenshotIndex + 1) % validScreenshots.length;
                            
                            _pageController.animateToPage(
                              nextIndex,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Single screenshot item with caption
  Widget _buildScreenshotItem(ProjectScreenshot screenshot) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImageUtils.base64ToImage(
                screenshot.imageBase64,
                fit: BoxFit.contain,
                errorWidget: const Icon(Icons.broken_image, size: 80),
              ),
            ),
          ),
          if (screenshot.caption.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              screenshot.caption,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  // Description section
  Widget _buildDescriptionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.project.description,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ],
      ),
    );
  }

  // Technologies section with chips
  Widget _buildTechnologiesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Technologies Used',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.project.technologies.map((tech) => _buildTechChip(tech)).toList(),
          ),
        ],
      ),
    );
  }

  // Tech chip with colored background
  Widget _buildTechChip(String tech) {
    // Choose different colors based on technology
    Color chipColor;
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tech,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
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