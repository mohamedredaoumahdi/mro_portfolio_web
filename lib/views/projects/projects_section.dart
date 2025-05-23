// lib/views/projects/projects_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../viewmodels/project_viewmodel.dart';
import '../../widgets/responsive_wrapper.dart';
import '../../widgets/skeleton_loaders/project_skeleton.dart';
import 'widgets/project_card.dart';
import 'widgets/project_detail_dialog.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Projects',
              style: context.responsive<TextStyle>(
                mobile: Theme.of(context).textTheme.headlineSmall!,
                tablet: Theme.of(context).textTheme.headlineMedium!,
                desktop: Theme.of(context).textTheme.headlineLarge!,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Featured mobile applications showcasing my development skills',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 60),
            Consumer<ProjectViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return _buildSkeletonGrid(context);
                }
                
                if (viewModel.errorMessage != null) {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load projects',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          viewModel.errorMessage!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.red.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => viewModel.loadProjects(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (viewModel.projects.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.folder_open,
                          color: Colors.grey,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No projects available',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return _buildProjectsGrid(context, viewModel);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSkeletonGrid(BuildContext context) {
    return ResponsiveWrapper(
      mobile: _buildSkeletonList(context),
      tablet: _buildSkeletonGrid2Columns(context),
      desktop: _buildSkeletonGrid3Columns(context),
    );
  }
  
  Widget _buildSkeletonList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: ProjectSkeleton(),
        );
      },
    );
  }
  
  Widget _buildSkeletonGrid2Columns(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.7, // Adjusted for new card layout
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const ProjectSkeleton();
      },
    );
  }
  
  Widget _buildSkeletonGrid3Columns(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.7, // Adjusted for new card layout
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const ProjectSkeleton();
      },
    );
  }
  
  Widget _buildProjectsGrid(BuildContext context, ProjectViewModel viewModel) {
    return AnimationLimiter(
      child: ResponsiveWrapper(
        mobile: _buildProjectsList(context, viewModel),
        tablet: _buildProjectsGrid2Columns(context, viewModel),
        desktop: _buildProjectsGrid3Columns(context, viewModel),
      ),
    );
  }
  
  Widget _buildProjectsList(BuildContext context, ProjectViewModel viewModel) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.projects.length,
      itemBuilder: (context, index) {
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ProjectCard(
                  project: viewModel.projects[index],
                  // Only the Details button will trigger this
                  onTap: () => _showProjectDetails(context, viewModel.projects[index]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildProjectsGrid2Columns(BuildContext context, ProjectViewModel viewModel) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.7, // Adjusted for new card layout
      ),
      itemCount: viewModel.projects.length,
      itemBuilder: (context, index) {
        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 600),
          columnCount: 2,
          child: ScaleAnimation(
            child: FadeInAnimation(
              child: ProjectCard(
                project: viewModel.projects[index],
                // Only the Details button will trigger this
                onTap: () => _showProjectDetails(context, viewModel.projects[index]),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildProjectsGrid3Columns(BuildContext context, ProjectViewModel viewModel) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.7, // Adjusted for new card layout
      ),
      itemCount: viewModel.projects.length,
      itemBuilder: (context, index) {
        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 600),
          columnCount: 3,
          child: ScaleAnimation(
            child: FadeInAnimation(
              child: ProjectCard(
                project: viewModel.projects[index],
                // Only the Details button will trigger this
                onTap: () => _showProjectDetails(context, viewModel.projects[index]),
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _showProjectDetails(BuildContext context, dynamic project) {
    showDialog(
      context: context,
      builder: (context) => ProjectDetailDialog(project: project),
    );
  }
}