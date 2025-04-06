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
    if (isLargeDesktop && largeDesktop != null) return largeDesktop;
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Get responsive padding
  EdgeInsets get responsivePadding => responsive<EdgeInsets>(
    mobile: const EdgeInsets.all(16),
    tablet: const EdgeInsets.all(24),
    desktop: const EdgeInsets.all(32),
    largeDesktop: const EdgeInsets.all(48),
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
}

/// Container that sets max width for content based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: padding ?? context.responsivePadding,
        constraints: BoxConstraints(
          maxWidth: context.contentMaxWidth,
        ),
        child: child,
      ),
    );
  }
}