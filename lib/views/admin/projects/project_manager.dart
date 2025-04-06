// lib/views/admin/projects/project_manager.dart
import 'package:flutter/material.dart';
import 'package:portfolio_website/utils/image_utils.dart';
import 'package:provider/provider.dart';
import 'package:portfolio_website/models/project_model.dart';
import 'package:portfolio_website/services/firestore_service.dart';
import 'package:portfolio_website/viewmodels/project_viewmodel.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:portfolio_website/viewmodels/activity_viewmodel.dart';

class ProjectManagerScreen extends StatefulWidget {
  const ProjectManagerScreen({super.key});

  @override
  State<ProjectManagerScreen> createState() => _ProjectManagerScreenState();
}

class _ProjectManagerScreenState extends State<ProjectManagerScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  Project? _selectedProject;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Projects Manager',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () => _showProjectForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Project'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Create and manage projects for your portfolio',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            
            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            
            // Projects list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildProjectsList(context),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProjectsList(BuildContext context) {
    return Consumer<ProjectViewModel>(
      builder: (context, projectViewModel, child) {
        if (projectViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (projectViewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error loading projects',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(projectViewModel.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => projectViewModel.loadProjects(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (projectViewModel.projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder_open, color: Colors.grey, size: 48),
                const SizedBox(height: 16),
                Text(
                  'No projects found',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text('Add your first project using the button above'),
              ],
            ),
          );
        }
        
        return ReorderableListView.builder(
          itemCount: projectViewModel.projects.length,
          onReorder: (oldIndex, newIndex) {
            // Handle reordering
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            // Implement reordering logic with Firestore
            FirestoreService.instance.reorderProjects(oldIndex, newIndex).then((_) {
              // Refresh the projects list
              projectViewModel.loadProjects();
            }).catchError((error) {
              setState(() {
                _errorMessage = 'Failed to reorder projects: $error';
              });
            });
          },
          itemBuilder: (context, index) {
            final project = projectViewModel.projects[index];
            return Card(
              key: Key(project.id),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Project thumbnail from YouTube
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://img.youtube.com/vi/${project.youtubeVideoId}/mqdefault.jpg',
                        width: 120,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 80,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Project details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            project.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: project.technologies.map((tech) {
                              return Chip(
                                label: Text(tech),
                                labelStyle: const TextStyle(fontSize: 12),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    
                    // Action buttons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _selectedProject = project;
                            _showProjectForm(context, isEditing: true);
                          },
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmation(context, project),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  void _showProjectForm(BuildContext context, {bool isEditing = false}) {
    showDialog(
      context: context,
      builder: (context) => ProjectFormDialog(
        project: isEditing ? _selectedProject : null,
        onSave: () {
          Navigator.pop(context);
          // Refresh the projects list
          context.read<ProjectViewModel>().loadProjects();
        },
      ),
    ).then((_) {
      // Clear selected project after dialog is closed
      setState(() {
        _selectedProject = null;
      });
    });
  }
  
  void _showDeleteConfirmation(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final activityViewModel = Provider.of<ActivityViewModel>(context, listen: false);
              await activityViewModel.logActivity(
                type: 'delete',
                message: 'You deleted the "${project.title}" project',
                entityId: project.id,
                metadata: {'title': project.title},
              );
              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });
              
              try {
                // Delete the project from Firestore
                await FirestoreService.instance.deleteProject(project.id);
                
                // Refresh the projects list
                if (mounted) {
                  context.read<ProjectViewModel>().loadProjects();
                }
              } catch (e) {
                setState(() {
                  _errorMessage = 'Failed to delete project: ${e.toString()}';
                  _isLoading = false;
                });
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// lib/views/admin/projects/project_manager.dart - Updated ProjectFormDialog class

class ProjectFormDialog extends StatefulWidget {
  final Project? project;
  final VoidCallback onSave;

  const ProjectFormDialog({
    super.key,
    this.project,
    required this.onSave,
  });

  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeIdController = TextEditingController();
  final _techFieldController = TextEditingController();
  final _screenshotCaptionController = TextEditingController();
  
  List<String> _technologies = [];
  List<ProjectScreenshot> _screenshots = [];
  String _newTech = '';
  bool _isLoading = false;
  String? _errorMessage;
  String? _previewVideoId;
  bool _isPreviewVisible = false;
  ProjectScreenshot? _selectedScreenshot;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize form with existing project data if editing
    if (widget.project != null) {
      _titleController.text = widget.project!.title;
      _descriptionController.text = widget.project!.description;
      _youtubeIdController.text = widget.project!.youtubeVideoId;
      _technologies = List.from(widget.project!.technologies);
      _screenshots = List.from(widget.project!.screenshots);
      _previewVideoId = widget.project!.youtubeVideoId;
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _youtubeIdController.dispose();
    _techFieldController.dispose();
    _screenshotCaptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;
    
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog title
                Text(
                  isEditing ? 'Edit Project' : 'Add New Project',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                
                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Form fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title field
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Project Title',
                            hintText: 'Enter project title',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Description field
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Project Description',
                            hintText: 'Enter project description',
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // YouTube Video ID field
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _youtubeIdController,
                                decoration: const InputDecoration(
                                  labelText: 'YouTube Video ID',
                                  hintText: 'e.g. dQw4w9WgXcQ',
                                  helperText: 'The ID part from YouTube URL (not the full URL)',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a YouTube video ID';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  // Reset the preview state
                                  setState(() {
                                    _isPreviewVisible = false;
                                    _previewVideoId = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                // Set preview video ID and show preview
                                setState(() {
                                  _previewVideoId = _youtubeIdController.text;
                                  _isPreviewVisible = true;
                                });
                              },
                              child: const Text('Preview'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // YouTube preview
                        if (_isPreviewVisible && _previewVideoId != null && _previewVideoId!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Video Preview:'),
                              const SizedBox(height: 8),
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: YoutubePlayer(
                                  controller: YoutubePlayerController.fromVideoId(
                                    videoId: _previewVideoId!,
                                    autoPlay: false,
                                    params: const YoutubePlayerParams(
                                      showControls: true,
                                      showFullscreenButton: true,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 24),
                        
                        // Technologies section
                        const Text(
                          'Technologies Used',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _techFieldController,
                                decoration: const InputDecoration(
                                  hintText: 'Add a technology',
                                  helperText: 'e.g. Flutter, Firebase, etc.',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _newTech = value;
                                  });
                                },
                                onFieldSubmitted: (value) {
                                  _addTechnology();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _addTechnology,
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Technology chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _technologies.map((tech) {
                            return Chip(
                              label: Text(tech),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setState(() {
                                  _technologies.remove(tech);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Screenshots section
                        const Text(
                          'Project Screenshots',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add screenshots of your project to showcase features and UI',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Add screenshot button
                        ElevatedButton.icon(
                          onPressed: _pickScreenshot,
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Add Screenshot'),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Screenshots grid
                        if (_screenshots.isNotEmpty)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: _screenshots.length,
                            itemBuilder: (context, index) {
                              final screenshot = _screenshots[index];
                              return _buildScreenshotTile(screenshot);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProject,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEditing ? 'Update' : 'Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Build a tile to display a screenshot with options
  Widget _buildScreenshotTile(ProjectScreenshot screenshot) {
    return Stack(
      children: [
        // Screenshot preview
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedScreenshot?.id == screenshot.id 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey.shade300,
              width: _selectedScreenshot?.id == screenshot.id ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image from base64
                ImageUtils.base64ToImage(
                  screenshot.imageBase64,
                  fit: BoxFit.cover,
                ),
                
                // Caption overlay at bottom
                if (screenshot.caption.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: Colors.black.withOpacity(0.5),
                      child: Text(
                        screenshot.caption,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  
                // Semi-transparent overlay when selected
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectScreenshot(screenshot),
                    splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Delete button
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              onPressed: () => _removeScreenshot(screenshot),
              tooltip: 'Remove screenshot',
            ),
          ),
        ),
      ],
    );
  }
  
  // Select a screenshot to edit
  void _selectScreenshot(ProjectScreenshot screenshot) {
    setState(() {
      if (_selectedScreenshot?.id == screenshot.id) {
        _selectedScreenshot = null;
        _screenshotCaptionController.clear();
      } else {
        _selectedScreenshot = screenshot;
        _screenshotCaptionController.text = screenshot.caption;
        
        // Show dialog to edit caption
        _showCaptionEditDialog(screenshot);
      }
    });
  }
  
  // Remove a screenshot
  void _removeScreenshot(ProjectScreenshot screenshot) {
    setState(() {
      _screenshots.removeWhere((s) => s.id == screenshot.id);
      if (_selectedScreenshot?.id == screenshot.id) {
        _selectedScreenshot = null;
        _screenshotCaptionController.clear();
      }
    });
  }
  
  // Show dialog to edit screenshot caption
  void _showCaptionEditDialog(ProjectScreenshot screenshot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Screenshot Caption'),
        content: TextField(
          controller: _screenshotCaptionController,
          decoration: const InputDecoration(
            labelText: 'Caption',
            hintText: 'Enter a caption for this screenshot',
          ),
          maxLength: 100,
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedCaption = _screenshotCaptionController.text;
              setState(() {
                final index = _screenshots.indexWhere((s) => s.id == screenshot.id);
                if (index != -1) {
                  _screenshots[index] = ProjectScreenshot(
                    id: screenshot.id,
                    imageBase64: screenshot.imageBase64,
                    caption: updatedCaption,
                  );
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  // Pick a new screenshot from device
  Future<void> _pickScreenshot() async {
    try {
      final screenshot = await ImageUtils.pickImage();
      if (screenshot != null) {
        // Check if the image is too large (Firestore has a 1MB limit per document)
        final sizeInKB = ImageUtils.getBase64SizeInKB(screenshot.imageBase64);
        if (sizeInKB > 800) { // 800KB seems reasonable, leaving room for other fields
          setState(() {
            _errorMessage = 'Image is too large (${sizeInKB.toStringAsFixed(0)}KB). Please choose a smaller image or reduce quality.';
          });
          return;
        }
        
        // Show caption dialog
        _screenshotCaptionController.clear();
        final captionResult = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Add Caption'),
            content: TextField(
              controller: _screenshotCaptionController,
              decoration: const InputDecoration(
                labelText: 'Caption (Optional)',
                hintText: 'Enter a caption for this screenshot',
              ),
              maxLength: 100,
              maxLines: 2,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _screenshotCaptionController.text);
                },
                child: const Text('Add Screenshot'),
              ),
            ],
          ),
        );
        
        if (captionResult != null) {
          setState(() {
            _screenshots.add(ProjectScreenshot(
              id: screenshot.id,
              imageBase64: screenshot.imageBase64,
              caption: captionResult,
            ));
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking screenshot: ${e.toString()}';
      });
    }
  }
  
  void _addTechnology() {
    if (_newTech.isNotEmpty) {
      setState(() {
        if (!_technologies.contains(_newTech)) {
          _technologies.add(_newTech);
          _techFieldController.clear(); // Clear the field after adding
        }
        _newTech = '';
      });
      
      // Return focus to the field for continuous entry
      FocusScope.of(context).requestFocus();
    }
  }
  
  Future<void> _saveProject() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      try {
        final firestoreService = FirestoreService.instance;
        
        final projectData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'technologies': _technologies,
          'youtubeVideoId': _youtubeIdController.text,
          'date': DateTime.now().toIso8601String(),
          // Use YouTube thumbnail as project thumbnail
          'thumbnailUrl': 'https://img.youtube.com/vi/${_youtubeIdController.text}/hqdefault.jpg',
          'screenshots': _screenshots,
        };
        
        if (widget.project != null) {
          // Update existing project
          await firestoreService.updateProject(widget.project!.id, projectData);

          // Log the activity
          final activityViewModel = Provider.of<ActivityViewModel>(context, listen: false);
          await activityViewModel.logProjectEdit(widget.project!.id, _titleController.text);
  
          // Call onSave callback
          widget.onSave();
          
        } else {
          // After creating new project
          final docRef = await firestoreService.addProject(projectData);
  
          // Log the activity
          final activityViewModel = Provider.of<ActivityViewModel>(context, listen: false);
          await activityViewModel.logActivity(
            type: 'create',
            message: 'You created a new project "${_titleController.text}"',
            entityId: docRef.id,
            metadata: {'title': _titleController.text},
          );
  
          // Call onSave callback
          widget.onSave();
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to save project: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
}