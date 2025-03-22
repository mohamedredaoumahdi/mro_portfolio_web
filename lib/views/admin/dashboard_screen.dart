// lib/views/admin/dashboard_screen.dart
import 'package:flutter/material.dart';
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

class AdminDashboardScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const AdminDashboardScreen({
    Key? key, 
    this.initialTabIndex = 0,
  }) : super(key: key);

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
      const AnalyticsDashboardScreen(),
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

// Dashboard Overview Screen - keep as is
class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                value: '5,248',
                trend: '+12%',
                trendUp: true,
              ),
              _buildStatCard(
                context,
                icon: Icons.work,
                title: 'Projects',
                value: '8',
                trend: '+1',
                trendUp: true,
              ),
              _buildStatCard(
                context,
                icon: Icons.email,
                title: 'Messages',
                value: '24',
                trend: '+3',
                trendUp: true,
              ),
              _buildStatCard(
                context,
                icon: Icons.people,
                title: 'Unique Visitors',
                value: '1,856',
                trend: '+8%',
                trendUp: true,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recent activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildActivityList(context),
          
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
  
  Widget _buildActivityList(BuildContext context) {
    final activities = [
      {
        'type': 'view',
        'message': 'Someone viewed your E-Commerce Mobile App project',
        'time': '2 minutes ago',
      },
      {
        'type': 'contact',
        'message': 'New contact message received',
        'time': '1 hour ago',
      },
      {
        'type': 'edit',
        'message': 'You updated the Food Delivery Application project',
        'time': '3 hours ago',
      },
      {
        'type': 'view',
        'message': 'Someone viewed your Fitness Tracking App project',
        'time': '5 hours ago',
      },
    ];
    
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
          switch (activity['type']) {
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
            title: Text(activity['message'] ?? ''),
            subtitle: Text(activity['time'] ?? ''),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to detail page or show more info
            },
          );
        },
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