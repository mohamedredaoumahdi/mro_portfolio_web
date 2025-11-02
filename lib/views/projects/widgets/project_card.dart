// lib/views/projects/widgets/project_card.dart
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../models/project_model.dart';

// Consistent purple colors
class CardColors {
  static const Color primaryPurple = Color(0xFF4A00E0);
  static const Color accentPurple = Color(0xFF8E2DE2);
}

class ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderAnimation;
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for hover effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _elevationAnimation = Tween<double>(begin: 8, end: 20).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _borderAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Initialize YouTube player controller with basic settings
    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: widget.project.youtubeVideoId,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _youtubeController.close();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _animationController.forward();
      },
      onExit: (_) {
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).cardColor.withValues(alpha: 0.9),
                  Theme.of(context).cardColor.withValues(alpha: 0.7),
                ],
              ),
              border: Border.all(
                color: CardColors.accentPurple.withValues(alpha: _borderAnimation.value),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: CardColors.primaryPurple.withValues(alpha: 0.1),
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value / 2),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: _elevationAnimation.value * 1.5,
                  offset: Offset(0, _elevationAnimation.value),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Add bounds checking to prevent assertion failures
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;
            
            // Handle truly invalid constraints only (not just small ones)
            // Note: Infinite height is normal in ListView, so only reject infinite width or zero/negative values
            if (maxWidth <= 0 || (maxHeight <= 0 && !maxHeight.isInfinite) || maxWidth.isInfinite) {
              return const SizedBox.shrink(); // Return empty space for truly invalid constraints
            }
            
            // Use actual constraints but with reasonable minimums for very small screens
            final safeWidth = maxWidth < 150 ? 150.0 : maxWidth;
            // For infinite height (normal in ListView), use a reasonable default
            final safeHeight = maxHeight.isInfinite ? 500.0 : (maxHeight < 200 ? 200.0 : maxHeight);
            
            // Detect if we're in ListView (infinite height) vs GridView (finite height)
            final isInListView = maxHeight.isInfinite;
            
            final cardHeight = safeHeight;
            final cardWidth = safeWidth;
            final isCompact = cardHeight < 500 || cardWidth < 300;
            final isVerySmall = cardHeight < 350 || cardWidth < 250;
            final isExtremelySmall = cardHeight < 250 || cardWidth < 200;
            
            // Calculate dimensions based on available space with better minimum handling
            // For mobile ListView, use more compact proportions
            final videoHeight = isInListView 
                ? 200.0  // Fixed compact height for mobile ListView
                : isExtremelySmall 
                    ? (cardHeight * 0.35).clamp(120.0, 180.0)
                    : isVerySmall 
                        ? cardHeight * 0.40
                        : isCompact 
                            ? cardHeight * 0.48
                            : 260.0;
            final contentPadding = isInListView ? 20.0 : (isExtremelySmall ? 8.0 : isVerySmall ? 12.0 : isCompact ? 16.0 : 24.0);
            final titleFontSize = isExtremelySmall ? 14.0 : isVerySmall ? 16.0 : isCompact ? 18.0 : 20.0;
            // Much more generous description lines for mobile ListView
            final descriptionLines = isInListView ? 8 : (isExtremelySmall ? 2 : isVerySmall ? 3 : isCompact ? 4 : 5);
            final buttonHeight = isExtremelySmall ? 30.0 : isVerySmall ? 34.0 : isCompact ? 38.0 : 44.0;
            final spacingBetween = isInListView ? 12.0 : (isExtremelySmall ? 6.0 : isVerySmall ? 8.0 : isCompact ? 12.0 : 16.0);
            final buttonSpacing = isInListView ? 16.0 : (isExtremelySmall ? 8.0 : isVerySmall ? 10.0 : isCompact ? 12.0 : 16.0);
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: isInListView ? MainAxisSize.min : MainAxisSize.max,
              children: [
                // Responsive YouTube Video container
                Container(
                  width: double.infinity,
                  height: isInListView ? videoHeight : videoHeight.clamp(150.0, 400.0), // No clamp needed for ListView
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: YoutubePlayer(
                    controller: _youtubeController,
                  ),
                ),
                
                // Flexible content container - use Expanded only in GridView, normal Container in ListView
                isInListView ? Container(
                    padding: EdgeInsets.all(contentPadding),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).cardColor.withValues(alpha: 0.0),
                          Theme.of(context).cardColor.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Enhanced project title
                        Container(
                          padding: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: CardColors.accentPurple.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            widget.project.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: titleFontSize,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: spacingBetween),
                        
                        // Enhanced project description - no Expanded in ListView
                        Text(
                          widget.project.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,  // Slightly reduced line height for more content
                            letterSpacing: 0.1,
                          ),
                          maxLines: descriptionLines,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: buttonSpacing),
                        
                        // Premium details button
                        Container(
                          width: double.infinity,
                          height: buttonHeight.clamp(30.0, 50.0), // Ensure reasonable bounds
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                CardColors.primaryPurple,
                                CardColors.accentPurple,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: CardColors.primaryPurple.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: widget.onTap,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                      size: isExtremelySmall ? 14 : isVerySmall ? 16 : isCompact ? 18 : 20,
                                    ),
                                    SizedBox(width: isExtremelySmall ? 4 : isVerySmall ? 6 : isCompact ? 8 : 12),
                                    Text(
                                      isExtremelySmall ? 'Details' : 'View Details',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: isExtremelySmall ? 10 : isVerySmall ? 12 : isCompact ? 14 : 16,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(width: isExtremelySmall ? 2 : isVerySmall ? 4 : isCompact ? 6 : 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: isExtremelySmall ? 12 : isVerySmall ? 14 : isCompact ? 16 : 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ) : Expanded(
                    child: Container(
                      padding: EdgeInsets.all(contentPadding),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).cardColor.withValues(alpha: 0.0),
                            Theme.of(context).cardColor.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enhanced project title
                          Container(
                            padding: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: CardColors.accentPurple.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              widget.project.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: titleFontSize,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: spacingBetween),
                          
                          // Enhanced project description - with Expanded for GridView
                          Expanded(
                            child: Text(
                              widget.project.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.5,  // Slightly reduced line height for more content
                                letterSpacing: 0.1,
                              ),
                              maxLines: descriptionLines,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: buttonSpacing),
                          
                          // Premium details button
                          Container(
                            width: double.infinity,
                            height: buttonHeight.clamp(30.0, 50.0), // Ensure reasonable bounds
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  CardColors.primaryPurple,
                                  CardColors.accentPurple,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: CardColors.primaryPurple.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onTap,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        color: Colors.white,
                                        size: isExtremelySmall ? 14 : isVerySmall ? 16 : isCompact ? 18 : 20,
                                      ),
                                      SizedBox(width: isExtremelySmall ? 4 : isVerySmall ? 6 : isCompact ? 8 : 12),
                                      Text(
                                        isExtremelySmall ? 'Details' : 'View Details',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: isExtremelySmall ? 10 : isVerySmall ? 12 : isCompact ? 14 : 16,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: isExtremelySmall ? 2 : isVerySmall ? 4 : isCompact ? 6 : 8),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: isExtremelySmall ? 12 : isVerySmall ? 14 : isCompact ? 16 : 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}