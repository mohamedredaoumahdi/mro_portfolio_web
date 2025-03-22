import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../models/project_model.dart';
import '../../../widgets/responsive_wrapper.dart';

class ProjectDetailDialog extends StatefulWidget {
  final Project project;

  const ProjectDetailDialog({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  State<ProjectDetailDialog> createState() => _ProjectDetailDialogState();
}

class _ProjectDetailDialogState extends State<ProjectDetailDialog> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.project.youtubeVideoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableJavaScript: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: context.responsive<EdgeInsets>(
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(48),
        desktop: const EdgeInsets.all(80),
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: context.responsive<double>(
            mobile: double.infinity,
            tablet: 700,
            desktop: 900,
          ),
          maxHeight: context.responsive<double>(
            mobile: MediaQuery.of(context).size.height * 0.8,
            tablet: MediaQuery.of(context).size.height * 0.8,
            desktop: MediaQuery.of(context).size.height * 0.9,
          ),
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.project.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),
            
            // YouTube Player
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // YouTube player
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: YoutubePlayer(
                        controller: _controller,
                        aspectRatio: 16 / 9,
                      ),
                    ),
                    
                    // Project details
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
                          const SizedBox(height: 24),
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
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                                backgroundColor: Theme.of(context).colorScheme.primary,
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
}