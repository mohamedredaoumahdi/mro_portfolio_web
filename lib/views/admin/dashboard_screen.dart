// lib/views/admin/dashboard_screen.dart
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:portfolio_website/models/activity_model.dart';
import 'package:portfolio_website/models/project_model.dart';
import 'package:portfolio_website/services/firestore_service.dart';
import 'package:portfolio_website/viewmodels/activity_viewmodel.dart';
import 'package:portfolio_website/views/admin/social/social_links_manager.dart' show SocialLinksManagerScreen;
import 'package:provider/provider.dart';
import 'package:portfolio_website/services/auth_service.dart';
import 'package:portfolio_website/viewmodels/theme_viewmodel.dart';
import 'package:portfolio_website/widgets/theme_toggle_button.dart';

// Import admin screens
import 'package:portfolio_website/views/admin/projects/project_manager.dart';
import 'package:portfolio_website/views/admin/services/services_manager.dart';
import 'package:portfolio_website/views/admin/profile/profile_editor.dart';
import 'package:portfolio_website/views/admin/analytics/analytics_dashboard.dart';
import 'package:portfolio_website/views/admin/settings/settings_page.dart';
import 'package:portfolio_website/views/admin/messages/messages_manager.dart';

class AdminDashboardScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const AdminDashboardScreen({
    super.key, 
    this.initialTabIndex = 0,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late int _selectedIndex;
  
  // Method to update selected index (used for quick actions)
  void _updateSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  // Navigation items with icons and labels
  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard'},
    {'icon': Icons.work, 'label': 'Projects'},
    {'icon': Icons.design_services, 'label': 'Services'},
    {'icon': Icons.person, 'label': 'Profile'},
    {'icon': Icons.insert_link, 'label': 'Social Links'},
    {'icon': Icons.email, 'label': 'Messages'},
    {'icon': Icons.analytics, 'label': 'Analytics'},
    {'icon': Icons.settings, 'label': 'Settings'},
  ];
  
  // Content screens for each nav item
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    
    // Initialize screens list
    _screens = [
      const _DashboardOverview(),
      const ProjectManagerScreen(),
      const ServicesManagerScreen(),
      const ProfileEditorScreen(),
      const SocialLinksManagerScreen(),
      const MessagesManagerScreen(), 
      const EnhancedAnalyticsDashboardScreen(),
      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeViewModel>(context).isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          // Theme toggle
          const ThemeToggleButton(isInAppBar: true),
          const SizedBox(width: 8),
          
          // User menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (BuildContext context) {
              final authService = Provider.of<AuthService>(context);
              return [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Text(
                    authService.user?.email ?? 'Admin User',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Side navigation
          NavigationRail(
            extended: MediaQuery.of(context).size.width >= 1200,
            minExtendedWidth: 200,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: _navItems.map((item) => NavigationRailDestination(
              icon: Icon(item['icon']),
              label: Text(item['label']),
            )).toList(),
          ),
          
          // Content area
          Expanded(
            child: Container(
              color: isDarkMode ? Colors.black12 : Colors.grey[100],
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleLogout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/admin-mro');
    }
  }
}

// Dashboard Overview Screen
class _DashboardOverview extends StatefulWidget {
  const _DashboardOverview();

  @override
  State<_DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<_DashboardOverview> {
  bool _isLoading = true;
  Map<String, dynamic> _analyticsData = {};
  List<Project> _projects = [];
  String? _errorMessage;
  late ActivityViewModel _activityViewModel;
  bool _mounted = false;

  @override
  void initState() {
    super.initState();
    _mounted = true;
    _activityViewModel = ActivityViewModel();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _mounted = false;
    _activityViewModel.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (_mounted) {
      setState(fn);
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      _safeSetState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get services for dashboard stats
      final firestoreService = FirestoreService.instance;
      
      // Get analytics data
      final analyticsData = await firestoreService.getAnalyticsData();
      
      // Get projects for counts and latest activities
      final projects = await firestoreService.getProjects();

      // Update state with fetched data
      _safeSetState(() {
        _analyticsData = analyticsData;
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      _safeSetState(() {
        _errorMessage = 'Error loading dashboard data: ${e.toString()}';
        _isLoading = false;
      });
      print('Dashboard data error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error Loading Dashboard Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(_errorMessage!),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Extract values from analytics data for stats
    final totalVisits = _analyticsData['pageVisits']?['totalVisits'] ?? 0;
    final projectCount = _projects.length;
    final contactSubmissionsCount = _analyticsData['contactSubmissionsCount'] ?? 0;
    
    final projectViewsData = _analyticsData['projectViews']?['projects'] as Map<String, dynamic>? ?? {};
    final totalProjectViews = _analyticsData['projectViews']?['totalViews'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to your Admin Dashboard',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your portfolio content and view analytics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            
            // Quick statistics cards
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(
                  context,
                  icon: Icons.visibility,
                  title: 'Total Views',
                  value: totalVisits.toString(),
                  trend: '',
                  trendUp: true,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.work,
                  title: 'Projects',
                  value: projectCount.toString(),
                  trend: '',
                  trendUp: true,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.email,
                  title: 'Messages',
                  value: contactSubmissionsCount.toString(),
                  trend: '',
                  trendUp: true,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.people,
                  title: 'Project Views',
                  value: totalProjectViews.toString(),
                  trend: '',
                  trendUp: true,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Recent activity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () => _activityViewModel.loadActivities(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<ActivityViewModel>(
              builder: (context, activityViewModel, child) {
                if (activityViewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (activityViewModel.errorMessage != null) {
                  return Center(child: Text(activityViewModel.errorMessage!));
                }
                
                final activities = activityViewModel.activities;
                
                if (activities.isEmpty) {
                  return Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.grey, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'No recent activities',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Activities will appear here as you interact with your portfolio',
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _addDemoActivity(),
                              child: const Text('Add Demo Activity'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                
                return Card(
                  elevation: 1,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activities.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      IconData icon;
                      Color iconColor;
                      
                      // Choose icon based on activity type
                      switch (activity.type) {
                        case 'view':
                          icon = Icons.visibility;
                          iconColor = Colors.blue;
                          break;
                        case 'contact':
                          icon = Icons.email;
                          iconColor = Colors.green;
                          break;
                        case 'edit':
                          icon = Icons.edit;
                          iconColor = Theme.of(context).colorScheme.primary;
                          break;
                        default:
                          icon = Icons.notifications;
                          iconColor = Colors.orange;
                      }
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: iconColor.withOpacity(0.1),
                          child: Icon(icon, color: iconColor),
                        ),
                        title: Text(activity.message),
                        subtitle: Text(activity.timeAgo),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showActivityDetails(context, activity);
                        },
                      );
                    },
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Quick actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }
  
  // Add a demo activity for testing
  Future<void> _addDemoActivity() async {
    final random = Random();
    final types = ['view', 'edit', 'contact'];
    final selectedType = types[random.nextInt(types.length)];
    
    String message;
    String? entityId;
    
    if (selectedType == 'view' && _projects.isNotEmpty) {
      final project = _projects[random.nextInt(_projects.length)];
      message = 'Someone viewed your "${project.title}" project';
      entityId = project.id;
      await _activityViewModel.logProjectView(project.id, project.title);
    } else if (selectedType == 'edit' && _projects.isNotEmpty) {
      final project = _projects[random.nextInt(_projects.length)];
      message = 'You updated the "${project.title}" project';
      entityId = project.id;
      await _activityViewModel.logProjectEdit(project.id, project.title);
    } else {
      message = 'New contact message received from "Demo User"';
      entityId = 'demo_contact_${DateTime.now().millisecondsSinceEpoch}';
      await _activityViewModel.logContactSubmission(entityId, 'Demo User');
    }
  }
  
  // Show activity details in a dialog
  void _showActivityDetails(BuildContext context, Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activity Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Type: ${activity.type}'),
              const SizedBox(height: 8),
              Text('Message: ${activity.message}'),
              const SizedBox(height: 8),
              Text('Time: ${activity.timeAgo}'),
              if (activity.entityId != null) ...[
                const SizedBox(height: 8),
                Text('Entity ID: ${activity.entityId}'),
              ],
              if (activity.metadata != null && activity.metadata!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Additional Information:'),
                const SizedBox(height: 8),
                ...activity.metadata!.entries.map(
                  (entry) => Text('${entry.key}: ${entry.value}')
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String trend,
    required bool trendUp,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                if (trend.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trendUp ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                          color: trendUp ? Colors.green : Colors.red,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trend,
                          style: TextStyle(
                            color: trendUp ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.add_circle,
        'label': 'Add New Project',
        'color': Colors.blue,
        'index': 1, // Projects tab index
      },
      {
        'icon': Icons.edit,
        'label': 'Update Profile',
        'color': Colors.orange,
        'index': 3, // Profile tab index
      },
      {
        'icon': Icons.analytics,
        'label': 'View Analytics',
        'color': Colors.purple,
        'index': 5, // Analytics tab index
      },
      {
        'icon': Icons.link,
        'label': 'Manage Links',
        'color': Colors.green,
        'index': 4, // Social links tab index
      },
    ];
    
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: actions.map((action) {
        return InkWell(
          onTap: () {
            // Navigate to the specific screen by updating selectedIndex
            if (action.containsKey('index')) {
              int index = action['index'] as int;
              (context.findAncestorStateOfType<_AdminDashboardScreenState>())?._updateSelectedIndex(index);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (action['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (action['color'] as Color).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action['icon'] as IconData,
                  size: 40,
                  color: action['color'] as Color,
                ),
                const SizedBox(height: 12),
                Text(
                  action['label'] as String,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}