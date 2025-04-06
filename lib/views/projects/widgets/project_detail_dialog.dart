// lib/views/projects/widgets/project_detail_dialog.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/project_model.dart';
import '../../../widgets/responsive_wrapper.dart';
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
  late final String _youtubeUrl;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Generate YouTube URL
    _youtubeUrl = 'https://www.youtube.com/watch?v=${widget.project.youtubeVideoId}';
    
    // Debug prints to verify screenshots data
    print('ProjectDetailDialog opened for project: ${widget.project.title}');
    print('Screenshots count: ${widget.project.screenshots.length}');
    if (widget.project.screenshots.isNotEmpty) {
      print('First screenshot has caption: ${widget.project.screenshots.first.caption}');
      print('First screenshot base64 length: ${widget.project.screenshots.first.imageBase64.length}');
    }

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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.2, // Centers the dialog
        vertical: 40,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with project title, YouTube button, and close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.project.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Row(
                    children: [
                      // YouTube review button
                      OutlinedButton.icon(
                        icon: const Icon(Icons.play_circle_filled),
                        label: const Text('See the review'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                        onPressed: () {
                          final youtubeUrl = 'https://www.youtube.com/watch?v=${widget.project.youtubeVideoId}';
                          launchURL(youtubeUrl);
                        },
                      ),
                      const SizedBox(width: 8),
                      // Close button
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Screenshots section (if any)
                    if (widget.project.screenshots.isNotEmpty) ...[
                      _buildScreenshotsSection(),
                      const SizedBox(height: 32),
                    ],

                    // Description
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.project.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          
                          const SizedBox(height: 32),
                          Text(
                            'Technologies Used',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: widget.project.technologies.map((tech) {
                              return Chip(
                                label: Text(
                                  tech,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build screenshots section with horizontal scrolling
  Widget _buildScreenshotsSection() {
    // Debug print to verify screenshots before displaying
    print('Building screenshots section with ${widget.project.screenshots.length} screenshots');
    if (widget.project.screenshots.isEmpty) {
      print('No screenshots available for this project');
      return const SizedBox.shrink(); // Return empty if no screenshots
    }
    
    // Verify that screenshots have valid base64 data
    final validScreenshots = widget.project.screenshots.where((s) => 
      s.imageBase64.isNotEmpty && s.id.isNotEmpty
    ).toList();
    
    if (validScreenshots.isEmpty) {
      print('Screenshots are present but none have valid base64 data');
      return const SizedBox.shrink();
    }
    
    print('Found ${validScreenshots.length} valid screenshots to display');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
          child: Text(
            'Screenshots',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 16),
        
        // Screenshot gallery
        SizedBox(
          height: 340, // Reduced height
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: validScreenshots.length,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemBuilder: (context, index) {
              final screenshot = validScreenshots[index];
              return _buildScreenshotItem(screenshot, index);
            },
          ),
        ),
      ],
    );
  }
  
  // Build a single screenshot item
  Widget _buildScreenshotItem(ProjectScreenshot screenshot, int index) {
    // Use about a fifth of the available width
    final screenWidth = MediaQuery.of(context).size.width * 0.18;
    
    return Container(
      width: screenWidth,
      margin: const EdgeInsets.only(right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Screenshot image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: ImageUtils.base64ToImage(
                  screenshot.imageBase64,
                  fit: BoxFit.contain,
                  errorWidget: const Center(
                    child: Icon(Icons.broken_image, size: 40, color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
          
          // Caption below image
          if (screenshot.caption.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              screenshot.caption,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
  
  // This method is now removed since we don't need it anymore
  // We're no longer tracking the current selected screenshot or handling navigation dots
  /*
  void _scrollToIndex(int index) {
    final screenWidth = MediaQuery.of(context).size.width * 0.18;
    final position = index * (screenWidth + 4); // width + margin
    
    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
  */
}