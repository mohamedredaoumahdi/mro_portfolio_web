// lib/views/admin/dashboard_screen.dart
import 'package:flutter/material.dart';
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
  bool _showAllActivities = false;

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
    final totalProjectViews = _analyticsData['projectViews']?['totalViews'] ?? 0;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header and stats on same line (responsive)
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 900;
                
                if (isMobile) {
                  // Stack on mobile
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Column(
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
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Stats cards in grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactStatCard(
                              context,
                              icon: Icons.visibility,
                              title: 'Total Views',
                              value: totalVisits.toString(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactStatCard(
                              context,
                              icon: Icons.work,
                              title: 'Projects',
                              value: projectCount.toString(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactStatCard(
                              context,
                              icon: Icons.email,
                              title: 'Messages',
                              value: contactSubmissionsCount.toString(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactStatCard(
                              context,
                              icon: Icons.people,
                              title: 'Project Views',
                              value: totalProjectViews.toString(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                
                // Desktop: side by side
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header section (left)
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
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
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    
                    // Statistics cards (right)
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildCompactStatCard(
                              context,
                              icon: Icons.visibility,
                              title: 'Total Views',
                              value: totalVisits.toString(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactStatCard(
                              context,
                              icon: Icons.work,
                              title: 'Projects',
                              value: projectCount.toString(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactStatCard(
                              context,
                              icon: Icons.email,
                              title: 'Messages',
                              value: contactSubmissionsCount.toString(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactStatCard(
                              context,
                              icon: Icons.people,
                              title: 'Project Views',
                              value: totalProjectViews.toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Quick actions - simplified
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildQuickActions(context),
            
            const SizedBox(height: 32),
            
            // Recent activity - simplified
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Consumer<ActivityViewModel>(
              builder: (context, activityViewModel, child) {
                if (activityViewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (activityViewModel.errorMessage != null) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            activityViewModel.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                final allActivities = activityViewModel.activities;
                final displayLimit = 5;
                final hasMore = allActivities.length > displayLimit;
                final activities = _showAllActivities 
                    ? allActivities 
                    : allActivities.take(displayLimit).toList();
                
                if (activities.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No recent activities',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Activities will appear here as you interact with your portfolio',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          ...activities.asMap().entries.map((entry) {
                            final index = entry.key;
                            final activity = entry.value;
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
                            
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: index < activities.length - 1
                                    ? Border(
                                        bottom: BorderSide(
                                          color: Theme.of(context).dividerColor.withOpacity(0.1),
                                          width: 1,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: iconColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(icon, color: iconColor, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activity.message,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          activity.timeAgo,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    
                    // Show More button
                    if (hasMore)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showAllActivities = !_showAllActivities;
                            });
                          },
                          icon: Icon(
                            _showAllActivities ? Icons.expand_less : Icons.expand_more,
                          ),
                          label: Text(
                            _showAllActivities ? 'Show Less' : 'Show More',
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
  
  
  // Compact stat card for inline display
  Widget _buildCompactStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    Theme.of(context).cardColor,
                    Theme.of(context).cardColor.withOpacity(0.8),
                  ]
                : [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
          ),
          border: Border.all(
            color: primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with background
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(0.15),
                    primaryColor.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 20,
              ),
            ),
            
            // Value and title
            const SizedBox(height: 12),
            Text(
              value,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    final actions = [
      {
        'icon': Icons.add_circle,
        'label': 'Add New Project',
        'index': 1, // Projects tab index
      },
      {
        'icon': Icons.edit,
        'label': 'Update Profile',
        'index': 3, // Profile tab index
      },
      {
        'icon': Icons.analytics,
        'label': 'View Analytics',
        'index': 6, // Analytics tab index (fixed from 5 to 6)
      },
      {
        'icon': Icons.link,
        'label': 'Manage Links',
        'index': 4, // Social links tab index
      },
    ];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        
        return Wrap(
          spacing: 12,
          runSpacing: 12,
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
                width: isMobile 
                    ? (constraints.maxWidth - 12) / 2
                    : (constraints.maxWidth - 36) / 4,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryColor.withOpacity(0.15),
                            primaryColor.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        size: 24,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        action['label'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}