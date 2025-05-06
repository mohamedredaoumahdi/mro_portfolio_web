// lib/routes/admin_routes.dart - Updated version
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portfolio_website/services/auth_service.dart';
import 'package:portfolio_website/views/admin/login_screen.dart';
import 'package:portfolio_website/views/admin/dashboard_screen.dart';

// Admin route names
class AdminRoutes {
  static const String adminPrefix = '/admin-mro';
  static const String login = adminPrefix;
  static const String dashboard = '$adminPrefix/dashboard';
  static const String projects = '$adminPrefix/projects';
  static const String services = '$adminPrefix/services';
  static const String profile = '$adminPrefix/profile';
  static const String socialLinks = '$adminPrefix/social';
  static const String messages = '$adminPrefix/messages';
  static const String analytics = '$adminPrefix/analytics';
  static const String settings = '$adminPrefix/settings';

  // Register admin routes
  static Map<String, Widget Function(BuildContext)> getRoutes() {
    return {
      login: (context) => const AdminLoginScreen(),
      dashboard: (context) => _protectRoute(const AdminDashboardScreen()),
      projects: (context) => _protectRoute(const AdminDashboardScreen(initialTabIndex: 1)),
      services: (context) => _protectRoute(const AdminDashboardScreen(initialTabIndex: 2)),
      profile: (context) => _protectRoute(const AdminDashboardScreen(initialTabIndex: 3)),
      socialLinks: (context) => _protectRoute(const AdminDashboardScreen(initialTabIndex: 4)),
      messages: (context) => _protectRoute(const AdminDashboardScreen(initialTabIndex: 5)),
      analytics: (context) => _protectRoute(const AdminDashboardScreen(initialTabIndex: 6)),
      settings: (context) => _protectRoute(const AdminDashboardScreen(initialTabIndex: 7)),
    };
  }

  // Protect routes with authentication check
  static Widget _protectRoute(Widget destination) {
    // Implementation unchanged
    return Builder(
      builder: (context) {
        final authService = Provider.of<AuthService>(context);
        
        // If not authenticated, redirect to login
        if (!authService.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, login);
          });
          // Show loading while redirecting
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If authenticated, show the requested page
        return destination;
      },
    );
  }
}