// lib/views/services/services_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../viewmodels/service_viewmodel.dart';
import '../../widgets/responsive_wrapper.dart';
import '../../widgets/skeleton_loaders/service_skeleton.dart';
import 'widgets/service_card.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  Theme.of(context).colorScheme.surface.withOpacity(0.3),
                  Theme.of(context).colorScheme.surface.withOpacity(0.1),
                ]
              : [
                  Colors.grey[50]!,
                  Colors.white,
                ],
        ),
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
              'Comprehensive mobile development services to bring your ideas to life',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 60),
            Consumer<ServiceViewModel>(
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
                          'Failed to load services',
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
                          onPressed: () => viewModel.loadServices(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (viewModel.services.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.design_services,
                          color: Colors.grey,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No services available',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
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
  
  Widget _buildSkeletonGrid(BuildContext context) {
    return ResponsiveWrapper(
      mobile: _buildSkeletonList(context),
      tablet: _buildSkeletonGrid2Columns(context),
      desktop: _buildSkeletonCarousel(context),
    );
  }
  
  Widget _buildSkeletonList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: ServiceSkeleton(),
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
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const ServiceSkeleton();
      },
    );
  }
  
  Widget _buildSkeletonCarousel(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: 4,
      itemBuilder: (context, index, realIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: const ServiceSkeleton(),
        );
      },
      options: CarouselOptions(
        viewportFraction: 0.23,
        enlargeCenterPage: false,
        enableInfiniteScroll: false,
        autoPlay: false,
        height: 320,
        padEnds: false,
      ),
    );
  }
  
  Widget _buildServiceGrid(BuildContext context, ServiceViewModel viewModel) {
    return AnimationLimiter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use responsive breakpoints
          if (constraints.maxWidth < 768.0) { // ScreenSize.tablet
            // Mobile: List view
            return _buildServiceList(context, viewModel);
          } else if (constraints.maxWidth < 1024.0) { // ScreenSize.desktop
            // Tablet: 2 columns
            return _buildServiceGrid2Columns(context, viewModel);
          } else {
            // Desktop: Dynamic grid based on width and service count
            if (viewModel.services.length <= 4) {
              return _buildServiceRow(context, viewModel);
            } else {
              return _buildServiceGrid4Columns(context, viewModel);
            }
          }
        },
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
  
  Widget _buildServiceRow(BuildContext context, ServiceViewModel viewModel) {
    return Row(
      children: List.generate(
        viewModel.services.length,
        (index) {
          return Expanded(
            child: AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 600),
              columnCount: viewModel.services.length,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < viewModel.services.length - 1 ? 16.0 : 0,
                    ),
                    child: ServiceCard(service: viewModel.services[index]),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceGrid4Columns(BuildContext context, ServiceViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamically determine column count based on available width
        final double cardMinWidth = 280; // Minimum card width
        final double spacing = 20;
        final double availableWidth = constraints.maxWidth;
        
        // Calculate how many columns can fit
        int crossAxisCount = (availableWidth / (cardMinWidth + spacing)).floor();
        crossAxisCount = crossAxisCount.clamp(1, 4); // Between 1 and 4 columns
        
        // Ensure we have enough space for the calculated columns
        final double totalSpacing = (crossAxisCount - 1) * spacing;
        final double cardWidth = (availableWidth - totalSpacing) / crossAxisCount;
        
        // If cards would be too narrow, reduce column count
        if (cardWidth < cardMinWidth && crossAxisCount > 1) {
          crossAxisCount--;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: 24,
            childAspectRatio: 1.0,
          ),
          itemCount: viewModel.services.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 600),
              columnCount: crossAxisCount,
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: ScaleAnimation(
                    scale: 0.9,
                    child: ServiceCard(service: viewModel.services[index]),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildServiceCarousel(BuildContext context, ServiceViewModel viewModel) {
    // Calculate viewport fraction for more than 4 services
    final double viewportFraction = (1.0 / viewModel.services.length) - 0.03;
    
    return CarouselSlider.builder(
      itemCount: viewModel.services.length,
      itemBuilder: (context, index, realIndex) {
        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 600),
          columnCount: viewModel.services.length,
          child: ScaleAnimation(
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ServiceCard(service: viewModel.services[index]),
              ),
            ),
          ),
        );
      },
      options: CarouselOptions(
        viewportFraction: viewportFraction.clamp(0.2, 0.3),
        enlargeCenterPage: false,
        enableInfiniteScroll: true,
        autoPlay: false,
        height: 320,
        padEnds: false,
      ),
    );
  }
}