import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../viewmodels/project_viewmodel.dart';
import '../../widgets/responsive_wrapper.dart';
import 'widgets/project_card.dart';
import 'widgets/project_detail_dialog.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({Key? key}) : super(key: key);

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
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (viewModel.errorMessage != null) {
                  return Center(
                    child: Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: Colors.red),
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
        childAspectRatio: 0.85,
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
        childAspectRatio: 0.85,
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