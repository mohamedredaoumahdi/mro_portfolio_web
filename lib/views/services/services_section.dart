import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../viewmodels/service_viewmodel.dart';
import '../../widgets/responsive_wrapper.dart';
import 'widgets/service_card.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      ),
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Services',
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
              'Specialized mobile development services to bring your ideas to life',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 40),
            Consumer<ServiceViewModel>(
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
                
                return _buildServiceGrid(context, viewModel);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildServiceGrid(BuildContext context, ServiceViewModel viewModel) {
    return AnimationLimiter(
      child: ResponsiveWrapper(
        mobile: _buildServiceList(context, viewModel),
        tablet: _buildServiceGrid2Columns(context, viewModel),
        desktop: _buildServiceGrid4Columns(context, viewModel),
      ),
    );
  }
  
  Widget _buildServiceList(BuildContext context, ServiceViewModel viewModel) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.services.length,
      itemBuilder: (context, index) {
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ServiceCard(service: viewModel.services[index]),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildServiceGrid2Columns(BuildContext context, ServiceViewModel viewModel) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: viewModel.services.length,
      itemBuilder: (context, index) {
        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 600),
          columnCount: 2,
          child: ScaleAnimation(
            child: FadeInAnimation(
              child: ServiceCard(service: viewModel.services[index]),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildServiceGrid4Columns(BuildContext context, ServiceViewModel viewModel) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: viewModel.services.length,
      itemBuilder: (context, index) {
        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 600),
          columnCount: 4,
          child: ScaleAnimation(
            child: FadeInAnimation(
              child: ServiceCard(service: viewModel.services[index]),
            ),
          ),
        );
      },
    );
  }
}