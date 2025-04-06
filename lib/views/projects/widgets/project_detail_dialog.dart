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
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity, // Will be constrained by Dialog
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
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
    );
  }

  // Header with title, button, and close icon
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.project.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => launchURL(
                  'https://www.youtube.com/watch?v=${widget.project.youtubeVideoId}',
                ),
                icon: const Icon(Icons.play_circle_filled, color: Colors.white),
                label: const Text('See the review', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
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

  // Screenshots section with horizontal row of images
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
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: validScreenshots.length,
                    itemBuilder: (context, index) {
                      final screenshot = validScreenshots[index];
                      return _buildScreenshotItem(screenshot);
                    },
                  ),
                ),
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
      width: 200, // Fixed width for each screenshot
      margin: const EdgeInsets.only(left: 16),
      child: Column(
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.indigo,
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