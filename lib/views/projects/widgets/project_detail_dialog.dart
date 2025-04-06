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
    // Use responsive inset padding based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate appropriate inset padding
    final horizontalInset = context.responsive<double>(
      mobile: 16.0,
      tablet: screenWidth * 0.1,
      desktop: screenWidth * 0.2,
    );
    
    final verticalInset = context.responsive<double>(
      mobile: 16.0,
      tablet: 24.0,
      desktop: 40.0,
    );
    
    // Calculate appropriate width constraint
    final maxWidth = context.responsive<double>(
      mobile: screenWidth,
      tablet: screenWidth * 0.8,
      desktop: screenWidth * 0.6,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: horizontalInset,
        vertical: verticalInset,
      ),
      child: Container(
        width: maxWidth,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.9,
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
            _buildHeader(context),
            const Divider(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Screenshots section (if any)
                    if (widget.project.screenshots.isNotEmpty) ...[
                      _buildScreenshotsSection(context),
                      const SizedBox(height: 32),
                    ],

                    // Description and technologies
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
  
  // Build responsive header section
  Widget _buildHeader(BuildContext context) {
    return ResponsiveWrapper(
      mobile: _buildMobileHeader(context),
      desktop: _buildDesktopHeader(context),
    );
  }
  
  // Mobile-specific header layout
  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.project.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.play_circle_filled),
            label: const Text('See the review'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            onPressed: () => launchURL(_youtubeUrl),
          ),
        ),
      ],
    );
  }
  
  // Desktop header layout
  Widget _buildDesktopHeader(BuildContext context) {
    return Padding(
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
                onPressed: () => launchURL(_youtubeUrl),
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
    );
  }
  
  // Build responsive screenshots section
  Widget _buildScreenshotsSection(BuildContext context) {
    // Verify that screenshots have valid base64 data
    final validScreenshots = widget.project.screenshots.where((s) => 
      s.imageBase64.isNotEmpty && s.id.isNotEmpty
    ).toList();
    
    if (validScreenshots.isEmpty) {
      return const SizedBox.shrink();
    }
    
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
        
        // Screenshot gallery with responsive height
        SizedBox(
          height: context.responsive<double>(
            mobile: 240, // Smaller height on mobile
            tablet: 320,
            desktop: 340,
          ),
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
  
  // Build a responsive screenshot item
  Widget _buildScreenshotItem(ProjectScreenshot screenshot, int index) {
    // Calculate responsive width based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = context.responsive<double>(
      mobile: screenWidth * 0.35, // Smaller on mobile
      tablet: screenWidth * 0.25,
      desktop: screenWidth * 0.18,
    );
    
    return Container(
      width: itemWidth,
      margin: const EdgeInsets.only(right: 8),
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
}