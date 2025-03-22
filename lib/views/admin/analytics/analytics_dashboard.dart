// lib/views/admin/analytics/analytics_dashboard.dart
import 'package:flutter/material.dart';
import 'package:portfolio_website/services/firestore_service.dart';
import 'package:portfolio_website/viewmodels/project_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _analyticsData = {};
  
  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }
  
  Future<void> _loadAnalytics() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final firestoreService = FirestoreService();
      final data = await firestoreService.getAnalyticsData();
      
      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load analytics: ${e.toString()}';
        _isLoading = false;
      });
    }
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
                ElevatedButton.icon(
                  onPressed: _loadAnalytics,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
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
            
            // Analytics content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildAnalyticsContent(context),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnalyticsContent(BuildContext context) {
    if (_analyticsData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics, color: Colors.grey, size: 64),
            const SizedBox(height: 24),
            Text(
              'No analytics data available yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'Analytics data will be collected as visitors interact with your portfolio',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Extract data
    final Map<String, dynamic> pageVisits = 
        _analyticsData['pageVisits'] as Map<String, dynamic>? ?? {};
    final Map<String, dynamic> projectViews = 
        _analyticsData['projectViews'] as Map<String, dynamic>? ?? {};
    final Map<String, dynamic> contactSubmissions = 
        _analyticsData['contactSubmissions'] as Map<String, dynamic>? ?? {};
    
    final int totalVisits = pageVisits['totalVisits'] ?? 0;
    final int totalProjectViews = projectViews['totalViews'] ?? 0;
    final int totalContacts = contactSubmissions['totalSubmissions'] ?? 0;
    
    final Map<String, dynamic> pageVisitsData = 
        pageVisits['pages'] as Map<String, dynamic>? ?? {};
    final Map<String, dynamic> projectViewsData = 
        projectViews['projects'] as Map<String, dynamic>? ?? {};
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Statistics
          _buildStatisticsCards(
            context, 
            totalVisits: totalVisits,
            totalProjectViews: totalProjectViews,
            totalContacts: totalContacts,
          ),
          const SizedBox(height: 32),
          
          // Projects data
          _buildProjectViewsSection(context, projectViewsData),
          const SizedBox(height: 32),
          
          // Page visits
          _buildPageVisitsSection(context, pageVisitsData),
        ],
      ),
    );
  }
  
  Widget _buildStatisticsCards(
    BuildContext context, {
    required int totalVisits,
    required int totalProjectViews,
    required int totalContacts,
  }) {
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
          value: totalVisits.toString(),
          icon: Icons.visibility,
          color: Colors.blue,
        ),
        _buildStatCard(
          context,
          title: 'Project Views',
          value: totalProjectViews.toString(),
          icon: Icons.work,
          color: Colors.purple,
        ),
        _buildStatCard(
          context,
          title: 'Contact Submissions',
          value: totalContacts.toString(),
          icon: Icons.email,
          color: Colors.green,
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
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProjectViewsSection(
    BuildContext context, 
    Map<String, dynamic> projectViewsData,
  ) {
    return Consumer<ProjectViewModel>(
      builder: (context, projectViewModel, child) {
        if (projectViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (projectViewModel.projects.isEmpty || projectViewsData.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Map project IDs to titles
        final Map<String, String> projectIdToTitle = {};
        for (final project in projectViewModel.projects) {
          projectIdToTitle[project.id] = project.title;
        }
        
        // Create data for chart
        final List<MapEntry<String, dynamic>> sortedProjects = 
            projectViewsData.entries.toList()
              ..sort((a, b) => (b.value as int).compareTo(a.value as int));
        
        // Take top 5 projects
        final List<MapEntry<String, dynamic>> topProjects = 
            sortedProjects.take(5).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Viewed Projects',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: topProjects.isEmpty
                  ? const Center(
                      child: Text('No project views data available yet'),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: topProjects.first.value.toDouble() * 1.2,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                            tooltipPadding: const EdgeInsets.all(12),
                            tooltipMargin: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final projectId = topProjects[groupIndex].key;
                              final projectTitle = projectIdToTitle[projectId] ?? 'Unknown Project';
                              final viewCount = topProjects[groupIndex].value;
                              return BarTooltipItem(
                                '$projectTitle\n',
                                const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: '$viewCount views',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.normal,
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
                                if (value >= topProjects.length || value < 0) {
                                  return const SizedBox.shrink();
                                }
                                final projectId = topProjects[value.toInt()].key;
                                final projectTitle = projectIdToTitle[projectId] ?? 'Unknown';
                                
                                // Abbreviate long project titles
                                String displayTitle = projectTitle;
                                if (displayTitle.length > 10) {
                                  displayTitle = '${displayTitle.substring(0, 8)}...';
                                }
                                
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    displayTitle,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
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
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    value.toInt().toString(),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: topProjects.first.value.toDouble() / 5,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Theme.of(context).dividerColor.withOpacity(0.3),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: List.generate(topProjects.length, (index) {
                          final projectViews = topProjects[index].value.toDouble();
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: projectViews,
                                color: Theme.of(context).colorScheme.primary,
                                width: 20,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            _buildProjectViewsTable(context, sortedProjects, projectIdToTitle),
          ],
        );
      },
    );
  }
  
  Widget _buildProjectViewsTable(
    BuildContext context,
    List<MapEntry<String, dynamic>> projectViews,
    Map<String, String> projectIdToTitle,
  ) {
    if (projectViews.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Views Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Project')),
                  DataColumn(label: Text('Views'), numeric: true),
                ],
                rows: projectViews.map((entry) {
                  final projectId = entry.key;
                  final viewCount = entry.value as int;
                  final projectTitle = projectIdToTitle[projectId] ?? 'Unknown Project';
                  
                  return DataRow(
                    cells: [
                      DataCell(Text(projectTitle)),
                      DataCell(Text(viewCount.toString())),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPageVisitsSection(
    BuildContext context,
    Map<String, dynamic> pageVisitsData,
  ) {
    if (pageVisitsData.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Create data for chart
    final List<MapEntry<String, dynamic>> sortedPages = 
        pageVisitsData.entries.toList()
          ..sort((a, b) => (b.value as int).compareTo(a.value as int));
    
    // Take top 5 pages
    final List<MapEntry<String, dynamic>> topPages = 
        sortedPages.take(5).toList();
    
    // Format page names
    final Map<String, String> pageNames = {
      '/': 'Home',
      '#services': 'Services',
      '#projects': 'Projects',
      '#contact': 'Contact',
    };
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Page Visits',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Page Visits Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Page')),
                      DataColumn(label: Text('Visits'), numeric: true),
                    ],
                    rows: sortedPages.map((entry) {
                      final pagePath = entry.key;
                      final visitCount = entry.value as int;
                      final pageName = pageNames[pagePath] ?? pagePath;
                      
                      return DataRow(
                        cells: [
                          DataCell(Text(pageName)),
                          DataCell(Text(visitCount.toString())),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}