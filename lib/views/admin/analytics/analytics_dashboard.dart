// lib/views/admin/analytics/enhanced_analytics_dashboard.dart
import 'package:flutter/material.dart';
import 'package:portfolio_website/services/firestore_service.dart';
import 'package:portfolio_website/viewmodels/project_viewmodel.dart';
import 'package:portfolio_website/viewmodels/contact_viewmodel.dart';
import 'package:portfolio_website/viewmodels/activity_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class EnhancedAnalyticsDashboardScreen extends StatefulWidget {
  const EnhancedAnalyticsDashboardScreen({super.key});

  @override
  State<EnhancedAnalyticsDashboardScreen> createState() => _EnhancedAnalyticsDashboardScreenState();
}

class _EnhancedAnalyticsDashboardScreenState extends State<EnhancedAnalyticsDashboardScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _analyticsData = {};
  
  // Stats for summary cards
  int _totalPageVisits = 0;
  int _totalProjectViews = 0;
  int _totalContactSubmissions = 0;
  
  // Data for charts
  Map<String, dynamic> _pageVisitsData = {};
  Map<String, dynamic> _projectViewsData = {};
  List<Map<String, dynamic>> _activityData = [];
  Map<DateTime, int> _visitsOverTime = {};
  
  // For tab navigation
  late TabController _tabController;
  
  // Time filters
  String _selectedTimeFilter = 'all';
  final List<String> _timeFilters = ['7d', '30d', '90d', 'all'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      // When tab changes, we might want to refresh specific data
      setState(() {});
    });
    _loadAnalytics();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAnalytics() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final firestoreService = FirestoreService.instance;
      final data = await firestoreService.getAnalyticsData();
      
      // Get activities for timeline
      final activityViewModel = Provider.of<ActivityViewModel>(context, listen: false);
      final activities = await activityViewModel.getRecentActivities(limit: 50);
      
      // Process data for time-based charts
      final visitsOverTime = await _processVisitsOverTime();
      
      setState(() {
        _analyticsData = data;
        _activityData = activities;
        _visitsOverTime = visitsOverTime;
        
        // Extract stats for summary cards
        _totalPageVisits = data['pageVisits']?['totalVisits'] ?? 0;
        _totalProjectViews = data['projectViews']?['totalViews'] ?? 0;
        _totalContactSubmissions = data['contactSubmissionsCount'] ?? 0;
        
        // Extract data for charts
        _pageVisitsData = data['pageVisits']?['pages'] as Map<String, dynamic>? ?? {};
        _projectViewsData = data['projectViews']?['projects'] as Map<String, dynamic>? ?? {};
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load analytics: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  // This would normally come from a real backend with proper analytics
  // Here we're just simulating time-based data
  Future<Map<DateTime, int>> _processVisitsOverTime() async {
    // Simulate daily visits for the past 90 days
    final Map<DateTime, int> result = {};
    final DateTime now = DateTime.now();
    
    for (int i = 90; i >= 0; i--) {
      final DateTime date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      
      // Generate a semi-random number between 1-15, with a slight uptrend over time
      // and weekends having higher traffic
      final int weekdayFactor = date.weekday >= 6 ? 10 : 5; // More traffic on weekends
      final int trendFactor = (90 - i) ~/ 10; // Gradual increase over time
      final int randomFactor = (date.day * date.month) % 5 + 1; // Some randomness
      
      final int visits = weekdayFactor + trendFactor + randomFactor;
      result[date] = visits;
    }
    
    return result;
  }
  
  // Filter data based on selected time period
  Map<DateTime, int> _getFilteredVisitsData() {
    if (_selectedTimeFilter == 'all') {
      return _visitsOverTime;
    }
    
    // Get the cutoff date based on filter
    final DateTime now = DateTime.now();
    DateTime cutoffDate;
    
    switch (_selectedTimeFilter) {
      case '7d':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case '30d':
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case '90d':
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      default:
        cutoffDate = now.subtract(const Duration(days: 30));
    }
    
    // Filter the data
    return Map.fromEntries(
      _visitsOverTime.entries.where((entry) => entry.key.isAfter(cutoffDate))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Analytics Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Row(
                  children: [
                    // Time filter dropdown
                    DropdownButton<String>(
                      value: _selectedTimeFilter,
                      items: _timeFilters.map((filter) {
                        String label;
                        switch (filter) {
                          case '7d':
                            label = 'Last 7 days';
                            break;
                          case '30d':
                            label = 'Last 30 days';
                            break;
                          case '90d':
                            label = 'Last 90 days';
                            break;
                          case 'all':
                            label = 'All time';
                            break;
                          default:
                            label = filter;
                        }
                        
                        return DropdownMenuItem<String>(
                          value: filter,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedTimeFilter = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    // Refresh button
                    ElevatedButton.icon(
                      onPressed: _loadAnalytics,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Track visitor interactions and engagement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            
            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            
            // Stats cards
            _buildStatisticsCards(context),
            const SizedBox(height: 24),
            
            // Tab navigator for different dashboards
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Projects'),
                Tab(text: 'Activity'),
              ],
            ),
            
            // Tab content
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildProjectsTab(),
                      _buildActivityTab(),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Statistics cards at the top of the dashboard
  Widget _buildStatisticsCards(BuildContext context) {
    // Calculate trends (simulated for now)
    const trend1 = '+12%';
    const trend2 = '+8%';
    const trend3 = '+15%';
    
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          context,
          title: 'Page Visits',
          value: _totalPageVisits.toString(),
          icon: Icons.visibility,
          color: Colors.blue,
          trend: trend1,
          trendUp: true,
        ),
        _buildStatCard(
          context,
          title: 'Project Views',
          value: _totalProjectViews.toString(),
          icon: Icons.work,
          color: Colors.purple,
          trend: trend2,
          trendUp: true,
        ),
        _buildStatCard(
          context,
          title: 'Contact Submissions',
          value: _totalContactSubmissions.toString(),
          icon: Icons.email,
          color: Colors.green,
          trend: trend3,
          trendUp: true,
        ),
      ],
    );
  }
  
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    required bool trendUp,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color),
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
  
  // Overview tab with line chart and page visits
  Widget _buildOverviewTab() {
    // Get filtered data based on time selection
    final filteredData = _getFilteredVisitsData();
    
    if (filteredData.isEmpty) {
      return const Center(child: Text('No data available for the selected time period'));
    }
    
    // Prepare data for line chart
    final List<FlSpot> spots = [];
    filteredData.forEach((date, count) {
      // Convert date to X coordinate (days since start)
      final firstDate = filteredData.keys.first;
      final daysSinceStart = date.difference(firstDate).inDays.toDouble();
      spots.add(FlSpot(daysSinceStart, count.toDouble()));
    });
    
    // Sort spots by X value
    spots.sort((a, b) => a.x.compareTo(b.x));
    
    // Find max Y for line chart scale
    final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Visits Over Time',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Track how your portfolio visits have changed over time',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          // Line chart for visits over time
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _selectedTimeFilter == '7d' ? 1 : 
                               _selectedTimeFilter == '30d' ? 5 :
                               _selectedTimeFilter == '90d' ? 15 : 30,
                      getTitlesWidget: (value, meta) {
                        // Convert X coordinate back to date
                        if (filteredData.isEmpty || value < 0 || value >= spots.length) {
                          return const Text('');
                        }
                        
                        final firstDate = filteredData.keys.first;
                        final date = firstDate.add(Duration(days: value.toInt()));
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MM/dd').format(date),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY > 50 ? 10 : maxY > 20 ? 5 : 2,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                minX: 0,
                maxX: spots.length.toDouble() - 1,
                minY: 0,
                maxY: maxY * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Page visits breakdown
          Text(
            'Page Visits Breakdown',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildPageVisitsTable(),
        ],
      ),
    );
  }
  
  Widget _buildPageVisitsTable() {
    if (_pageVisitsData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No page visits data available'),
        ),
      );
    }
    
    // Sort pages by visit count in descending order
    final sortedPages = _pageVisitsData.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));
      
    // Format page names for better display
    final pageNames = {
      '/': 'Home',
      '#services': 'Services',
      '#projects': 'Projects',
      '#contact': 'Contact',
    };
    
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Page')),
              DataColumn(label: Text('Visits'), numeric: true),
              DataColumn(label: Text('Percentage'), numeric: true),
            ],
            rows: sortedPages.map((entry) {
              final pagePath = entry.key;
              final visitCount = entry.value as int;
              final percentage = (_totalPageVisits > 0 
                  ? (visitCount / _totalPageVisits * 100) 
                  : 0).toStringAsFixed(1);
                  
              final pageName = pageNames[pagePath] ?? pagePath;
              
              return DataRow(
                cells: [
                  DataCell(Text(pageName)),
                  DataCell(Text(visitCount.toString())),
                  DataCell(Text('$percentage%')),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  
  // Projects tab with project views data
  Widget _buildProjectsTab() {
    if (_projectViewsData.isEmpty) {
      return const Center(child: Text('No project views data available'));
    }
    
    // Get project data from view model to map IDs to titles
    final projectViewModel = Provider.of<ProjectViewModel>(context);
    final projects = projectViewModel.projects;
    
    // Map project IDs to titles
    final Map<String, String> projectIdToTitle = {};
    for (final project in projects) {
      projectIdToTitle[project.id] = project.title;
    }
    
    // Sort projects by view count in descending order
    final sortedProjects = _projectViewsData.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));
    
    // Prepare data for the chart
    final List<Map<String, dynamic>> chartData = [];
    for (var i = 0; i < sortedProjects.length && i < 5; i++) {
      final projectId = sortedProjects[i].key;
      final viewCount = sortedProjects[i].value as int;
      final title = projectIdToTitle[projectId] ?? 'Unknown Project';
      
      chartData.add({
        'title': title,
        'views': viewCount,
      });
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Most Viewed Projects',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          // Bar chart for top projects
          SizedBox(
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chartData.isEmpty ? 10 : (chartData.first['views'] * 1.2),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Theme.of(context).cardColor,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        if (groupIndex >= chartData.length) return null;
                        return BarTooltipItem(
                          '${chartData[groupIndex]['title']}\n',
                          const TextStyle(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: '${chartData[groupIndex]['views']} views',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value >= chartData.length) return const SizedBox();
                          String title = chartData[value.toInt()]['title'];
                          if (title.length > 15) {
                            title = '${title.substring(0, 12)}...';
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              title,
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    chartData.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: chartData[index]['views'].toDouble(),
                          color: Theme.of(context).colorScheme.primary,
                          width: 22,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Project views table
          Text(
            'Project Views Breakdown',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Project')),
                    DataColumn(label: Text('Views'), numeric: true),
                    DataColumn(label: Text('Percentage'), numeric: true),
                  ],
                  rows: sortedProjects.map((entry) {
                    final projectId = entry.key;
                    final viewCount = entry.value as int;
                    final percentage = (_totalProjectViews > 0 
                        ? (viewCount / _totalProjectViews * 100) 
                        : 0).toStringAsFixed(1);
                    final title = projectIdToTitle[projectId] ?? 'Unknown Project';
                    
                    return DataRow(
                      cells: [
                        DataCell(Text(title)),
                        DataCell(Text(viewCount.toString())),
                        DataCell(Text('$percentage%')),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Activity tab with timeline of events
  Widget _buildActivityTab() {
  if (_activityData.isEmpty) {
    return const Center(child: Text('No activity data available'));
  }
  
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        // Activity timeline
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _activityData.length,
          itemBuilder: (context, index) {
            final activity = _activityData[index];
            
            // Handle timestamp properly with nullcheck
            final timestamp = activity['timestamp']; 
            String formattedDate;
            
            if (timestamp is DateTime) {
              formattedDate = DateFormat('MMM d, yyyy - h:mm a').format(timestamp);
            } else {
              // Fallback for cases where timestamp might be a string or another format
              formattedDate = "Unknown date";
            }
            
            Color indicatorColor;
            IconData indicatorIcon;
            
            // Determine icon and color based on activity type
            switch (activity['type']) {
              case 'view':
                indicatorColor = Colors.blue;
                indicatorIcon = Icons.visibility;
                break;
              case 'edit':
                indicatorColor = Colors.orange;
                indicatorIcon = Icons.edit;
                break;
              case 'contact':
                indicatorColor = Colors.green;
                indicatorIcon = Icons.email;
                break;
              case 'create':
                indicatorColor = Colors.purple;
                indicatorIcon = Icons.add_circle;
                break;
              case 'delete':
                indicatorColor = Colors.red;
                indicatorIcon = Icons.delete;
                break;
              default:
                indicatorColor = Colors.grey;
                indicatorIcon = Icons.circle;
            }
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: indicatorColor.withOpacity(0.2),
                          child: Icon(indicatorIcon, color: indicatorColor, size: 20),
                        ),
                        if (index < _activityData.length - 1)
                          Container(
                            width: 2,
                            height: 30,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    
                    // Activity content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['message'] ?? 'Unknown activity',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
  
  // Method to get color for a data label
  Color _getColorForLabel(String label) {
    // Generate a consistent color based on the label string
    final colorSeed = label.codeUnits.fold(0, (prev, element) => prev + element);
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.amber,
      Colors.pink,
    ];
    
    return colors[colorSeed % colors.length];
  }
  
  // Method to create a donut chart for categorical data
  Widget _buildDonutChart(Map<String, int> data) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data available')),
      );
    }
    
    final total = data.values.fold(0, (sum, item) => sum + item);
    
    // Prepare sections
    final sections = <PieChartSectionData>[];
    data.forEach((label, value) {
      final double percentage = total > 0 ? (value / total * 100) : 0;
      sections.add(PieChartSectionData(
        color: _getColorForLabel(label),
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    });
    
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          startDegreeOffset: -90,
        ),
      ),
    );
  }
  
  // Method to build a list of legend items for charts
  Widget _buildLegend(Map<String, int> data) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getColorForLabel(entry.key),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              entry.key,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
  
  // Helper method to format dates for display
  String _formatDate(DateTime date, {bool showTime = false}) {
    if (showTime) {
      return DateFormat('MMM d, yyyy h:mm a').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
  
  // Build a heat map for showing data intensity across days
  Widget _buildHeatMap() {
    // This would normally pull real data, but here we just generate sample data
    final DateTime now = DateTime.now();
    
    // Generate a grid of data for the last 12 weeks (7 days x 12 weeks)
    final List<List<int>> heatmapData = [];
    
    for (int week = 0; week < 12; week++) {
      final List<int> weekData = [];
      for (int day = 0; day < 7; day++) {
        // Generate a random value for this day 
        final int value = (week * 7 + day) % 30;
        weekData.add(value);
      }
      heatmapData.add(weekData);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: Row(
            children: [
              // Day labels (Monday-Sunday)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Mon', style: TextStyle(fontSize: 10)),
                  Text('Wed', style: TextStyle(fontSize: 10)),
                  Text('Fri', style: TextStyle(fontSize: 10)),
                  Text('Sun', style: TextStyle(fontSize: 10)),
                ],
              ),
              const SizedBox(width: 4),
              
              // Heatmap grid
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: heatmapData.length,
                  itemBuilder: (context, weekIndex) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (dayIndex) {
                        final value = heatmapData[weekIndex][dayIndex];
                        return Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(value / 30),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Legend
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Less', style: TextStyle(fontSize: 10)),
            const SizedBox(width: 4),
            ...List.generate(5, (index) {
              return Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(index / 4),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
            const SizedBox(width: 4),
            const Text('More', style: TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }
}