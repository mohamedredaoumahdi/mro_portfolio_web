import 'package:flutter/material.dart';

/// Responsive breakpoints
class ScreenSize {
  static const double mobile = 480.0;
  static const double tablet = 768.0;
  static const double desktop = 1024.0;
  static const double largeDesktop = 1440.0;
}

/// ResponsiveWrapper that adapts content based on screen size
class ResponsiveWrapper extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveWrapper({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ScreenSize.largeDesktop && largeDesktop != null) {
          return largeDesktop!;
        }
        if (constraints.maxWidth >= ScreenSize.desktop && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= ScreenSize.tablet && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

/// Extension methods for responsive sizing
extension ResponsiveExtension on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < ScreenSize.tablet;
  bool get isTablet => MediaQuery.of(this).size.width >= ScreenSize.tablet && MediaQuery.of(this).size.width < ScreenSize.desktop;
  bool get isDesktop => MediaQuery.of(this).size.width >= ScreenSize.desktop && MediaQuery.of(this).size.width < ScreenSize.largeDesktop;
  bool get isLargeDesktop => MediaQuery.of(this).size.width >= ScreenSize.largeDesktop;

  /// Get responsive value based on screen size
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final width = MediaQuery.of(this).size.width;
    
    if (width >= ScreenSize.largeDesktop && largeDesktop != null) return largeDesktop;
    if (width >= ScreenSize.desktop && desktop != null) return desktop;
    if (width >= ScreenSize.tablet && tablet != null) return tablet;
    return mobile;
  }

  /// Get responsive padding
  EdgeInsets get responsivePadding => responsive<EdgeInsets>(
    mobile: const EdgeInsets.all(16),
    tablet: const EdgeInsets.all(24),
    desktop: const EdgeInsets.all(32),
    largeDesktop: const EdgeInsets.all(48),
  );

  /// Get responsive horizontal padding
  EdgeInsets get responsiveHorizontalPadding => responsive<EdgeInsets>(
    mobile: const EdgeInsets.symmetric(horizontal: 16),
    tablet: const EdgeInsets.symmetric(horizontal: 24),
    desktop: const EdgeInsets.symmetric(horizontal: 32),
    largeDesktop: const EdgeInsets.symmetric(horizontal: 48),
  );

  /// Get responsive margin
  EdgeInsets get responsiveMargin => responsive<EdgeInsets>(
    mobile: const EdgeInsets.all(8),
    tablet: const EdgeInsets.all(16),
    desktop: const EdgeInsets.all(24),
    largeDesktop: const EdgeInsets.all(32),
  );

  /// Get responsive content width constraint
  double get contentMaxWidth => responsive<double>(
    mobile: double.infinity,
    tablet: 720,
    desktop: 1200,
    largeDesktop: 1440,
  );
  
  /// Get responsive font size for headings
  double get responsiveHeadingSize => responsive<double>(
    mobile: 24,
    tablet: 28,
    desktop: 32,
    largeDesktop: 36,
  );
  
  /// Get responsive font size for body text
  double get responsiveBodySize => responsive<double>(
    mobile: 14,
    tablet: 15,
    desktop: 16,
    largeDesktop: 16,
  );
}

/// Container that sets max width for content based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool centerContent;
  final double? minHeight;
  final Color? backgroundColor;
  final BoxDecoration? decoration;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.centerContent = true,
    this.minHeight,
    this.backgroundColor,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: context.contentMaxWidth,
          minHeight: minHeight ?? 0,
        ),
        padding: padding ?? context.responsivePadding,
        decoration: decoration,
        color: backgroundColor,
        child: centerContent ? Center(child: child) : child,
      ),
    );
  }
}

/// SafeArea-aware ResponsiveContainer for sections
class ResponsiveSection extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BoxDecoration? decoration;
  final double? minHeight;

  const ResponsiveSection({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.decoration,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: backgroundColor,
        decoration: decoration,
        constraints: BoxConstraints(
          minHeight: minHeight ?? 0,
        ),
        child: ResponsiveContainer(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Grid with responsive column count
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileCrossAxisCount;
  final int tabletCrossAxisCount;
  final int desktopCrossAxisCount;
  final int largeDesktopCrossAxisCount;
  final double childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileCrossAxisCount = 1,
    this.tabletCrossAxisCount = 2,
    this.desktopCrossAxisCount = 3,
    this.largeDesktopCrossAxisCount = 4,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        
        if (constraints.maxWidth >= ScreenSize.largeDesktop) {
          crossAxisCount = largeDesktopCrossAxisCount;
        } else if (constraints.maxWidth >= ScreenSize.desktop) {
          crossAxisCount = desktopCrossAxisCount;
        } else if (constraints.maxWidth >= ScreenSize.tablet) {
          crossAxisCount = tabletCrossAxisCount;
        } else {
          crossAxisCount = mobileCrossAxisCount;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}